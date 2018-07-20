//
//  ChartSlice.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


struct ChartSlice {
    var radiusMultiplier: CGFloat
    var fillColor: UIColor = UIColor.clear
    var lineColor: UIColor = UIColor.black
    var lineWidth: CGFloat = 1
    var title: String
    
    init(title: String, radiusMultiplier: CGFloat, lineColor: UIColor = UIColor.black, lineWidth: CGFloat = 1, fillColor: UIColor = UIColor.clear) {
        
        self.title = title
        self.radiusMultiplier = radiusMultiplier
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
    }
    
}
