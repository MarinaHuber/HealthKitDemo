

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
    private let store: HKHealthStore
    static let shared: HealthManager = { return HealthManager() }()
    
    private override init() {
        self.store = HKHealthStore()
        super.init()
    }
    
}


extension HealthManager: HealthDelegate {
    
    
    // MARK: - Authorisation
    
    #warning("check authorisation so it's not crashing when added to HK before")
    func requestAuthorization(completion: @escaping HealthAuthCompletionBlock) {
        guard HKHealthStore.isHealthDataAvailable() else {
            os_log("No data")
            completion(false, nil)
            return
        }
        
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
              let speed = HKObjectType.quantityType(forIdentifier: .walkingSpeed) else {
            fatalError("Index Type is no longer available in HealthKit")
        }
        let healthKitTypes: Set<HKSampleType> = [heartRate,
                                                 distance,
                                                 speed,
                                                 HKSeriesType.workoutRoute(),
                                                 HKObjectType.workoutType()]
        
        store.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (success, error) in
            guard success else {
                fatalError("An error occurred while requesting authorization: \(error!.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - Route & Distance
    func setRouteValueToHealthKit(for myRoute: [GPXLocation]) {
        var previousLocation: CLLocation?
        var totalDistance: Double = 0
        
        myRoute.forEach {
            
            let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.coordinates.coordinate.latitude, longitude: $0.coordinates.coordinate.longitude), altitude: $0.coordinates.altitude, horizontalAccuracy: $0.coordinates.horizontalAccuracy, verticalAccuracy: $0.coordinates.verticalAccuracy, timestamp: $0.startTime)
            
            if let previousLocation = previousLocation {
                let distance = location.distance(from: previousLocation)
                totalDistance += distance
                //here add distance to workout instance
                let quantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
                
                let sample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
                
                self.samples.append(sample)
                
            }
            self.arrayLocation.append(location)
            previousLocation = location
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
                            // We first add the samples to hkworkout instance.
                            self.store.add(samples, to: hkworkout, completion: { (finished, error) in })
                            // and than route
                            self.addRoute(to: hkworkout)
                        }
                    }
                }
            })
        }
        
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
                    os_log("Error \(error as NSObject)")
                    return
                }
                
                guard let locations = locationsOrNil else {
                    fatalError("*** NIL found in locations ***")
                }
                
                locations.forEach {
                    totalWorkouts.append($0)
                }
                if done {
                    DispatchQueue.main.async {
                        completion(totalWorkouts, nil)
                    }
                }
            }
            
            self.store.execute(query)
        }
        
        store.execute(routeQuery)
    }
    
    // MARK: - Heart rate
    func setHRValueToHealthKit(myHeartRate: [GPXLocation]) {
        var heartRate: Double = 0
        let unit = HKUnit(from: "count/min")
        
        myHeartRate.forEach {
            heartRate = $0.heartRate
            
            let quantity = HKQuantity(unit: unit, doubleValue: heartRate)
            let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            
            let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
            
            self.samples.append(heartRateSample)
            
            DispatchQueue.main.async {
                self.store.save(heartRateSample) { (finished, error) in
                    if !finished {
                        os_log("Error occured saving the HR sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(error! as NSObject).")
                    }
                    os_log("Saving the HR sample \(heartRateSample).")
                }
            }
        }
    }
    
    func getHRValueFromHealthkit(completion: @escaping (([Double], Error?) -> Void)) {
        #warning("check authorisation")
        var array = [Double]()
        guard let sampleType = HKObjectType
                .quantityType(forIdentifier: .heartRate) else {
            completion([], nil)
            return
        }
        let heartQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, heartRates, error) in
            
            guard let samples = heartRates as? [HKQuantitySample] else {
                return
            }
            for sample in samples {
                array.append(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
            DispatchQueue.main.async {
                completion(array, nil)
            }
        }
        self.store.execute(heartQuery)
        
    }

    // MARK: - Speed
    func setSpeedValueToHealthKit(myHeartRate: [GPXLocation]) {
        var speed: Double = 0
        let unit = HKUnit.meter().unitDivided(by: HKUnit.second())
        
        myHeartRate.forEach {
            speed = $0.speed
            
            let quantity = HKQuantity(unit: unit, doubleValue: speed)
            let type = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
            
            let speedSample = HKQuantitySample(type: type, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
            
            self.samples.append(speedSample)
            
            DispatchQueue.main.async {
                self.store.save(speedSample) { (finished, error) in
                    if !finished {
                        os_log("Error occured saving the HR sample \(speedSample). In your app, try to handle this gracefully. The error was: \(error! as NSObject).")
                    }
                    os_log("Saving the HR sample \(speedSample).")
                }
            }
        }
    }
    
    func getSpeedValueFromHealthkit(completion: @escaping (([Double], Error?) -> Void)) {
        #warning("check authorisation")
        var array = [Double]()
        guard let sampleType = HKObjectType
                .quantityType(forIdentifier: .walkingSpeed) else {
            completion([], nil)
            return
        }
        let heartQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, speed, error) in
            
            guard let samples = speed as? [HKQuantitySample] else {
                fatalError("*** NIL found in speed ***")
            }
            for sample in samples {
                array.append(sample.quantity.doubleValue(for: HKUnit.meter().unitDivided(by: HKUnit.second())))
            }
            DispatchQueue.main.async {
                completion(array, nil)
            }
        }
        self.store.execute(heartQuery)
        
    }
    
    
    // MARK: - Distance
    
    func getDistanceSum(completion: @escaping (Double, Error?) -> ()) {
        guard let sampleType = HKObjectType
                .quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0, nil)
            return
        }
        
        let statisticsSumQuery = HKStatisticsQuery(quantityType: sampleType,
                                                   quantitySamplePredicate: nil,
                                                   options: .cumulativeSum) {
            query, result, error in
            
            if result != nil {
                var total = 0.0
                
                if let quantity = result?.sumQuantity() {
                    let unit = HKUnit.meter()
                    total = quantity.doubleValue(for: unit)
                }
                
                DispatchQueue.main.async {
                    completion(total, nil)
                }
                
            }
        }
        self.store.execute(statisticsSumQuery)
    }
    
}

extension HealthManager {
    
    func addRoute(to workout: HKWorkout) {
        self.routeBuilder.finishRoute(with: workout, metadata: nil, completion: { workoutRoute, error in
            if workoutRoute == nil {
                fatalError("error saving workout route\(error.debugDescription)")
            }
        })
    }
}



//*****    in the pace: 6.52 minutes/km.

//  to get seconds to minutes 2,700 seconds x 0.0166 = 36 minutes
//
//    So, it takes you 6.52 minutes to run 1 km ("pace")

//use this to calculate pace distance % time = Pace per seconds



