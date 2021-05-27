//
//  MapViewController.swift
//  Workout Detail
//
//  Created by Marina Huber on 26.05.2021..
//

import Foundation
import SnapKit
import UIKit
import MapKit
import os
import PanModal
import CoreGPX

class MapViewController: UIViewController, MKMapViewDelegate {
 
    private let gpxService: GPXService
    private var mapView = MKMapView()
    private var routeLocations = [CLLocation]()
    let regionRadius: CLLocationDistance = 4000

    private lazy var chartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 50 / 2.0
        return button
    }()
    
    init(gpxService: GPXService) {
        self.gpxService = gpxService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        os_log("MapViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.chartButton)
        self.mapView.delegate = self

        self.mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.chartButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(-30)
            make.height.width.equalTo(50)
        }
        self.addRoute()
        let coords = routeLocations.map { CLLocationCoordinate2D(
          latitude: CLLocationDegrees($0.coordinate.latitude),
          longitude: CLLocationDegrees($0.coordinate.longitude))
        }
  
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        self.mapView.addOverlay(myPolyline)
    }
    
    @objc func handleButtonPressed(_ sender: UIButton) {
        let chart = SpeedChartView()
        self.navigationController?.presentPanModal(chart)
    }

    
    func addRoute() {
        guard let fileUrl = Bundle.main.url(forResource: "import", withExtension: "gpx") else {
            os_log("Could not find file", type: .error)
            return
        }
        
        guard let gpx = GPXParser(withURL: fileUrl)?.parsedData() else {
            os_log("Could not parse file", type: .error)
            return
        }
        
        var allHr = [Date: Int]()
        
        for track in gpx.tracks {
            for segment in track.segments {
                for trackPoint in segment.points {
                    guard let location = trackPoint.coreLocation
                    else {
                        os_log("Could not make location out of waypoint")
                        continue
                    }
                    self.routeLocations.append(location)

                    self.centerMapOnStartLocation(location: location)
                    
                    
                    if let heartRateString = trackPoint.extensions?["gpxtpx:TrackPointExtension"]["gpxtpx:hr"].text,
                       let hrDouble = Int(heartRateString),
                       let date = trackPoint.time // UTC
                       {
                        allHr[date] = hrDouble
                        
                    }
                }
            }
        }
        
        os_log("Finished reading data")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = .green
            renderer.lineWidth = 6
            return renderer
        }

        return MKOverlayRenderer()
    }
    
    // MARK: - Region Zoom
    func centerMapOnStartLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }

}
