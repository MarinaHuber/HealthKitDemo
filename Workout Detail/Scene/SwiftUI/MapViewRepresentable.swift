//
//  MapView.swift
//  Workout Detail
//
//  Created by Marina Huber on 01.10.2021..
//

import SwiftUI
import MapKit

@available(iOS 14.0, *)
struct MapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
    @ObservedObject var workoutProvider: WorkoutProvider
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.mapType = .satellite
        workoutProvider.drawRoute(mapView: map)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("inside updateuiview")
    }
    
    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }
    
}

final class Coordinator: NSObject, MKMapViewDelegate {
    
    var control: MapViewRepresentable
    
    init(_ control: MapViewRepresentable) {
        self.control = control
    }
    
    // MARK: - MapKit
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor(named: "Route")
            renderer.lineWidth = 5
            return renderer
        }

        return MKOverlayRenderer()
    }
}
