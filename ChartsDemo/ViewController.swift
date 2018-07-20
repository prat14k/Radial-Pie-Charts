//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var pieView: Chart! {
        didSet {
            pieView.delegate = self
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

}


extension ViewController: ChartDelegate {
    
    func circle(forChart chart: Chart, atIndex index: Int) -> ChartCircle {
        var chartCircle = ChartCircle(title: "\(20 * (index + 1))", titleColor: UIColor.white, lineColor: UIColor.white)
        chartCircle.lineDash = LineDash(length: CGFloat(20 / (index + 2)), gap: CGFloat(20 / (index + 2)))
        return chartCircle
    }
    
    func numberofConcentricCircles(forChart chart: Chart) -> Int {
        return 5
    }
    

    func numberOfSlices(forChart chart: Chart) -> Int {
        return 5
    }

    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice {
        let v: CGFloat = 0.4 + (index % 2 == 0 ? 0.3 : 0.1) + (index == 4 ? 0.2 : 0)
        var slice = ChartSlice(radiusMultiplier: v)
        slice.fillColor = UIColor.yellow.withAlphaComponent(0.3)
        slice.lineColor = UIColor.orange
        
        return slice
    }

//    func area(forChart chart: Chart) -> ChartArea {
//        let area = ChartArea()
//        area.scaleLinesCount = 5
//        area.lineColor = UIColor.gray
//        area.lineWidth = 1
//        area.selectedLineWidth = 4
//        return area
//    }

    func maximumRadiusValue(forChart chart: Chart) -> CGFloat {
        return pieView.bounds.width/2 - 10
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
