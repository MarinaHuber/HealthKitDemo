//
//  WorkoutProvider.swift
//  Workout Detail
//
//  Created by Marina Huber on 03.10.2021..
//

import Foundation
import MapKit
import SwiftUI

class WorkoutProvider: ObservableObject {
    
    
    func drawRoute(mapView: MKMapView) {
        HealthManager.shared.getRouteValueFromHealthKit { locations, error in
            //center the map at the start of the route
            let centerLocation = locations.map { $0 }
            self.centerMapOnLocation(location: centerLocation.first!, mapView: mapView)
            
            let coords = locations.map { location in CLLocationCoordinate2D(
                latitude: CLLocationDegrees(location.coordinate.latitude),
                longitude: CLLocationDegrees(location.coordinate.longitude))
            }
            
            let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
            DispatchQueue.main.async {
                mapView.addOverlay(myPolyline)
            }
        }
    }
    
    
    // MARK: - Region Zoom
    
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        DispatchQueue.main.async {
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
}
