
import UIKit


struct Arc {
    
    let radius: CGFloat
    let center: CGPoint
    var startAngle: CGFloat
    var endAngle: CGFloat
    var clockWise: Bool
    var lineWidth: CGFloat
    var lineColor: UIColor
    var fillColor: UIColor
    var lineDash: LineDash?
    
    init(center: CGPoint, radius: CGFloat, startAngle: CGFloat = 0, endAngle: CGFloat = (CGFloat.pi * 2), clockWise: Bool = true, lineWidth: CGFloat = 1, lineColor: UIColor = .black, fillColor: UIColor = .clear) {
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockWise = clockWise
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.fillColor = fillColor
    }
    
}
