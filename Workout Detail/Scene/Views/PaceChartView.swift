//
//  PaceChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 28.06.2021..
//

import UIKit
import AAInfographics
import os

class PaceChartView: UIView {
    
    private var aaChartViewHR = AAChartView()
    
    private var distance: Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
        self.getPace()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        self.addSubview(self.aaChartViewHR)
    }
    
    private func setupConstraints() {
        self.aaChartViewHR.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(180)
        }
    }
    
    private func getPace() {
        HealthManager.shared.getValueFromHealthKit(.speed) { [weak self] (speed, error) in
            guard let `self` = self else { return }
            let paceInSeconds = speed.map { 1 / $0 }
            self.configureChart(data: paceInSeconds)
        }
    }
    
    
    private func configureChart(data: [Double]) {
        let aaChartModel = AAChartModel()
            .chartType(.areaspline)
            .xAxisVisible(false)
            .animationType(.easeInQuint)
            .axesTextColor(AAColor.black)
            .legendEnabled(false)
            .margin(top: 10.0, right: 10.0, bottom: 20.0, left: 30.0)
            .series([
                AASeriesElement()
                    .color(AAColor.rgbaColor(233, 99, 99, 0.9)) // lineColor
                    .lineWidth(2.8)
                    .enableMouseTracking(false)
                    .zIndex(1)
                    .data(data)
            ])
        
        let aaOptions = AAOptionsConstructor.configureChartOptions(aaChartModel)
        // Y axis
        aaOptions.yAxis?
            .max(0.5).min(0)
            .allowDecimals(false)
            .lineWidth(0)
            .gridLineWidth(0)
        aaOptions.yAxis?.labels(AALabels()
                                    .x(-30)
                                    .align(AAChartAlignType.left.rawValue)
                                    .style(AAStyle()
                                            .color(AAColor.black)
                                            .fontWeight(AAChartFontWeightType.bold)
                                            .fontSize(14)
                                    )
                                )
        self.aaChartViewHR.aa_drawChartWithChartOptions(aaOptions)
    }
}
