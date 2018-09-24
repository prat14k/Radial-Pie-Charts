
import UIKit

extension UIColor {
    
    convenience init(hexValue: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hexValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hexValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(hexValue & 0xFF)/255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

extension UIView {
    
    func createNAddTapGesture(action: Selector, target: Any) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
        return tap
    }
    
    func fadeOut(duration: TimeInterval = 0.3, delay: TimeInterval = 0, fromAlpha: CGFloat = 1, toAlpha: CGFloat = 0, completion: ((Bool) -> ())? = nil) {
        alpha = fromAlpha
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: { [weak self] in
            self?.alpha = toAlpha
        }) { (finished) in
            completion?(finished)
        }
    }
    
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0, fromAlpha: CGFloat = 0, toAlpha: CGFloat = 1, completion: ((Bool) -> ())? = nil) {
        alpha = fromAlpha
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: { [weak self] in
            self?.alpha = toAlpha
        }) { (finished) in
            completion?(finished)
        }
    }
    
    func rotateView(fromAngle startAngle: Double, toAngle endAngle: Float, duration: Double = 1, completion: (() -> ())? = nil) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.fromValue = startAngle
        animation.toValue = endAngle
        animation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock { completion?() }
        layer.add(animation, forKey: nil)
        CATransaction.commit()
    }
    
}

extension CAShapeLayer {
    
    convenience init(circle: Arc, frame: CGRect) {
        self.init()
        let circlePath = UIBezierPath(arcCenter: circle.center, radius: circle.radius, startAngle: circle.startAngle, endAngle: circle.endAngle, clockwise: circle.clockWise)
        
        self.frame = frame
        path = circlePath.cgPath
        lineWidth = circle.lineWidth
        strokeColor = circle.lineColor.cgColor
        fillColor = circle.fillColor.cgColor
        strokeStart = 0
        strokeEnd = 1
        lineDashPattern = (circle.lineDash != nil ? [circle.lineDash!.length, circle.lineDash!.gap] : nil) as [NSNumber]?
    }
    
}

extension CALayer {
    
    func animateLineWidth(startWidth: CGFloat, endWidth: CGFloat, duration: Double, delay: Double, keyPath: String? = nil) {
        let widthScaleAnimation = CABasicAnimation(keyPath: "lineWidth")
        widthScaleAnimation.beginTime = CACurrentMediaTime() + delay
        widthScaleAnimation.duration = duration
        widthScaleAnimation.fromValue = startWidth
        widthScaleAnimation.toValue = endWidth
        widthScaleAnimation.fillMode = kCAFillModeForwards
        widthScaleAnimation.isRemovedOnCompletion = false
        add(widthScaleAnimation, forKey: keyPath ?? widthScaleAnimation.keyPath)
    }
    
    func animateScaling(startScale: CGFloat, endScale: CGFloat, duration: Double, delay: Double, keyPath: String? = nil) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.beginTime = CACurrentMediaTime() + delay
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = startScale
        scaleAnimation.toValue = endScale
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.isRemovedOnCompletion = false
        add(scaleAnimation, forKey: keyPath ?? scaleAnimation.keyPath)
    }
    
    func fade(duration: CFTimeInterval = 1, delay: CFTimeInterval = 0, startAlpha: Float, endAlpha: Float, isInfinite: Bool = false, autoReverses: Bool = false, keyPath: String? = nil) {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = duration
        fadeAnimation.beginTime = CACurrentMediaTime() + delay
        fadeAnimation.fromValue = startAlpha
        fadeAnimation.toValue = endAlpha
        fadeAnimation.repeatCount = isInfinite ? Float.infinity : 0
        fadeAnimation.autoreverses = autoReverses
        fadeAnimation.fillMode = kCAFillModeForwards
        fadeAnimation.isRemovedOnCompletion = false
        add(fadeAnimation, forKey: keyPath ?? fadeAnimation.keyPath)
    }
    
    func rotateOnZAxis(duration: CFTimeInterval = 1, delay: CFTimeInterval = 0, fromDegree: Double = 0, toDegree: Double = (2 * Double.pi), completionHandler: (() -> ())? = nil) {
        CATransaction.begin()
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.duration = duration
        rotateAnimation.beginTime = CACurrentMediaTime() + delay
        rotateAnimation.fromValue = fromDegree
        rotateAnimation.toValue = toDegree
        rotateAnimation.fillMode = kCAFillModeForwards
        rotateAnimation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock { completionHandler?() }
        add(rotateAnimation, forKey: rotateAnimation.keyPath)
        CATransaction.commit()
    }
    
    func animateStrokeEnd(duration: CFTimeInterval = 1, delay: CFTimeInterval = 0, startValue: CGFloat = 0, endValue: CGFloat = 1, keyPath: String? = nil, completionHandler: (() -> ())? = nil) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = startValue
        animation.beginTime = CACurrentMediaTime() + delay
        animation.toValue = endValue
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false

        CATransaction.setCompletionBlock { completionHandler?() }
        add(animation, forKey: keyPath ?? animation.keyPath)
        CATransaction.commit()
    }
    
}

extension CALayer {
    
    private func setLayerBaseShadow(color: UIColor) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowRadius = 0
        shadowOpacity = 1
        shadowOffset = .zero
    }
    
    func presentGlowAnimation(withColor color: UIColor, maxSpreadDistance maxRadius: CGFloat, duration: CFTimeInterval, delay: CFTimeInterval = 0, autoReverses: Bool = false) {
        setLayerBaseShadow(color: color)
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = maxRadius
        glowAnimation.beginTime = CACurrentMediaTime() + delay
        glowAnimation.duration = duration
        glowAnimation.fillMode = kCAFillModeForwards
        glowAnimation.autoreverses = autoReverses
        glowAnimation.isRemovedOnCompletion = false
        add(glowAnimation, forKey: glowAnimation.keyPath)
    }
    
    func animateShadowOpacity(to newOpacity: Float, duration: CFTimeInterval, delay: CFTimeInterval = 0, autoReverses: Bool = false) {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = self.shadowOpacity
        animation.toValue = newOpacity
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.autoreverses = autoReverses
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: animation.keyPath)
    }
    
}

extension UILabel {
    
    func update(text newText: String? = nil, spacing: Double) {
        guard let mainString = newText ?? text ?? attributedText?.string, spacing > 0  else { return }
        var mutableAttributedString: NSMutableAttributedString
        if newText == nil && attributedText != nil {
            mutableAttributedString = NSMutableAttributedString(attributedString: attributedText!)
        } else {
            mutableAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: mainString))
        }
        mutableAttributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSRange(location: 0, length: mutableAttributedString.length))
        self.attributedText = mutableAttributedString
    }
    
}

extension CGFloat {
    
    func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
    
    func toDegree() -> CGFloat {
        return (self * (180 / CGFloat.pi)).truncatingRemainder(dividingBy: 360)
    }
    
}

extension CGPoint {
    
    func distanceFrom(point: CGPoint) -> CGFloat {
        return sqrt(pow((x - point.x), 2) + pow((y - point.y), 2))
    }
    
    func extendedAngle(center: CGPoint) -> CGFloat{
        let dx =  center.x - x
        let dy =  center.y - y
        let radians = (atan2(dy, dx) + CGFloat.pi)
        return radians.toDegree()
    }
    
}
