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
import HealthKit

class ImportViewController: UIViewController {
    
    private let arrayWorkout = WorkoutMapper.parse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func importDataTapped(_ sender: UIButton) {
        self.authorizeHealthKit()
        self.writeToHealthKit(locations: arrayWorkout)
  }
    
    private func authorizeHealthKit() {
      
      HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
        
        guard authorized else {
          
          let baseMessage = "HealthKit Authorization Failed"
          
          if let error = error {
            os_log("\(baseMessage). Reason: \(error.localizedDescription)")
          } else {
            print(baseMessage)
          }
          
          return
        }
        
        os_log("HealthKit Successfully Authorized.")
      }
      
    }
    
    func writeToHealthKit(locations: [GPXLocation]) {
        //TODO: write to heathkit
    } 
    
    @IBAction func showMap(_ sender: Any) {
        let mvc = MapViewController()
        self.navigationController?.pushViewController(mvc, animated: true)
    }
    
}
