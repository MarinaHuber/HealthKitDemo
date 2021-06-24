

import Foundation
import HealthKit
import CoreLocation

typealias HealthAuthCompletionBlock = (_ success: Bool, _ error: Error?) -> ()
typealias HealthGetRouteCompletionBlock = ([CLLocation], Error?) -> ()
typealias HealthSetHRCompletionBlock = ([Double], Error?) -> ()

#warning("finish delegate methods")
protocol HealthDelegate: class {
    func requestAuthorization(completion: @escaping HealthAuthCompletionBlock)
    func setRouteValueToHealthKit(for myRoute: [GPXLocation])
    func getRouteValueFromHealthKit(completion: @escaping HealthGetRouteCompletionBlock)
    func setHRValueToHealthKit(myHeartRate: [GPXLocation])
    func getHRValueFromHealthkit(completion: @escaping HealthSetHRCompletionBlock)
}
