//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var selectedIndex = -1 {
        didSet {
            indedx?.text = "\(selectedIndex)"
        }
    }
    var slicesNum = 7
    var diff = -1
    @IBOutlet weak var indedx: UILabel!
    @IBOutlet weak var pieView: Chart! {
        didSet {
            pieView.delegate = self
            pieView.dataSource = self
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


extension ViewController: ChartDataSource {
    
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
    
}

extension ViewController: ChartDelegate {
    
    // State not changing for the BezierPaths, probably need to make a shapeLayer from it rather than a context drawing instead.
    func didTapSlice(atIndex index: Int) {
        if selectedIndex == index {
            pieView.deSelectArc(atIndex: index)
            selectedIndex = -1
        } else {
            pieView.selectArc(atIndex: index)
            selectedIndex = index
        }
    }
    
//    func didRotateChart() {
//        print("Graph Rotated")
//    }
//
//    func maximumRadiusValue(forChart chart: Chart) -> CGFloat {
//        return pieView.bounds.width/2 - 50
//    }

}







