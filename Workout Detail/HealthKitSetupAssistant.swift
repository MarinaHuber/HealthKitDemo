//
//  HealthKitSetupAssistant.swift
//  Workout Detail
//
//  Created by Marina Huber on 29.05.2021..
//

import Foundation

import HealthKit

class HealthKitSetupAssistant {
  
  private enum HealthkitSetupError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
  }
  
  class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
    
    //1. Check to see if HealthKit Is Available on this device
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(false, HealthkitSetupError.notAvailableOnDevice)
      return
    }
    //2. Prepare the data types that will interact with HealthKit

    //3. Prepare a list of types you want HealthKit to read and write
    let healthKitTypesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
    
    let healthKitTypesToRead: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!
       // HKObjectType.workoutType()
        ]
    
    //4. Request Authorization
    HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                         read: healthKitTypesToRead) { (success, error) in
        guard success else {
            // Handle errors here.
            fatalError("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
        }
      completion(success, error)
    }
  }
}

