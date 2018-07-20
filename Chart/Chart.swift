//
//  Chart.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


protocol ChartDelegate: class {
    func numberOfSlices(forChart chart: Chart) -> Int
    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice
    func maximumRadiusValue(forChart chart: Chart) -> CGFloat
    
    func circle(forChart chart: Chart, atIndex index: Int) -> ChartCircle
    func numberofConcentricCircles(forChart chart: Chart) -> Int
}


class Chart: UIControl {
    
    weak var delegate: ChartDelegate?
    
    private var slicesCount: Int = 0
    private var circlesCount: Int = 0
    var chartCircles = [ChartCircle]()
    var slices = [ChartSlice]()
    
    private var maximumRadius: CGFloat = 0
    
    private var isInitialSetupCompleted = false
    
//    var selectedLineWidth: CGFloat = 4
//    var selectedIndex: Int?
    
    
    private func setupGraph() {
        guard !isInitialSetupCompleted  else { return }

        guard let circlesCount = delegate?.numberofConcentricCircles(forChart: self),
              let slicesCount = delegate?.numberOfSlices(forChart: self),
              let maximumRadius = delegate?.maximumRadiusValue(forChart: self)
        else { return }
            
        if slicesCount < 0 || maximumRadius < 0 || circlesCount < 0  {
            breakExecution(message: "Negative values cannot be sent from the delegate methods")
        }
        
        self.circlesCount = circlesCount
        self.slicesCount = slicesCount
        self.maximumRadius = maximumRadius
        
        reloadData()
        isInitialSetupCompleted = !isInitialSetupCompleted
    }
    
    private func breakExecution(message: String) -> Never {
        fatalError(message)
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupGraph()
    }

    private func fetchChartSlices() {
        slices.removeAll()
        guard let delegate = delegate, slicesCount > 0  else { return }
        for i in 0..<slicesCount {
            slices.append(delegate.sliceArea(fromChart: self, atIndex: i))
        }
    }
    
    private func fetchChartCircles() {
        chartCircles.removeAll()
        guard let delegate = delegate, circlesCount > 0  else { return }
        for i in 0..<circlesCount {
            chartCircles.append(delegate.circle(forChart: self, atIndex: i))
        }
    }
    
    func reloadData() {
        fetchChartCircles()
        fetchChartSlices()
        
        if isInitialSetupCompleted {
            setNeedsDisplay()
        }
    }
    
    
    private func getNumberLabel(text: String, color: UIColor) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.sizeToFit()
        lbl.textColor = color
        return lbl
    }
    
    private func drawChart() {
        drawCircles()
    }
    
    private func drawCircles() {
        
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        let concentricCirclesGap = maximumRadius / CGFloat(chartCircles.count)
        var currentRadius = concentricCirclesGap
        
        for chartCircle in chartCircles {
            let circle = UIBezierPath()
            circle.addArc(withCenter: center, radius: currentRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            circle.close()
            
            circle.lineWidth = chartCircle.lineWidth
            
            if let lineDash = chartCircle.lineDash {
                circle.setLineDash([lineDash.length, lineDash.gap], count: 2, phase: 0)
            }
            
            chartCircle.lineColor.setStroke()
            circle.stroke()
            chartCircle.fillColor.setFill()
            circle.fill()

            let lbl = getNumberLabel(text: chartCircle.title, color: chartCircle.titleColor)
            lbl.frame = CGRect(x: center.x + 4, y: (center.y - currentRadius) + 4, width: lbl.frame.width, height: lbl.frame.height)
            addSubview(lbl)
            
            currentRadius += concentricCirclesGap
        }
        
        maximumRadius = currentRadius - concentricCirclesGap
    }
    
    private func drawSlices() {
        
        for index in 0..<slices.count {
            let slice = slices[index]
            let deltaAngle = (2 * CGFloat.pi) / CGFloat(slices.count)

            let startAngle = CGFloat(index) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))
            let endAngle = CGFloat(index + 1) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))

            let actualRadius = slice.radiusMultiplier * maximumRadius

            drawSlice(ofRadius: actualRadius, startAngle: startAngle, endAngle: endAngle, fillColor: slice.fillColor, strokeColor: slice.lineColor, lineWidth: slice.lineWidth)
        }
        
    }
    
    
    private func drawSlice(ofRadius radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, fillColor: UIColor?, strokeColor: UIColor?, lineWidth: CGFloat) {

        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let arc = UIBezierPath()

        arc.lineWidth = lineWidth
        arc.move(to: center)

        var nextPoint = CGPoint.zero

        nextPoint.x = center.x + radius * cos(startAngle)
        nextPoint.y = center.y + radius * sin(startAngle)

        arc.addLine(to: nextPoint)
        arc.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        arc.addLine(to: center)

        fillColor?.setFill()
        arc.fill()

        strokeColor?.setStroke()
        arc.stroke()
    }

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("Draw REct Called")
        drawChart()
        drawSlices()
    }
    
}






//extension CGFloat {
//    func toRadians() -> CGFloat {
//        return self * CGFloat.pi / 180.0
//    }
//}
