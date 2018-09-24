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
    var avgPointRadiusMultiplier: CGFloat
    var avgImageAsset: ImageAsset
    var fillColor: UIColor
    var lineColor: UIColor
    var lineWidth: CGFloat
    let graphLabel: GraphLabel
    
    init(radiusMultiplier: CGFloat, avgPointRadiusMultiplier: CGFloat, lineColor: UIColor = UIColor.black, lineWidth: CGFloat = 0.8, fillColor: UIColor = UIColor.clear, avgImageAsset: ImageAsset, graphLabel: GraphLabel) {
        self.graphLabel = graphLabel
        self.radiusMultiplier = radiusMultiplier
        self.avgPointRadiusMultiplier = avgPointRadiusMultiplier
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.avgImageAsset = avgImageAsset
    }
    
}
