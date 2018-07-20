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
    func area(forChart chart: Chart) -> ChartArea
    func maximumRadiusValue(forChart chart: Chart) -> CGFloat
}


class Chart: UIControl {
    
    weak var delegate: ChartDelegate?
    var selectedIndex: Int?
    
    private var maximumRadius: CGFloat = 0
    private var area: ChartArea?
    
    private var slicesArray = [ChartSlice]()
    private var slicesCount: Int = 0
    private var setupCompleted = false
    
    
    func setupGraph() {
        guard !setupCompleted  else { return }
        
        if delegate != nil {
            area = delegate?.area(forChart: self)
            slicesCount = delegate!.numberOfSlices(forChart: self)
            maximumRadius = delegate!.maximumRadiusValue(forChart: self)
            if slicesCount < 0 || maximumRadius < 0 {
                breakExecution(message: "Negative values cannot be returned")
            }
        }
        
        reloadData()
        setupCompleted = !setupCompleted
    }
    
    func breakExecution(message: String) -> Never {
        fatalError(message)
    }
    
//    var shapeLayer: CAShapeLayer?/
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupGraph()
        
//        if shapeLayer != nil {
//            shapeLayer?.removeFromSuperlayer()
//            shapeLayer = nil
//        }
//        drawArea()
    }

    
    func reloadData() {
        
        slicesArray.removeAll()

        guard let delegate = delegate, slicesCount > 0  else { return }
        for i in 0..<slicesCount {
            slicesArray.append(delegate.sliceArea(fromChart: self, atIndex: i))
        }
        
        if setupCompleted {
            setNeedsDisplay()
        }
        
    }
    
    
    func getNumberLabel(text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.sizeToFit()
        return lbl
    }
    
    
    func drawArea() {

        guard let area = area  else { return }
        
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        let circle = UIBezierPath(arcCenter: center, radius: maximumRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circle.lineWidth = area.lineWidth
        circle.close()
        
        area.lineColor.setStroke()
        circle.stroke()
        
        var yText = 50
        let lbl = getNumberLabel(text: "\(yText)")
        lbl.frame = CGRect(x: center.x + 2, y: (center.y - maximumRadius) + 2, width: lbl.frame.width, height: lbl.frame.height)
        addSubview(lbl)
        
        let scaleGapSize = maximumRadius / area.scaleLinesCount + 1
        var progress = scaleGapSize

        yText = 10
        
        while progress < maximumRadius {
            let innerCircle = UIBezierPath()
            innerCircle.lineWidth = area.lineWidth
            innerCircle.addArc(withCenter: center, radius: progress, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            innerCircle.close()

            area.lineColor.set()
            innerCircle.stroke()

            let lbl = getNumberLabel(text: "\(yText)")
            lbl.frame = CGRect(x: center.x + 4, y: (center.y - progress) + 4, width: lbl.frame.width, height: lbl.frame.height)
            addSubview(lbl)
            
            yText += 10
            
            progress += scaleGapSize

        }
        
    }
    
    
    func drawSlice(ofRedius radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, fillColor: UIColor?, strokeColor: UIColor?, lineWidth: CGFloat) {

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
        
        drawArea()
        
        for index in 0..<slicesArray.count {
            let slice = slicesArray[index]
            let sliceAngle = (2 * CGFloat.pi) / CGFloat(slicesArray.count)
            
            let startAngle = CGFloat(index) * sliceAngle + ((2 * CGFloat.pi) * (3 / 4))
            let endAngle = CGFloat(index + 1) * sliceAngle + ((2 * CGFloat.pi) * (3 / 4))
            
            let actualRadius = slice.value * maximumRadius
            
            drawSlice(ofRedius: actualRadius, startAngle: startAngle, endAngle: endAngle, fillColor: slice.fillColor, strokeColor: slice.strokeColor, lineWidth: area!.selectedLineWidth)
            
        }
        
    }
    
}






extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}



//        shapeLayer = CAShapeLayer()
//        shapeLayer?.path = circle.cgPath
//        shapeLayer?.lineWidth = area.lineWidth
//        shapeLayer?.strokeColor = area.lineColor.cgColor
//        shapeLayer?.fillColor = UIColor.clear.cgColor
//        layer.addSublayer(shapeLayer!)
