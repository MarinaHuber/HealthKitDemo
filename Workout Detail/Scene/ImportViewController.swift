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
import SwiftUI
import HealthKit

class ImportViewController: UIViewController {
    
    private let workoutList = WorkoutMapper.parseGPX()
    private var workoutHeartRate: Double = 0
    @ObservedObject var workoutProvider = WorkoutProvider()
    
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
        HealthManager.shared.setHRValueToHealthKit(.heartRate, for: model)
        HealthManager.shared.setValueToHealthKit(.speed, for: model)
    }
   
    @IBAction func showMap(_ sender: Any) {
        let mvc = MapViewController()
        // UIHostingController(rootView: MapScreen(workoutProvider: self.workoutProvider))
        mvc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(mvc, animated: true, completion: nil)
    }
}
