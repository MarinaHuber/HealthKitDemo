//
//  WorkoutMapper.swift
//  Workout Detail
//
//  Created by Marina Huber on 29.05.2021..
//

import CoreGPX
import Foundation
import os


enum WorkoutMapper {
    
    static func parse() -> [GPXLocation] {
        var locations: [GPXLocation] = []
        guard let fileUrl = Bundle.main.url(forResource: "import", withExtension: "gpx") else {
            os_log("Could not find file", type: .error)
            return []
        }
        
        guard let gpx = GPXParser(withURL: fileUrl)?.parsedData() else {
            os_log("Could not parse file", type: .error)
            return []
        }
        
        for track in gpx.tracks {
            for segment in track.segments {
                for trackPoint in segment.points {
                    guard let location = trackPoint.coreLocation
                    else {
                        continue
                    }
                    
                    if let heartRateString = trackPoint.extensions?["gpxtpx:TrackPointExtension"]["gpxtpx:hr"].text,
                       let speedString = trackPoint.extensions?["gpxtpx:TrackPointExtension"]["gpxtpx:speed"].text,
                       let hrDouble = Int(heartRateString),
                       let speed = Double(speedString)
                    {
                        let gpxLocation = GPXLocation.init(coordinates: location, heartRate: hrDouble, speed: speed, course: nil)
                        locations.append(gpxLocation)
                    }
                }
            }
        }
        os_log("Finished reading data")
        return locations
    }
    
}
