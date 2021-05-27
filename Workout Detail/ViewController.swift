//
//  ViewController.swift
//  Workout Detail
//
//  Created by Lewis Smith on 20/05/2021.
//

import UIKit
import os
import CoreGPX
import CoreLocation
import HealthKit

class ViewController: UIViewController {

    private let gpxService = GPXService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func importDataTapped(_ sender: UIButton) {
        guard let fileUrl = Bundle.main.url(forResource: "import", withExtension: "gpx") else {
            os_log("Could not find file", type: .error)
            return
        }
        
        guard let gpx = GPXParser(withURL: fileUrl)?.parsedData() else {
            os_log("Could not parse file", type: .error)
            return
        }
        
        var allLocations = [CLLocation]()
        var allHr = [Date: Int]()
        
        for track in gpx.tracks {
            for segment in track.segments {
                for trackPoint in segment.points {
                    guard let location = trackPoint.coreLocation
                    else {
                        os_log("Could not make location out of waypoint")
                        continue
                    }
                    allLocations.append(location)
                    //      let cgPoints = points.map { NSCoder.cgPoint(for: $0) }
                    //      let coords = cgPoints.map { CLLocationCoordinate2D(
                    //        latitude: CLLocationDegrees($0.x),
                    //        longitude: CLLocationDegrees($0.y))
                    //      }
                    //      let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
                    //
                    //      mapView.addOverlay(myPolyline)
                    
                    print("this are the trkpt coordinate: \(location.coordinate)")
                    
                    if let heartRateString = trackPoint.extensions?["gpxtpx:TrackPointExtension"]["gpxtpx:hr"].text,
                       let hrDouble = Int(heartRateString),
                       let date = trackPoint.time // UTC
                       {
                        allHr[date] = hrDouble
                        
                        print("Heart Rate: \(hrDouble)")
                    }
                }
            }
        }
        
        os_log("Finished reading data")
        
        // TODO: write to Apple Health!
        
       // 1. requestAuthorization
       // 2. convert location to HealthKit object
        //https://rowant.co.uk/importing-file-data/
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
           
        guard HKHealthStore.isHealthDataAvailable() else {
             // completion(false, HealthkitSetupError.notAvailableOnDevice)
              return
            }
           
        let healthKitTypesToWrite: Set<HKSampleType> = [
              HKObjectType.quantityType(forIdentifier: .heartRate)!,
              HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
              HKSeriesType.workoutRoute(),
              HKObjectType.workoutType()
            ]
        
        let healthKitTypesToRead: Set<HKSampleType> = [
              HKObjectType.quantityType(forIdentifier: .heartRate)!,
              HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
              HKSeriesType.workoutRoute(),
              HKObjectType.workoutType()
            ]
           
           
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            DispatchQueue.main.async {
                   // Handle Completion
                completion(success, error)
                 }
           }
       }
    
    @IBAction func showMap(_ sender: Any) {
        
        let mvc = MapViewController(gpxService: gpxService)
        self.navigationController?.pushViewController(mvc, animated: true)
    }
    
}
