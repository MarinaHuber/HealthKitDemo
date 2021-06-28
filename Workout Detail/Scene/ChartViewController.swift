//
//  SpeedChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 27.05.2021..
//

import UIKit
import PanModal
import AAInfographics
import os

class ChartViewController: UIViewController {
    
    private var graphSegmentedControl = UISegmentedControl()

    private var heartChart = HeartRateChartView()
    private var speedChart = SpeedChartView()
    private var paceChart = PaceChartView()
    

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupGraphSegmentedControl()
        self.view.backgroundColor = .white
        self.setupView()
        self.setupConstraints()
        
    }
    
    private func setupView() {
        self.view.addSubview(self.graphSegmentedControl)
        self.view.addSubview(self.paceChart)
        self.view.addSubview(self.speedChart)
        self.view.addSubview(self.heartChart)
        
        self.graphSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupConstraints() {
        self.graphSegmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-50)
            make.height.equalTo(25)
        }
        self.heartChart.snp.makeConstraints { (make) in
            make.top.equalTo(graphSegmentedControl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(graphSegmentedControl.snp.width)
            make.height.equalTo(180)
        }
        self.speedChart.snp.makeConstraints { (make) in
            make.top.equalTo(graphSegmentedControl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(graphSegmentedControl.snp.width)
            make.height.equalTo(180)
        }
        self.paceChart.snp.makeConstraints { (make) in
            make.top.equalTo(graphSegmentedControl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(graphSegmentedControl.snp.width)
            make.height.equalTo(180)
        }
    }
    
    
    private func setupGraphSegmentedControl() {
        let items = ["Heart rate", "Speed", "Pace"]
        self.graphSegmentedControl = UISegmentedControl(items: items)
        self.graphSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.graphSegmentedControl.selectedSegmentTintColor = .systemBlue
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.graphSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        self.graphSegmentedControl.addTarget(self, action: #selector(graphDidChange(_:)), for: .valueChanged)
    }
    
    @objc func graphDidChange(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.heartChart.alpha = 1
            self.speedChart.alpha = 0
            self.paceChart.alpha = 0

        case 1:
            self.heartChart.alpha = 0
            self.speedChart.alpha = 1
            self.paceChart.alpha = 0

        case 2:
            self.heartChart.alpha = 0
            self.speedChart.alpha = 0
            self.paceChart.alpha = 1

        default:
            break
        }
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
