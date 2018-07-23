//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var slicesNum = 7
    var diff = -1
    @IBOutlet weak var pieView: Chart! {
        didSet {
            pieView.delegate = self
        }
    }
    
    @IBAction func hgh() {
        slicesNum = slicesNum + diff
        if slicesNum > 8 || slicesNum == 0 { diff *= -1 }
        pieView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

}


extension ViewController: ChartDelegate {
    
    func imageAsset(forDividerIndex: Int, chart: Chart) -> ImageAsset {
        return .diamond
    }
    
    func circle(forChart chart: Chart, atIndex index: Int) -> ChartCircle {
        let chartLabel = ChartLabel(text: "\(20 * (index + 1))", color: .white, font: UIFont.systemFont(ofSize: 14))
        var chartCircle = ChartCircle(chartLabel: chartLabel , lineColor: UIColor.white)
        chartCircle.lineDash = LineDash(length: CGFloat(20 / (index + 2)), gap: CGFloat(20 / (index + 2)))
        return chartCircle
    }
    
    func numberofConcentricCircles(forChart chart: Chart) -> Int {
        return 5
    }
    

    func numberOfSlices(forChart chart: Chart) -> Int {
        return slicesNum
    }

    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice {
        let v: CGFloat = 0.4 + (index % 2 == 0 ? 0.3 : 0.1) + (index == 4 ? 0.2 : 0)
        var slice = ChartSlice(radiusMultiplier: v, chartLabel: ChartLabel(text: "Hydration \(index)", color: .white, font: UIFont.systemFont(ofSize: 17)))
        slice.fillColor = UIColor.yellow.withAlphaComponent(0.3)
        slice.lineColor = UIColor.orange
        
        return slice
    }


    func maximumRadiusValue(forChart chart: Chart) -> CGFloat {
        return pieView.bounds.width/2 - 50
    }

}





















//    let data1 = PieChartDataEntry(value: 0)
//    let data2 = PieChartDataEntry(value: 0)


//        pieView.chartDescription?.text = ""
//
//
//        data1.label = "data 1"
//        data2.label = "data 2"
//        data1.value = 73
//        data2.value = 27
//
//        let set = PieChartDataSet(values: [data1, data2], label: nil)
//
//        set.colors = [UIColor.red, UIColor.blue] as! [NSUIColor]
//        let chartData = PieChartData(dataSet: set)
//
//        pieView.data = chartData
