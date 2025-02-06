

import Foundation
import HealthKit
import os
import CoreLocation

enum HealthValueType {
    case speed
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

extension HealthManager {
    
    private func getIdentifierForType(_ type: HealthValueType) -> HKQuantityTypeIdentifier {
        switch type {
        case .heartRate:
            return .heartRate
        case .speed:
            return .walkingSpeed
        }
    }
    
    private func getUnitForType(_ type: HealthValueType) -> HKUnit {
        switch type {
        case .heartRate:
            return HKUnit(from: "count/min")
        case .speed:
            return HKUnit.meter().unitDivided(by: HKUnit.second())
        }
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
        var totalDistance: Double = 0.0
        
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
//                if !inserted {
//                    fatalError("Error inserting locations: \(error.debugDescription)")
//                }
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
        var totalWorkouts: [CLLocation] = []
        
        let query = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samples, let _ = deletedObjectsOrNil else {
                #warning("Add alert for when notauthorized")
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }
            guard samples.count > 0 else {
                os_log("Error samples are 0")
                return
            }
            let route = samples.first as! HKWorkoutRoute
            
            let routeQuery = HKWorkoutRouteQuery(route: route) {
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
            
            self.store.execute(routeQuery)
        }
        
        self.store.execute(query)
    }
    
    // MARK: - Heart rate
    func setHRValueToHealthKit(_ type: HealthValueType, for model: [GPXLocation]) {
        var heartRate: Double = 0.0
        let unit = self.getUnitForType(type)
        guard let sampleType = HKObjectType.quantityType(forIdentifier: getIdentifierForType(type)) else {
            return
        }
        
        model.forEach {
            heartRate = $0.heartRate
            
            let quantity = HKQuantity(unit: unit, doubleValue: heartRate)
            
            let heartRateSample = HKQuantitySample(type: sampleType, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
            
            self.samples.append(heartRateSample)
            
            DispatchQueue.main.async {
                self.store.save(heartRateSample) { (finished, error) in
                    if !finished {
                        os_log("Error occured saving the HR sample \(heartRateSample).The error was: \(error! as NSObject).")
                    }
                    os_log("Saving the HR sample \(heartRateSample).")
                }
            }
        }
    }
    

    // MARK: - Speed
    func setValueToHealthKit(_ type: HealthValueType, for model: [GPXLocation]) {
        var speed: Double = 0.0
        let unit = self.getUnitForType(type)
        guard let sampleType = HKObjectType.quantityType(forIdentifier: getIdentifierForType(type)) else {
            return
        }
        
        model.forEach {
            speed = $0.speed
            
            let quantity = HKQuantity(unit: unit, doubleValue: speed)
            
            let speedSample = HKQuantitySample(type: sampleType, quantity: quantity, start: self.workoutList.first!.startTime, end: self.workoutList.last!.startTime)
            
            self.samples.append(speedSample)
            
            DispatchQueue.main.async {
                self.store.save(speedSample) { (finished, error) in
                    if !finished {
                        os_log("Error occured saving the HR sample \(speedSample). The error was: \(error! as NSObject).")
                    }
                    os_log("Saving the sample \(speedSample).")
                }
            }
        }
    }
    
    func getValueFromHealthKit(_ type: HealthValueType, completion: @escaping HealthGetValueCompletionBlock) {
        var array: [Double] = []
        guard let sampleType = HKObjectType.quantityType(forIdentifier: self.getIdentifierForType(type)) else {
            completion([], nil)
            return
        }
        let heartQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            (query, heartRates, error) in
            
            guard let samples = heartRates as? [HKQuantitySample] else {
                return
            }
            for sample in samples {
                array.append(sample.quantity.doubleValue(for: self.getUnitForType(type)))
            }
            DispatchQueue.main.async {
                completion(array, nil)
            }
        }
        self.store.execute(heartQuery)
        
    }
    
    
}

// MARK: - Route
extension HealthManager {
    
    func addRoute(to workout: HKWorkout) {
        self.routeBuilder.finishRoute(with: workout, metadata: nil, completion: { workoutRoute, error in
            if workoutRoute == nil {
                fatalError("error saving workout route\(error.debugDescription)")
            }
        })
    }
}
