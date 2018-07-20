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
        
        guard slices.count > 0  else { return }
        
        for index in 0..<slices.count {
            let slice = slices[index]
            let deltaAngle = (2 * CGFloat.pi) / CGFloat(slices.count)

            let startAngle = CGFloat(index) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))
            let endAngle = CGFloat(index + 1) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))

            let actualRadius = slice.radiusMultiplier * maximumRadius

            drawSlice(ofRadius: actualRadius, startAngle: startAngle, endAngle: endAngle, chartSlice: slice)
        }
        
    }
    
    
    private func drawSlice(ofRadius radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, chartSlice: ChartSlice) {
        
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let arc = UIBezierPath()
        
        arc.lineWidth = chartSlice.lineWidth
        arc.move(to: center)
        
        var nextPoint = CGPoint.zero
        
        nextPoint.x = center.x + radius * cos(startAngle)
        nextPoint.y = center.y + radius * sin(startAngle)
        
        arc.addLine(to: nextPoint)
        arc.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        arc.addLine(to: center)
        
        chartSlice.lineColor.setStroke()
        arc.stroke()
        
        chartSlice.fillColor.setFill()
        arc.fill()
        
        
        
        
        guard let context = UIGraphicsGetCurrentContext()  else { return }
        context.saveGState()
        
        let size = bounds.size
        context.translateBy (x: size.width / 2, y: size.height / 2)
        context.scaleBy (x: 1, y: -1)
        
        let centreAngle = ((startAngle + endAngle) / 2).truncatingRemainder(dividingBy: CGFloat.pi * 2)
        var direction: Bool = true
        if centreAngle >= (CGFloat.pi / 4) && centreAngle <= (CGFloat.pi * 3 / 4) { direction = false }
        
        centreArcPerpendicular(text: chartSlice.title, context: context, radius: maximumRadius + 15, angle: -(startAngle + endAngle) / 2, colour: UIColor.white, font: UIFont.systemFont(ofSize: 15), clockwise: direction)
        
        context.restoreGState()
    }


    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("Draw REct Called")
        drawChart()
        drawSlices()
    }
    
}


    func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool){
        // *******************************************************
        // This draws the String str around an arc of radius r,
        // with the text centred at polar angle theta
        // *******************************************************
        
        let characters: [String] = str.map { String($0) } // An array of single character strings, each character in str
        let l = characters.count
        let attributes = [NSAttributedStringKey.font: font]
        
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
        
        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: r)]
            totalArc += arcs[i]
        }
        
        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection: CGFloat = clockwise ? -.pi / 2 : .pi / 2
        
        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        var thetaI = theta - direction * totalArc / 2
        
        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            // Call centerText with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }
    
    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
        /// bcoz the angle extended at the center is two times that of the top. Also, when extended to the diameter, it will be a 90 deg triangle for sure (traingle with diameter as a side incribed in a circle will always be a right triangle). So, sin can be calculated easily.
    }
    
    func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************
        
        // Set the text attributes
        let attributes = [NSAttributedStringKey.foregroundColor: c, NSAttributedStringKey.font: font]
        //let attributes = [NSForegroundColorAttributeName: c, NSFontAttributeName: font]
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }






extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}
