//
//  Workout.swift
//  Workout Detail
//
//  Created by Marina Huber on 27.05.2021..
//

import CoreLocation

struct Workout {
    
#warning("Remove or rename GPXLocation")
    
  let locations: [GPXLocation]
}

public struct GPXLocation {
    let coordinates: CLLocation
    let startTime: Date
    let heartRate: Double
    let speed: Double
    let course: Double?
}
