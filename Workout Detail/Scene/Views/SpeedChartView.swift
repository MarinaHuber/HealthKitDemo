//
//  SpeedChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 28.06.2021..
//https://github.com/AAChartModel/AAChartKit-Swift-Pro.git

import AAInfographics_Pro
import UIKit

class SpeedChartView: UIView {
    
    private var aaChartViewHR = AAChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
        self.getSpeed()
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
    
    private func getSpeed() {
        HealthManager.shared.getValueFromHealthKit(.speed) { [weak self] (speed, error) in
            guard let `self` = self else { return }
            self.configureChart(data: speed)
        }
    }
    
    private func configureChart(data: [Double]) {
        let aaChartModel = AAChartModel()
            .chartType(.areaspline)
            .title("m/sec")
            .animationType(.easeInQuint)
            .xAxisVisible(false)
           // .axesTextColor(AAColor.black)
            .legendEnabled(false)
            .margin(top: 10.0, right: 10.0, bottom: 20.0, left: 30.0)
            .series([
                AASeriesElement()
                    .color(AAColor.rgbaColor(223, 32, 32, 0.7)) // lineColor
                    .lineWidth(2.8)
                    .enableMouseTracking(false)
                    .zIndex(1)
                    .data(data)
            ])
        
        let aaOptions = AAOptionsConstructor.configureChartOptions(aaChartModel)
        // Y axis
        aaOptions.yAxis?
            .max(8).min(0)
            .allowDecimals(false)
            .lineWidth(0)
            .gridLineWidth(0)
            .alternateGridColor("#e6e6e6")
            .tickInterval(Float(8/4.0))
        aaOptions.yAxis?.labels(AALabels()
                                    .x(-30)
                                    .align(AAChartAlignType.left)
                                    .style(AAStyle()
                                            .color(AAColor.black)
                                            .fontWeight(AAChartFontWeightType.bold)
                                            .fontSize(14)
                                    )
                                )
        self.aaChartViewHR.aa_drawChartWithChartOptions(aaOptions)
    }
}
