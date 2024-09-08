//
//  PaceChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 28.06.2021..
//
import AAInfographics_Pro
import UIKit
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
            .legendEnabled(false)
            .colorsTheme(["#04d69f"])  // Defines the color diagram style
            .stacking(.normal)
            .markerRadius(0)
            .margin(top: 10.0, right: 10.0, bottom: 20.0, left: 30.0)
            .series([
                // Defines the color diagram style
                AASeriesElement()
                    .lineWidth(1.5)
                    .fillOpacity(0.5)
                    .enableMouseTracking(false)
                    .zIndex(1)
                    .data(data)
            ])
        
        let aaOptions = AAOptionsConstructor.configureChartOptions(aaChartModel)
        // Y axis
        aaOptions.yAxis?
            .max(2).min(0)
            .allowDecimals(false)
            .lineWidth(0)
            .gridLineWidth(0)
            .alternateGridColor("#e6e6e6") // gray bg color grid horizontal
            .tickInterval(Float(1/1.0))
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
