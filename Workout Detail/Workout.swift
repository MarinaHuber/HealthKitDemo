//
//  Workout.swift
//  Workout Detail
//
//  Created by Marina Huber on 27.05.2021..
//

import Foundation

struct Workout {
  let locations: [GPXLocation]
}

public struct GPXLocation {
    let longitude: Double
    let latitude: Double
    let elevation: Double
    let timeStamp: Date
    let heartRate: Int
    let speed: Double //mps
    let course: Double?
}
