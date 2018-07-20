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


    let title: String
    let titleColor: UIColor
    var lineDash: LineDash?
    
    let lineWidth: CGFloat
    let lineColor: UIColor
    let fillColor: UIColor
    
    
    
    
    init(title: String, titleColor: UIColor = UIColor.black, lineWidth: CGFloat = 1, lineColor: UIColor = UIColor.black, fillColor: UIColor = UIColor.clear) {
        self.title = title
        self.titleColor = titleColor
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.fillColor = fillColor
    }
    
}








//        float dashPattern[] = {5 * self.area.lineWidth, 5 * self.area.lineWidth}; //make your pattern here
//        [innerCircle setLineDash:dashPattern count:1 phase:1];


