//
//  ViewController.swift
//  Workout Detail
//
//  Created by Lewis Smith on 20/05/2021.
//

import UIKit
import os
import CoreGPX
import CoreLocation
//import HealthKit

class ImportViewController: UIViewController {
    
    private let workoutList = WorkoutMapper.parseGPX()
    private var workoutHeartRate: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func importDataTapped(_ sender: UIButton) {
        self.authorizeHealthKit()
    }
    
    private func authorizeHealthKit() {
        HealthManager.shared.requestAuthorization { (success, error) in
            guard success else {
              let baseMessage = "HealthKit Authorization Failed"
              
              if let error = error {
                os_log("\(baseMessage). Reason: \(error.localizedDescription)")
              } else {
                print(baseMessage)
              }
              return
            }
            os_log("HealthKit Successfully Authorized. Begin workout")
            #warning("TODO: update healthkit authorisation")
                self.writeToHealthKit(from: self.workoutList)
        }
    }
    
    
    func writeToHealthKit(from model: [GPXLocation]) {
        HealthManager.shared.setRouteValueToHealthKit(for: model)
        HealthManager.shared.setHRValueToHealthKit(myHeartRate: model)
        HealthManager.shared.setSpeedValueToHealthKit(myHeartRate: model)
    }
   
    @IBAction func showMap(_ sender: Any) {
        let mvc = MapViewController()
        self.navigationController?.pushViewController(mvc, animated: true)
    }
}
