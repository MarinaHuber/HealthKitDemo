

import Foundation
import HealthKit
import os
import CoreLocation

enum HealthValueType {
    case distance
    case heartRate
}

class HealthManager: NSObject {
    
    private let workoutList = WorkoutMapper.parseGPX()
    private var samples: [HKQuantitySample] = []
    private var arrayLocation: [CLLocation] = []
    private let routeBuilder = HKWorkoutRouteBuilder(healthStore: HKHealthStore(), device: nil)
    static let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    let store: HKHealthStore
    static let shared: HealthManager = { return HealthManager() }()
    
    private override init() {
        self.store = HKHealthStore()
        super.init()
    }

}


extension HealthManager {
    #warning("todo: check if authorised always")
    
    func requestAuthorization(completion: @escaping HealthAuthCompletionBlock) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Index Type is no longer available in HealthKit")
        }
        let healthKitTypes: Set<HKSampleType> = [heartRate,
                                                 distance,
                                                 HKSeriesType.workoutRoute(),
                                                 HKObjectType.workoutType()]
        
        store.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (success, error) in
            guard success else {
                fatalError("An error occurred while requesting authorization: \(error!.localizedDescription)")
            }
            completion(success, error)
        }
    }
     
    func setRouteValueToHealthKit(myRoute: [GPXLocation]) {
        var previousLocation: CLLocation?
        var totalDistance: Double = 0
        
        myRoute.forEach {
            
            let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.coordinates.coordinate.latitude, longitude: $0.coordinates.coordinate.longitude), altitude: -1, horizontalAccuracy: -1, verticalAccuracy: -1, timestamp: $0.startTime)
            
            if let previousLocation = previousLocation {
                let distance = location.distance(from: previousLocation)
                totalDistance += distance
            }
            self.arrayLocation.append(location)
        }
        
        let newDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: totalDistance)
        let hkworkout = HKWorkout(activityType: .other,
                                  start: self.workoutList.first!.startTime,
                                  end: self.workoutList.last!.startTime,
                                  workoutEvents: nil,
                                  totalEnergyBurned: nil,
                                  totalDistance: newDistance,
                                  device: nil,
                                  metadata: nil)
        
        if !self.arrayLocation.isEmpty {
            self.routeBuilder.insertRouteData(self.arrayLocation, completion: { (inserted, error) in
                if !inserted {
                    fatalError("Error inserting locations: \(error.debugDescription)")
                }
                DispatchQueue.main.async {
                    self.store.save(hkworkout) { [self] (finished, error) in
                        if finished {
                            self.addRoute(to: hkworkout)
                        }
                    }
                }
            })
        }

    }
    
    
     func addRoute(to workout: HKWorkout) {
            self.routeBuilder.finishRoute(with: workout, metadata: nil, completion: { workoutRoute, error in
            if workoutRoute == nil {
                fatalError("error saving workout route\(error.debugDescription)")
            }
        })
    }

    func getRouteValueFromHealthKit(completion: @escaping (([CLLocation], Error?) -> Void)) {
        var totalWorkouts = [CLLocation]()
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samples, let _ = deletedObjectsOrNil else {
                            fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
                                            }
                    guard samples.count > 0 else {
                        return
                    }
            let route = samples.first as! HKWorkoutRoute

            let query = HKWorkoutRouteQuery(route: route) {
                (query, locationsOrNil, done, errorOrNil) in
                    if let error = errorOrNil {
                        os_log("Error", type: .error)
                        return
                    }

                    guard let locations = locationsOrNil else {
                        fatalError("*** NIL found in locations ***")
                    }
                
                locations.forEach {
                    totalWorkouts.append($0)
                }
                if done {
                    completion(totalWorkouts, nil)
                }
            }
        
        self.store.execute(query)
       }
        
        store.execute(routeQuery)
    }
    

}


#warning("to do for charts query and samples")


//********
//func addSamples(toWorkout workout: HKWorkout, from startDate: Date, to endDate: Date, heartRate heartRateValue: Double) {
//    let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
//    let quantity = HKQuantity(unit: unit, doubleValue: heartRateValue)
//    let heartRate = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
//                                     quantity: quantity,
//                                                   start: startDate,
//                                                   end: endDate)
//
//    self.samples.append(heartRate)
//
//    // Add samples to workout
//    self.store.add(self.samples, to: workout) { (success: Bool, error: Error?) in
//        guard success else {
//            print("Adding workout subsamples failed with error: \(String(describing: error))")
//            return
//        }
//    }
//}
//
//
//func getHearRate() {
//    var samples: [HKQuantitySample] = []
//    self.workoutList.forEach {
//        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: $0.heartRate)
//
//        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
//
//        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: self.workoutList.first!.startTime, end: workoutList.last!.startTime)
//
//
//        samples.append(heartRateSample)
//    }
//}
//
//
//
//func testSaveHeartRate(heartRate heartRateValue: Double, completion completionBlock: @escaping HealthAuthCompletionBlock) {
//    let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
//    let quantity = HKQuantity(unit: unit, doubleValue: heartRateValue)
//    let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//
//    let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
//
//    self.store.save(heartRateSample) { (success, error) -> Void in
//        if !success {
//            print("Error occured saving the HR sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(error).")
//        }
//       // print("Saving the HR sample \(heartRateSample).")
//        completionBlock(success, error)
//        let hkworkout = HKWorkout(activityType: .paddleSports, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime, workoutEvents: nil, totalEnergyBurned: nil, totalDistance:  nil, device: nil, metadata: nil)
//        self.addSamples(toWorkout: hkworkout, from: self.workoutList.first!.startTime, to: self.workoutList.last!.startTime, heartRate: heartRateValue)
//
//    }
//}
//
//
//func testStatisticsCollectionQuery() {
//    let calendar = NSCalendar.current
//
//    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
//
//    let offset = (7 + anchorComponents.weekday! - 2) % 7
//
//    anchorComponents.day! -= offset
//    anchorComponents.hour = 2
//
//    guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
//        fatalError("*** unable to create a valid date from the given components ***")
//    }
//
//    let interval = NSDateComponents()
//    interval.minute = 30
//
//    let endDate = Date()
//
//    guard let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
//        fatalError("*** Unable to calculate the start date ***")
//    }
//
//    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
//        fatalError("*** Unable to create a step count type ***")
//    }
//
//    let query = HKStatisticsCollectionQuery(quantityType: quantityType,
//                                            quantitySamplePredicate: nil,
//                                                options: .discreteAverage,
//                                                anchorDate: anchorDate,
//                                                intervalComponents: interval as DateComponents)
//
//    query.initialResultsHandler = {
//        query, results, error in
//
//        guard let statsCollection = results else {
//            fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
//
//        }
//
//        statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
//            if let quantity = statistics.averageQuantity() {
//                let date = statistics.startDate
//                //for: E.g. for steps it's HKUnit.count()
//                let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
//                print("done")
//                print(value)
//                print(date)
//
//            }
//        }
//
//    }
//
//    self.store.execute(query)
//}
