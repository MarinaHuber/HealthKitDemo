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

class ViewController: UIViewController {

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
        var allHr = [Date: Double]()
        
        for track in gpx.tracks {
            for segment in track.segments {
                for trackPoint in segment.points {
                    guard let location = trackPoint.coreLocation
                    else {
                        os_log("Could not make location out of waypoint")
                        continue
                    }
                    
                    allLocations.append(location)
                    
                    if let heartRateString = trackPoint.extensions?["gpxtpx:TrackPointExtension"]["gpxtpx:hr"].text,
                       let hrDouble = Double(heartRateString),
                       let date = trackPoint.time
                       {
                        allHr[date] = hrDouble
                    }
                }
            }
        }
        
        os_log("Finished reading data")
        
        // TODO: write to Apple Health!
    }
    
}
