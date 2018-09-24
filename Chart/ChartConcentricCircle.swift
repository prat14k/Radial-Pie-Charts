//
//  ChartConcentricCircle.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/20/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


struct LineDash {
    var length: CGFloat
    var gap: CGFloat
}


struct ChartCircle {

    var graphLabel: GraphLabel
    var lineDash: LineDash?
    
    let lineWidth: CGFloat
    let lineColor: UIColor
    let fillColor: UIColor
    
    init(graphLabel: GraphLabel, lineWidth: CGFloat = 1, lineColor: UIColor = UIColor.black, fillColor: UIColor = UIColor.clear) {
        self.graphLabel = graphLabel
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.fillColor = fillColor
    }
    
}

