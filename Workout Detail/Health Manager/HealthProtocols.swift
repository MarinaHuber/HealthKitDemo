

import Foundation
import HealthKit
import CoreLocation

typealias HealthAuthCompletionBlock = (_ success: Bool, _ error: Error?) -> ()
typealias HealthGetRouteCompletionBlock = ([CLLocation], Error?) -> ()
typealias HealthGetValueCompletionBlock = ([Double], Error?) -> ()

#warning("finish delegate methods if needed in return")
protocol HealthDelegate: class {
    func requestAuthorization(completion: @escaping HealthAuthCompletionBlock)
    func setRouteValueToHealthKit(for myRoute: [GPXLocation])
    func getRouteValueFromHealthKit(completion: @escaping HealthGetRouteCompletionBlock)
    func setValueToHealthKit(_ type: HealthValueType, for model: [GPXLocation])
    func getValueFromHealthKit(_ type: HealthValueType, completion: @escaping HealthGetValueCompletionBlock)
}
