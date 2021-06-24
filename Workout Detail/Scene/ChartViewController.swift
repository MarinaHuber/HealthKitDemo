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
    private var aaChartViewHR = AAChartView()
    private var aaChartViewSpeed = AAChartView()
    private var aaChartViewPace = AAChartView()
    private var workoutDistance: Double
    
    #warning("timeFormater to be used")
    private lazy var timeFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return formatter
    }()
    
    init() {
        self.workoutDistance = 0.0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGraphSegmentedControl()
        self.view.backgroundColor = .systemGray5
        self.getheartRate()
        self.getPace()
        self.setupView()
        self.setupConstraints()
    }
    
    private func setupView() {
        self.view.addSubview(self.graphSegmentedControl)
        self.view.addSubview(self.aaChartViewHR)
        self.graphSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupConstraints() {
        self.graphSegmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-50)
            make.height.equalTo(25)
        }
        self.aaChartViewHR.snp.makeConstraints { (make) in
            make.top.equalTo(graphSegmentedControl.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(graphSegmentedControl.snp.width)
            make.height.equalTo(180)
        }
    }
    
    private func updateSpeedChartConstraints() {
        self.aaChartViewSpeed.snp.updateConstraints { (make) in
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
        self.graphSegmentedControl.selectedSegmentTintColor = .green
        self.graphSegmentedControl.addTarget(self, action: #selector(graphDidChange(_:)), for: .valueChanged)
    }
    
    @objc func graphDidChange(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.aaChartViewHR.isHidden = false
            self.aaChartViewSpeed.isHidden = true
        case 1:
            #warning("TODO: chart separated for speed")
            self.aaChartViewHR.isHidden = true
            self.aaChartViewSpeed.isHidden = false
            self.view.addSubview(self.aaChartViewSpeed)
            self.updateSpeedChartConstraints()
            HealthManager.shared.getSpeedValueFromHealthkit { (speed, error) in
                self.configureChart(data: speed)
            }
        case 2:
            self.aaChartViewHR.isHidden = true
            self.aaChartViewSpeed.isHidden = true
        default:
            break
        }
    }
    
    private func getheartRate() {
        HealthManager.shared.getHRValueFromHealthkit { [weak self] (heartRates, error) in
            self?.configureChart(data: heartRates)
        }
    }
    
    private func getPace() {
        HealthManager.shared.getDistanceSum { (distance, error) in
            let miles = Measurement(value: distance, unit: UnitLength.miles)
            let km = miles.converted(to: UnitLength.kilometers)
            os_log("distance in KM::: \(km)")
        }
    }
    
    private func configureChart(data: [Double]) {
        let aaChartModel = AAChartModel()
            .chartType(.line)
            .animationType(.easeInQuint)
            .axesTextColor(AAColor.black)
            .legendEnabled(false)
            .margin(top: 10.0, right: 10.0, bottom: 20.0, left: 30.0)
            .series([
                AASeriesElement()
                    .type(.line)
                    .color(AAColor.rgbaColor(201,0,22,0.9)) // lineColor
                    .lineWidth(2.8)
                    .enableMouseTracking(false)
                    .zIndex(1)
                    .data(data)
                    .marker(AAMarker()
                                .lineWidth(3.5)
                                .lineColor(AAColor.red)
                                .states(AAMarkerStates()
                                            .hover(AAMarkerHover()
                                                    .enabled(false)))
                    )
            ])
        
        let aaOptions = AAOptionsConstructor.configureChartOptions(aaChartModel)
        // Y axis
        aaOptions.yAxis?
            .max(200).min(40)
            .allowDecimals(false)
            .lineWidth(0)
            .gridLineWidth(0)
            .alternateGridColor("#F9F9FA")
            .tickInterval(Float(200/10.0))
        aaOptions.yAxis?.labels(AALabels()
                                    .x(-30)
                                    .align(AAChartAlignType.left.rawValue)
                                    .style(AAStyle()
                                            .color(AAColor.black)
                                            .fontWeight(AAChartFontWeightType.bold)
                                            .fontSize(14)
                                    )
                                )
        // X axis
        aaOptions.xAxis?
            .labels(AALabels()
                        .y(25)
                        .x(-10)
                        .align(AAChartAlignType.left.rawValue)
                        .style(AAStyle()
                                            .color(AAColor.black)
                                            .fontWeight(AAChartFontWeightType.regular)
                                            .fontSize(13)))
             .categories(createXAxisLabels(["17:48 pm", "18:24 pm"]))
        self.aaChartViewHR.aa_drawChartWithChartOptions(aaOptions)
    }
    
    #warning("testing purpose use hardcoded values")
    func createXAxisLabels(_ labels: [String]) -> [String] {
        var array = [String]()
        array.append(labels.first ?? "")
        for _ in 0..<7808 - 2  {
            array.append("")
        }
        array.append(labels.last ?? "")
        return array
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
