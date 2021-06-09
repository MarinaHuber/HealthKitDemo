

import Foundation
import  HealthKit

typealias HealthAuthCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
typealias HealthGetValueCompletionBlock = (_ value: Double, _ success: Bool) -> Void
typealias HealthSetValueCompletionBlock = (_ value: HKWorkout, _ success: Bool) -> Void

protocol HealthDelegate: class {
    func requestAuthorization(completion: @escaping HealthAuthCompletionBlock)
    func getValueForType(_ type: HealthValueType, completion: @escaping HealthGetValueCompletionBlock)
}
