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
    
    private lazy var chartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 50 / 2.0
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addAction(UIAction(title: ""){ _ in print("Hello Menu")},for: .menuActionTriggered)
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.view.addSubview(self.menuButton)
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
        self.menuButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-30)
            make.height.width.equalTo(30)
        }
    }
    
    func addRoute() {
        let workoutList = WorkoutMapper.parseGPX()
        self.drawRoute()
        
        let centerLocation = workoutList.map { $0.coordinates }
        self.centerMapOnLocation(location: centerLocation.first!)
    }
    
    func drawRoute() {
        HealthManager.shared.getRouteValueFromHealthKit { locations, error in
            let coords = locations.map { location in CLLocationCoordinate2D(
                latitude: CLLocationDegrees(location.coordinate.latitude),
                longitude: CLLocationDegrees(location.coordinate.longitude))
            }
            
            let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
            DispatchQueue.main.async {
                self.mapView.addOverlay(myPolyline)
            }
        }
    }
    
    
    @objc func handleButtonPressed(_ sender: UIButton) {
        let chart = ChartViewController()
        self.navigationController?.presentPanModal(chart)
    }
    
    @objc func handlMenuPressed(_ sender: UIButton) {

    }
    
    // MARK: - MapKit
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor(named: "Route")
            renderer.lineWidth = 7
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    // MARK: - Region Zoom
    
    func centerMapOnLocation(location: CLLocation) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
}
