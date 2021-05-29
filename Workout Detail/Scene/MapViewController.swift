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
 
    private var mapView = MKMapView()
    let regionRadius: CLLocationDistance = 4000

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
    
    func drawRoute(locations: [GPXLocation]) {
        let coords = locations.map { CLLocationCoordinate2D(
            latitude: CLLocationDegrees($0.coordinates.coordinate.latitude),
            longitude: CLLocationDegrees($0.coordinates.coordinate.longitude))
        }
  
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        self.mapView.addOverlay(myPolyline)
    }
    
    @objc func handleButtonPressed(_ sender: UIButton) {
        let chart = SpeedChartView()
        self.navigationController?.presentPanModal(chart)
    }

    
    func addRoute() {
        let locations = WorkoutMapper.parse()
        self.drawRoute(locations: locations)
        locations.forEach {
            self.centerMapOnStartLocation(location: $0.coordinates)
        }
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
