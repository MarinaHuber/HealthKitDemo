//
//  WorkoutMapper.swift
//  Workout Detail
//
//  Created by Marina Huber on 29.05.2021..
//

import CoreGPX
import Foundation
import os
import HealthKit


enum WorkoutMapper {
    
    static func parseGPX() -> [GPXLocation] {
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
                       let heartRate = Double(heartRateString),
                       let speed = Double(speedString)
                    {
                        let gpxLocation = GPXLocation(coordinates: location, startTime: location.timestamp, heartRate: heartRate, speed: speed, course: nil)
                        locations.append(gpxLocation)
                    }
                }
            }
        }
        os_log("Finished reading data")
        return locations
    }

    
}
