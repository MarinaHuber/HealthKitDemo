//
//  SpeedChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 27.05.2021..
//

import UIKit
import PanModal

class ChartViewController: UIViewController {
    
    private let graphSegmentedControl = UISegmentedControl()
    private let graphView = UIView()
    private var workoutDistance: Double
    private var heartRate: Int
    
    init() {
        self.workoutDistance = 0.0
        self.heartRate = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupView()
        self.setupConstraints()
      //  self.setupGraphSegmentedControl()
    }
    
    //Todo:
    public func setup(model: Workout) {
        self.setupView()
        self.setupConstraints()
        
    }
    
    private func setupView() {
        self.view.addSubview(self.graphSegmentedControl)
        self.view.addSubview(self.graphView)
        self.graphSegmentedControl.backgroundColor = UIColor.gray
        self.graphView.backgroundColor = UIColor.green
    }
    
    private func setupConstraints() {
        self.graphSegmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(35)
        }
        self.graphView.snp.makeConstraints { (make) in
            make.top.equalTo(graphSegmentedControl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(graphSegmentedControl.snp.width)
            make.height.equalTo(180)
        }
    }
    
    private func setupGraphSegmentedControl() {
        self.graphSegmentedControl.tintColor = .black
        self.graphSegmentedControl.selectedSegmentTintColor = .systemGray4
        self.graphSegmentedControl.setTitle("Speed", forSegmentAt: 0)
        self.graphSegmentedControl.setTitle("Pace", forSegmentAt: 1)
        self.graphSegmentedControl.setTitle("Heart Rate", forSegmentAt: 2)

    }
}

extension ChartViewController: PanModalPresentable {

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(self.view.bounds.size.height / 3.0 * 2)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
}
