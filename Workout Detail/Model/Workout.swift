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
    let speed: Double //mps
    let course: Double?
}


//  "@lat": "52.286239464072",
//  "@lon": "-1.527538273376",
//  "ele": "53.889278",
//  "time": "2021-05-18T16:38:52.000Z",
//  "extensions": {
//    "TrackPointExtension": {
//      "hr": "87",
//      "speed": "2.518402",
//      "course": "80.731514",
//      "hAcc": "5.999685",
//      "vAcc": "2.400000"
//    }
//  }
//}
