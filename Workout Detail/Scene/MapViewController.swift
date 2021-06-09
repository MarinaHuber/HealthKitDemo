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
import HealthKit

class MapViewController: UIViewController, MKMapViewDelegate {
 
    private var mapView = MKMapView()
    private var regionRadius: CLLocationDistance = 4000
    private var locationSamples: [CLLocation] = []

    private lazy var chartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 50 / 2.0
        return button
    }()
    
    init() {
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
        self.setupViews()
        self.setupConstraints()
        self.mapView.delegate = self

    }
    
    func setupViews() {
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.chartButton)
        self.addRoute()
    }
    
    func setupConstraints() {
        self.mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.chartButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(-30)
            make.height.width.equalTo(50)
        }
    }
    
    func drawRoute() {
        HealthManager.shared.getRouteValueFromHealthKit { locations, error in
          //  locations.forEach { location in
                let coords = locations.map { location in CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(location.coordinate.latitude),
                            longitude: CLLocationDegrees(location.coordinate.longitude))
                            }

                let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
                DispatchQueue.main.async {
                self.mapView.addOverlay(myPolyline)
              }
           // }
        }
        
        
        guard locationSamples.count > 0 else {
            return
        }
            self.locationSamples.forEach { location in
                let coords = self.locationSamples.map { _ in CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(location.coordinate.latitude),
                            longitude: CLLocationDegrees(location.coordinate.longitude))
                            }

                let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
                DispatchQueue.main.async {
                self.mapView.addOverlay(myPolyline)
              }
            }
        }
         

        
    
    func addRoute() {
        let workoutList = WorkoutMapper.parseGPX()
        self.drawRoute()
    
        let centerLocation = workoutList.map { $0.coordinates }
        self.centerMapOnStartLocation(location: centerLocation.last!)
    }
    
    @objc func handleButtonPressed(_ sender: UIButton) {
        let chart = ChartViewController()
        self.navigationController?.presentPanModal(chart)
    }


    // MARK: - MapKit
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
    
    #warning("center map improve")
    //*******
    //                let latitudes = locations.map {
    //                    $0.coordinate.latitude
    //                }
    //                let longitudes = locations.map {
    //                    $0.coordinate.longitude
    //                }
    //
    //                // Outline map region to display
    //                guard let maxLat = latitudes.max() else { fatalError("Unable to get maxLat") }
    //                guard let minLat = latitudes.min() else { return }
    //                guard let maxLong = longitudes.max() else { return }
    //                guard let minLong = longitudes.min() else { return }
    //
    //                if done {
    //                    let mapCenter = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
    //                    let mapSpan = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * mapDisplayAreaPadding,
    //                                                  longitudeDelta: (maxLong - minLong) * mapDisplayAreaPadding)
    //
    //                    DispatchQueue.main.async {
    //                        // Push to main thread to drop dots on the map.
    //                        // Without this a warning will occur.
    //                        self.region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
    //                        locations.forEach { (location) in
    //                            self.overlayRoute(at: location)
    //                        }
