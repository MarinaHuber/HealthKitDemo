//
//  HeartRateChartView.swift
//  Workout Detail
//
//  Created by Marina Huber on 28.06.2021..
//
import AAInfographics_Pro
import UIKit


class HeartRateChartView: UIView {
    
    private var aaChartViewHR = AAChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
        self.getHeartRate()
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
    
    private func getHeartRate() {
        HealthManager.shared.getValueFromHealthKit(.heartRate) { [weak self] (heartRates, error) in
            guard let `self` = self else { return }
            self.configureChart(data: heartRates)
        }
    }
    
    private func configureChart(data: [Double]) {
        let aaChartModel = AAChartModel()
            .chartType(.areaspline)
            .animationType(.easeInQuint)
            .colorsTheme(["#ce0909"])  // Defines the color diagram style
            .stacking(.normal)
            .markerRadius(0)
            .legendEnabled(false)
            .margin(top: 10.0, right: 10.0, bottom: 20.0, left: 30.0)
            .series([
                AASeriesElement()
                // Defines the color diagram style
                    .lineWidth(1.5)
                    .fillOpacity(0.5)
                    .enableMouseTracking(false)
                    .zIndex(1)
                    .data(data)
            ])
        
        let aaOptions = AAOptionsConstructor.configureChartOptions(aaChartModel)
        // Y axis
        aaOptions.yAxis?
            .max(200).min(40)
            .allowDecimals(false)
            .lineWidth(0)
            .gridLineWidth(0)
            .alternateGridColor("#e6e6e6")
            .tickInterval(Float(200/10.0))
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
