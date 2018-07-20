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
    
//    let data1 = PieChartDataEntry(value: 0)
//    let data2 = PieChartDataEntry(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    }

}


extension ViewController: ChartDelegate {
    
    func numberOfSlices(forChart chart: Chart) -> Int {
        return 5
    }
    
    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice {
        let slice = ChartSlice()
        slice.fillColor = UIColor.yellow
        slice.strokeColor = UIColor.orange
        slice.value = 0.4 + (index % 2 == 0 ? 0.3 : 0.1) + (index == 4 ? 0.2 : 0)
        return slice
    }
    
    func area(forChart chart: Chart) -> ChartArea {
        let area = ChartArea()
        area.scaleLinesCount = 5
        area.lineColor = UIColor.gray
        area.lineWidth = 1
        area.selectedLineWidth = 4
        return area
    }
    
    func maximumRadiusValue(forChart chart: Chart) -> CGFloat {
        return pieView.bounds.width/2 - 10
    }
    
}



















