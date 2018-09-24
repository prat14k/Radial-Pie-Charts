//
//  Chart.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/19/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


protocol ChartDataSource: class {
    func numberofConcentricCircles(forChart chart: Chart) -> Int
    func numberOfSlices(forChart chart: Chart) -> Int
    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice
    func circle(forChart chart: Chart, atIndex index: Int) -> ChartCircle
    func imageAsset(forDividerIndex: Int, chart: Chart) -> ImageAsset
}

@objc protocol ChartDelegate: class {
    @objc optional func maximumRadiusValue(forChart chart: Chart) -> CGFloat
    @objc optional func didTapSlice(atIndex index: Int, inChart chart: Chart)
}

class Chart: UIControl {
    
    private var backgroundArcsContainerView: UIView!
    private var arcsContainerView: UIView!
    
    private enum UIConstants {
        static let dividerImageSizeRatio: CGFloat = 30 / 1113
        static let avgPointImageSizeRatio: CGFloat = 90 / 1113
        static let curvedTitleTopSpaceRatio: CGFloat = 32 / 1113
        static let detailArcLineWidthRatio: CGFloat = 10.0 / 1113
        static let goodDetailArcColor = UIColor(hexValue: 0x228C10)
        static let badDetailArcColor = UIColor(hexValue: 0xA74343)
    }
    
    weak var dataSource: ChartDataSource?
    weak var delegate: ChartDelegate?
    
    var dividerLineWidth: CGFloat = 1
    var dividerLineColor: UIColor = .white
    var dividerLineDash: LineDash?
    
    private var slicesCount: Int = 0
    private var slices = [ChartSlice]()
    private var circlesCount: Int = 0
    private var chartCircles = [ChartCircle]()
    private var averagePointLineImages = [UIImageView]()
    private var maximumRadius: CGFloat = 0
    
    private var isInitialSetupCompleted = false
    
    private var backgroundSlices = [CAShapeLayer]()
    private var arcSlices = [CAShapeLayer]()
    private var detailViewArcs = [CAShapeLayer]()
    private var maskLayer: CAShapeLayer!
    
    var selectedSliceLineWidth: CGFloat?
    var selectedSliceLineColor: UIColor?
    var selectedSliceFillColor: UIColor?
    
    var deselectedStateFill: UIColor?
    
    var isTapGestureEnabled: Bool = true
    
    private(set) var selectedIndex: Int? {
        didSet {
            selectedIndex != nil ? delegate?.didTapSlice?(atIndex: selectedIndex!, inChart: self) : nil
        }
    }
    
    private var viewFrameCenter: CGPoint { return CGPoint(x: bounds.width / 2, y: bounds.height / 2) }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = createNAddTapGesture(action: #selector(handleTap(gesture:)), target: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = createNAddTapGesture(action: #selector(handleTap(gesture:)), target: self)
    }
    
}


extension Chart {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !isInitialSetupCompleted  else { return }
        reloadData()
        
        isInitialSetupCompleted = !isInitialSetupCompleted
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawCircles()
        drawSlices()
        drawLinesAndImages()
        setMasking(forLayer: arcsContainerView.layer)
    }
    
}


extension Chart {
    
    func reloadData() {
        averagePointLineImages.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setupGraph()
        
        fetchChartCircles()
        fetchChartSlices()
        
        if isInitialSetupCompleted {
            setNeedsDisplay()
        }
    }
    
    private func setupGraph() {
        arcSlices.removeAll()
        guard let circlesCount = dataSource?.numberofConcentricCircles(forChart: self),
            let slicesCount = dataSource?.numberOfSlices(forChart: self)
            else { return }
        
        let maximumRadius = delegate?.maximumRadiusValue?(forChart: self) ?? ((bounds.height / 2) - 50)
        
        if slicesCount < 0 || maximumRadius < 0 || circlesCount < 0  {
            breakExecution(message: "Negative values cannot be sent from the delegate methods")
        }
        
        self.circlesCount = circlesCount
        self.slicesCount = slicesCount
        self.maximumRadius = maximumRadius
    }
    
    private func fetchChartSlices() {
        slices.removeAll()
        guard let dataSource = dataSource, slicesCount > 0  else { return }
        for i in 0..<slicesCount {
            slices.append(dataSource.sliceArea(fromChart: self, atIndex: i))
        }
    }
    
    private func fetchChartCircles() {
        chartCircles.removeAll()
        guard let dataSource = dataSource, circlesCount > 0  else { return }
        for i in 0..<circlesCount {
            chartCircles.append(dataSource.circle(forChart: self, atIndex: i))
        }
    }
    
}


extension Chart {
    
    private func breakExecution(message: String) -> Never {
        fatalError(message)
    }
    
    private func createLabel(for graphLabel: GraphLabel) -> UILabel {
        let lbl = UILabel()
        lbl.text = graphLabel.text
        lbl.font = graphLabel.font
        lbl.sizeToFit()
        lbl.textColor = graphLabel.color
        lbl.update(spacing: graphLabel.spacing)
        return lbl
    }
    
    private func createImageView(withAsset asset: ImageAsset, center: CGPoint, imageNParentHeightRatio: CGFloat, aspectRatio: CGFloat) -> UIImageView {
        let imageHeight = imageNParentHeightRatio * bounds.height
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageHeight * aspectRatio, height: imageHeight))
        imageView.image = UIImage(asset: asset)
        imageView.contentMode = .scaleAspectFit
        imageView.center = center
        return imageView
    }
    
}


extension Chart {
    
    private func drawLinesAndImages() {
        
        guard slices.count > 0  else { return }
        
        let dividerLine = UIBezierPath()
        
        for index in 0..<slices.count {
            let sliceAngle = (2 * CGFloat.pi) / CGFloat(slices.count)
            let angle = CGFloat(index) * sliceAngle + ((2 * CGFloat.pi) * (3 / 4))
            
            var nextPoint = CGPoint.zero
            nextPoint.x = viewFrameCenter.x + maximumRadius * cos(angle)
            nextPoint.y = viewFrameCenter.y + maximumRadius * sin(angle)
            
            dividerLine.move(to: viewFrameCenter)
            dividerLine.addLine(to: nextPoint)
            
            guard let dividerImageAsset = dataSource?.imageAsset(forDividerIndex: index, chart: self)   else { continue }
            addDividerImage(asset: dividerImageAsset, atExtendedAngle: angle)
        }
        
        dividerLine.lineWidth = dividerLineWidth
        if let lineDash = dividerLineDash {
            dividerLine.setLineDash([lineDash.length, lineDash.gap], count: 2, phase: 0)
        }
        dividerLineColor.setStroke()
        dividerLine.stroke()
    }
    
    private func addDividerImage(asset: ImageAsset, atExtendedAngle angle: CGFloat) {
        let imageCenter = CGPoint(x: viewFrameCenter.x + (maximumRadius + 15) * cos(angle), y: viewFrameCenter.x + (maximumRadius + 15) * sin(angle))
        let imageView = createImageView(withAsset: asset, center: imageCenter, imageNParentHeightRatio: UIConstants.dividerImageSizeRatio, aspectRatio: 1)
        addSubview(imageView)
        imageView.transform = CGAffineTransform(rotationAngle: angle)
    }
    
}

extension Chart {
    
    private func drawCircles() {
        let concentricCirclesGap = maximumRadius / CGFloat(chartCircles.count)
        var currentRadius = concentricCirclesGap
        
        for chartCircle in chartCircles {
            
            drawCircle(withRadius: currentRadius, forChartCircle: chartCircle)
            addCircleTitleLabel(radius: currentRadius, graphLabel: chartCircle.graphLabel)
            
            currentRadius += concentricCirclesGap
        }
        
        maximumRadius = currentRadius - concentricCirclesGap
    }
    
    private func addCircleTitleLabel(radius: CGFloat, graphLabel: GraphLabel) {
        let lbl = createLabel(for: graphLabel)
        lbl.frame = CGRect(x: viewFrameCenter.x + 4, y: (viewFrameCenter.y - radius) + 4, width: lbl.frame.width, height: lbl.frame.height)
        lbl.font = graphLabel.font
        addSubview(lbl)
    }
    
    private func drawCircle(withRadius radius: CGFloat, forChartCircle chartCircle: ChartCircle) {
        let circle = UIBezierPath()
        circle.addArc(withCenter: viewFrameCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circle.close()
        
        circle.lineWidth = chartCircle.lineWidth
        
        if let lineDash = chartCircle.lineDash {
            circle.setLineDash([lineDash.length, lineDash.gap], count: 2, phase: 0)
        }
        
        chartCircle.lineColor.setStroke()
        circle.stroke()
        chartCircle.fillColor.setFill()
        circle.fill()
    }
    
}


extension Chart {
    
    private func setupArcContainerView() -> UIView {
        let superView = superview!
        
        let arcsContainerView = UIView(frame: bounds)
        arcsContainerView.backgroundColor = .clear
        superView.insertSubview(arcsContainerView, belowSubview: self)
        arcsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        superView.addConstraint(NSLayoutConstraint(item: arcsContainerView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        superView.addConstraint(NSLayoutConstraint(item: arcsContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        superView.addConstraint(NSLayoutConstraint(item: arcsContainerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        superView.addConstraint(NSLayoutConstraint(item: arcsContainerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        
        return arcsContainerView
    }
    
    private func drawSlices() {
        guard slices.count > 0  else { return }
        backgroundArcsContainerView = setupArcContainerView()
        arcsContainerView = setupArcContainerView()
        
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
        drawBackgroundArcs(forSlice: chartSlice, startAngle: startAngle, endAngle: endAngle, radius: maximumRadius - 5)
        drawArc(forSlice: chartSlice, startAngle: startAngle, endAngle: endAngle, radius: radius)
        drawTitle(forSlice: chartSlice, startAngle: startAngle, endAngle: endAngle)
        drawDetailViewArc(radius: radius, startAngle: startAngle, endAngle: endAngle, isAboveAvg: chartSlice.radiusMultiplier >= chartSlice.avgPointRadiusMultiplier)
        let angle = ((startAngle + endAngle) / 2).truncatingRemainder(dividingBy: CGFloat.pi * 2)
        addAverageIndicatorImage(radiusMultiplier: chartSlice.avgPointRadiusMultiplier, angle: angle, imageAsset: chartSlice.avgImageAsset)
    }
    
    private func drawDetailViewArc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, isAboveAvg: Bool) {
        let lineWidth = UIConstants.detailArcLineWidthRatio * bounds.width
        let lineColor = isAboveAvg ? UIConstants.goodDetailArcColor : UIConstants.badDetailArcColor
        let arc = Arc(center: viewFrameCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth, lineColor: lineColor)
        let arcLayer = CAShapeLayer(circle: arc, frame: bounds)
        layer.addSublayer(arcLayer)
        detailViewArcs.append(arcLayer)
        arcLayer.isHidden = true
    }
    
    private func addAverageIndicatorImage(radiusMultiplier: CGFloat, angle: CGFloat, imageAsset: ImageAsset) {
        let imageCenter = CGPoint(x: viewFrameCenter.x + (maximumRadius * radiusMultiplier) * cos(angle), y: viewFrameCenter.x + (maximumRadius * radiusMultiplier) * sin(angle))
        let imageView = createImageView(withAsset: imageAsset, center: imageCenter, imageNParentHeightRatio: UIConstants.avgPointImageSizeRatio, aspectRatio: 25 / 89)
        addSubview(imageView)
        imageView.transform = CGAffineTransform(rotationAngle: angle)
        averagePointLineImages.append(imageView)
    }
    
    private func drawBackgroundArcs(forSlice chartSlice: ChartSlice, startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat) {
        let arc = UIBezierPath()
        arc.move(to: viewFrameCenter)
        
        var nextPoint = CGPoint.zero
        
        nextPoint.x = viewFrameCenter.x + radius * cos(startAngle)
        nextPoint.y = viewFrameCenter.y + radius * sin(startAngle)
        
        arc.addLine(to: nextPoint)
        arc.addArc(withCenter: viewFrameCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        arc.addLine(to: viewFrameCenter)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor(hexValue: 0xE5FAFF, alpha: 0.13).cgColor
        shapeLayer.strokeColor = chartSlice.lineColor.cgColor
        shapeLayer.lineWidth = chartSlice.lineWidth
        shapeLayer.path = arc.cgPath
        
        backgroundArcsContainerView.layer.insertSublayer(shapeLayer, at: 0)
        backgroundSlices.append(shapeLayer)
    }
    
    private func drawArc(forSlice chartSlice: ChartSlice, startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat) {
        let arc = UIBezierPath()
        arc.move(to: viewFrameCenter)
        
        var nextPoint = CGPoint.zero
        
        nextPoint.x = viewFrameCenter.x + radius * cos(startAngle)
        nextPoint.y = viewFrameCenter.y + radius * sin(startAngle)
        
        arc.addLine(to: nextPoint)
        arc.addArc(withCenter: viewFrameCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        arc.addLine(to: viewFrameCenter)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = chartSlice.fillColor.cgColor
        shapeLayer.strokeColor = chartSlice.lineColor.cgColor
        shapeLayer.lineWidth = chartSlice.lineWidth
        shapeLayer.path = arc.cgPath
        
        arcsContainerView.layer.insertSublayer(shapeLayer, at: 0)
        arcSlices.append(shapeLayer)
    }
    
    private func drawTitle(forSlice chartSlice: ChartSlice, startAngle: CGFloat, endAngle: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext()  else { return }
        context.saveGState()
        
        let size = bounds.size
        context.translateBy (x: size.width / 2, y: size.height / 2)
        context.scaleBy (x: 1, y: -1)
        
        let centreAngle = ((startAngle + endAngle) / 2).truncatingRemainder(dividingBy: CGFloat.pi * 2)
        var direction: Bool = true
        if centreAngle >= 0 && centreAngle <= CGFloat.pi { direction = false }
        
        centreArcPerpendicular(graphLabel: chartSlice.graphLabel, context: context, radius: maximumRadius + (UIConstants.curvedTitleTopSpaceRatio * bounds.width), angle: -(startAngle + endAngle) / 2, clockwise: direction)
        
        context.restoreGState()
    }
    
}



extension Chart {
    
    private func setAvgPointImages(alpha: CGFloat) {
        for imageView in averagePointLineImages {
            imageView.alpha = alpha
        }
    }
    
    func setDetailGraphView(hidden: Bool) {
        detailViewArcs.forEach { $0.isHidden = hidden }
    }
    
}


extension Chart {
    
    func deSelectAllSlices(withFillColor fillColor: UIColor? = nil) {
        selectedIndex = nil
        guard slices.count > 0 else { return }
        for i in 0..<slices.count {
            deSelectArc(atIndex: i, fillColor: fillColor)
        }
        setAvgPointImages(alpha: 1)
    }
    
    func selectArc(atIndex index: Int) {
        guard index < slices.count, index >= 0  else { return }
        deSelectAllSlices(withFillColor: deselectedStateFill)
        setAvgPointImages(alpha: 0)
        
        let arc = arcSlices[index]
        let slice = slices[index]
        averagePointLineImages[index].alpha = 1
        arc.lineWidth = selectedSliceLineWidth ?? slice.lineWidth
        arc.strokeColor = (selectedSliceLineColor ?? slice.lineColor).cgColor
        arc.fillColor = (selectedSliceFillColor ?? slice.fillColor).cgColor
    }
    
    func deSelectArc(atIndex index: Int, fillColor: UIColor? = nil) {
        guard index < slices.count, index >= 0  else { return }
        let arc = arcSlices[index]
        let slice = slices[index]
        if index == selectedIndex { selectedIndex = nil }
        arc.lineWidth = slice.lineWidth
        arc.strokeColor = slice.lineColor.cgColor
        arc.fillColor = fillColor?.cgColor ?? slice.fillColor.cgColor
    }
    
}

extension Chart {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event)  else { return false }
        return point.distanceFrom(point: viewFrameCenter) < (bounds.width / 2)
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        guard isTapGestureEnabled  else { return }
        let tapPoint = gesture.location(in: self)
        let deltaAngle = (2 * CGFloat.pi) / CGFloat(slices.count)
        let extendedAngle = tapPoint.extendedAngle(center: viewFrameCenter)
        
        for index in 0..<slices.count {
            let startAngle = (CGFloat(index) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))).toDegree()
            let endAngle = (CGFloat(index + 1) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))).toDegree()
            
            if startAngle <= endAngle {
                if startAngle <= extendedAngle && endAngle >= extendedAngle {
                    selectedIndex = index
                    break
                }
            } else {
                if (startAngle <= extendedAngle && (2 * CGFloat.pi.toDegree()) >= extendedAngle) ||
                    (0 <= extendedAngle && endAngle >= extendedAngle) {
                    selectedIndex = index
                    break
                }
            }
        }
        
    }
    
}

extension Chart {
    
    func startPulsingSlice(atIndex index: Int) {
        guard index >= 0 && index < arcSlices.count  else { return }
        arcSlices[index].fade(duration: 1.6, startAlpha: 1, endAlpha: 0.3, isInfinite: true, autoReverses: true)
        detailViewArcs[index].fade(duration: 1.6, startAlpha: 1, endAlpha: 0.3, isInfinite: true, autoReverses: true)
        backgroundSlices[index].fade(duration: 1.6, startAlpha: 1, endAlpha: 0.0, isInfinite: true, autoReverses: true)
    }
    
    private func stopPulsing(atIndex index: Int) {
        guard index >= 0 && index < arcSlices.count  else { return }
        arcSlices[index].removeAllAnimations()
        detailViewArcs[index].removeAllAnimations()
        backgroundSlices[index].removeAllAnimations()
    }
    
    func startPulsingAllPriorities() {
        for i in 0..<arcSlices.count {
            startPulsingSlice(atIndex: i)
        }
    }
    
    func stopPulsingAllPriorities() {
        for i in 0..<arcSlices.count {
            stopPulsing(atIndex: i)
        }
    }
    
}

extension Chart {
    
    private func setMasking(forLayer layer: CALayer) {
        maskLayer = CAShapeLayer()
        maskLayer.frame = layer.bounds
        
        let circleRadius: CGFloat = layer.bounds.width / 2
        let circleHalfRadius = circleRadius * 0.5
        let circleBounds = CGRect(x: layer.bounds.midX - circleHalfRadius, y: layer.bounds.midY - circleHalfRadius, width: circleRadius, height: circleRadius)
        
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = circleRadius
        
        let path = UIBezierPath(roundedRect: circleBounds, cornerRadius: circleBounds.size.width * 0.5)
        maskLayer.path = path.cgPath
        maskLayer.strokeEnd = 0
        
        layer.mask = maskLayer
    }
    
    func startAnimatingArcs(duration: TimeInterval = 1) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        maskLayer.strokeEnd = 1.0
        maskLayer.add(animation, forKey: "strokeEnd")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) { [weak self] in
            self?.arcsContainerView.layer.mask = nil
        }
    }
    
}


// For Text Curving
extension Chart {
    
    private func centreArcPerpendicular(graphLabel: GraphLabel, context: CGContext, radius r: CGFloat, angle theta: CGFloat, clockwise: Bool){
        // *******************************************************
        // This draws the String str around an arc of radius r,
        // with the text centred at polar angle theta
        // *******************************************************
        
        let characters: [String] = graphLabel.text.map { String($0) } // An array of single character strings, each character in str
        let l = characters.count
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: graphLabel.font, NSAttributedStringKey.kern: graphLabel.spacing]
        
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
            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: graphLabel.color, font: graphLabel.font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }
    
    private func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
        /// bcoz the angle extended at the center is two times that of the top. Also, when extended to the diameter, it will be a 90 deg triangle for sure (traingle with diameter as a side incribed in a circle will always be a right triangle). So, sin can be calculated easily.
    }
    
    private func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(hexValue: 0x1b5663, alpha: 0.48)
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = CGSize(width: 3.5, height: -2.5)
        
        // Set the text attributes
        let attributes = [NSAttributedStringKey.foregroundColor: c, .font: font, .shadow: shadow]
        
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
    
}


