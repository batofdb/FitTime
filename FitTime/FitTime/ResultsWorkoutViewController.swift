//
//  ResultsWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 9/30/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import HealthKit
import SwiftCharts


class ResultsWorkoutViewController: UIViewController {
    @IBOutlet weak var chartOverlay: ChartBaseView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    @IBOutlet weak var heartRateMaxLabel: UILabel!

    var observedHeartrateSamples: [HKQuantitySample]?
    var maxHeartRateBPM: Double = 0.0
    var minHeartRateBPM: Double = 0.0

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        if let hrs = observedHeartrateSamples {
            if let maxBPM = hrs.max(by: { (a, b) -> Bool in
                return a.bpm() > b.bpm()
            }) {
                maxHeartRateBPM = maxBPM.bpm()
            }

            if let minBPM = hrs.min(by: { (a, b) -> Bool in
                return a.bpm() < b.bpm()
            }) {
                minHeartRateBPM = minBPM.bpm()
            }

            heartRateMaxLabel.text = "Max HeartRate (BPM): \(maxHeartRateBPM)"

            setupResultsChart(with: hrs)
        }
    }

    func setupResultsChart(with samples: [HKQuantitySample]) {
        var range = maxHeartRateBPM - minHeartRateBPM
        var by: Double = 1.0
        if range > 0 {
            by = Double(range/6)
        }
        let elapsedTime = HealthManager.shared.endDate!.seconds(from: HealthManager.shared.startDate!)

        let chartFrame = CGRect(x: 0, y: 0, width: chartOverlay.frame.width, height: chartOverlay.frame.height)
        var start: (Double, Double) = (0, 0)
        var end: (Double, Double) = (0, 0)

        var plots: [(Double, Double)] = [(Double, Double)]()

        if let f = samples.first {
            start = (0, f.bpm())

            if let l = samples.last {
                end = (Double(elapsedTime), l.bpm())
            } else {
                end = (Double(elapsedTime), f.bpm())
            }
        }

        plots.append(start)
        for s in samples {
            let bpm = s.bpm()
            print("sample date: \(s.startDate), Health start:\(HealthManager.shared.startDate!)")
            let timestamp = s.startDate.seconds(from: HealthManager.shared.startDate!)
            let plot = (Double(timestamp), bpm)
            plots.append(plot)
        }
        plots.append(end)
        print("plots: \(plots)")

        // map model data to chart points
        let chartPoints: [ChartPoint] = plots.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}


        print("chart points: \(chartPoints)")
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        // define x and y axis values (quick-demo way, see other examples for generation based on chartpoints)
        let xValues = stride(from: 0.0, through: Double(elapsedTime), by: Double(elapsedTime)/6.0).map {ChartAxisValueDouble($0, labelSettings: labelSettings)}
        let yValues = stride(from: minHeartRateBPM - 2.0, through: maxHeartRateBPM + 2.0, by: 2).map {ChartAxisValueDouble($0, labelSettings: labelSettings)}


        // create axis models with axis values and axis title
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Elapsed Time(s)", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "HeartRate(BPM)", settings: labelSettings.defaultVertical()))

        // generate axes layers and calculate chart inner frame, based on the axis models
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

        // create layer with guidelines
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxis, yAxisLayer: yAxis, settings: guidelinesLayerSettings)


        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.purple, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, lineModels: [lineModel], pathGenerator: CatmullPathGenerator()) // || CubicLinePathGenerator

        // create layer that uses viewGenerator to display chartpoints
        let chartPointsLayer = ChartPointsLineLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, lineModels: [])


        // create chart instance with frame and layers


        let chart = Chart(view: self.chartOverlay,
                          settings: ExamplesDefaults.chartSettings,
                          layers: [coordsSpace.xAxisLayer,
                                   coordsSpace.yAxisLayer,
                                   guidelinesLayer,
                                   chartPointsLineLayer
                                ])


        self.chart = chart
//
//        let chart = LineChart(
//            frame: frame,
//            chartConfig: chartConfig,
//            xTitle: "Elapsed Time",
//            yTitle: "HeartRate (BPM)",
//            lines: [
//                (chartPoints: plots, color: UIColor.red)
//            ]
//        )
//
//        chartOverlay.addSubview(chart.view)
    }

}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}

struct ExamplesDefaults {
    static var chartSettings: ChartSettings {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return iPadChartSettings
        } else {
            return iPhoneChartSettings
        }
    }

    static var chartSettingsWithPanZoom: ChartSettings {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return iPadChartSettingsWithPanZoom
        } else {
            return iPhoneChartSettingsWithPanZoom
        }
    }

    fileprivate static var iPadChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        chartSettings.labelsSpacing = 0
        return chartSettings
    }

    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }

    fileprivate static var iPadChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPadChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }

    fileprivate static var iPhoneChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }

    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 70, width: containerBounds.size.width, height: containerBounds.size.height - 70)
    }

    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ExamplesDefaults.labelFont)
    }

    static var labelFont: UIFont {
        return UIDevice.current.userInterfaceIdiom == .pad ? fontWithSize(14) : fontWithSize(11)
    }

    static var labelFontSmall: UIFont {
        return UIDevice.current.userInterfaceIdiom == .pad ? fontWithSize(12) : fontWithSize(10)
    }

    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static var guidelinesWidth: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 0.1
    }

    static var minBarSpacing: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5
    }
}
