//: Simple playground to demonstrate a spinner with a gradient background

import UIKit
import PlaygroundSupport
import Dispatch

let containerFrame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)
let containerView = UIView(frame: containerFrame)
containerView.backgroundColor = UIColor.white()
PlaygroundPage.current.liveView = containerView;
PlaygroundPage.current.needsIndefiniteExecution = true

let backgroundImageView = UIImageView(frame: containerFrame)
backgroundImageView.image = UIImage(named: "spinner_background")
backgroundImageView.alpha = 0.2
containerView.addSubview(backgroundImageView)

extension UIColor {
    convenience init(_ code: Int) {
        let red = CGFloat((code >> 16) & 0xFF) / 255.0
        let green = CGFloat((code >> 8) & 0xFF) / 255.0
        let blue = CGFloat(code & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

let gradientLayerWH : CGFloat = 200.0
let gradientLayerFrame = CGRect(
    x: (containerFrame.width-gradientLayerWH)/2.0,
    y: (containerFrame.height/2.0-gradientLayerWH)/2.0,
    width: gradientLayerWH,
    height: gradientLayerWH)

// angle of -40 degrees
let gradientAngle : CGFloat = (180.0-40.0)/CGFloat.pi
let yDelta : CGFloat = round(tan(gradientAngle) * gradientLayerWH)

let startColor : CGColor = UIColor(0x00a859).cgColor
let endColor : CGColor = UIColor(0x3e4095).cgColor
let gradientLayer = CAGradientLayer()
gradientLayer.colors = [startColor, endColor]
gradientLayer.startPoint = CGPoint(x: 0.0, y: (gradientLayerWH-yDelta)/gradientLayerWH)
gradientLayer.endPoint = CGPoint(x: 1.0, y: yDelta/gradientLayerWH)
gradientLayer.frame = gradientLayerFrame
gradientLayer.rasterizationScale = UIScreen.main().scale
gradientLayer.shouldRasterize = true

let strokeWidth : CGFloat = 14.0

let maskFrame = gradientLayer.bounds.insetBy(dx: strokeWidth, dy: strokeWidth)
let maskPath = UIBezierPath(arcCenter: CGPoint(x: strokeWidth + maskFrame.size.width/2.0, y: strokeWidth + maskFrame.size.height/2.0), radius: maskFrame.size.width/2.0, startAngle: -1.0 * (CGFloat.pi/2), endAngle: 3 * (CGFloat.pi/2), clockwise:true)
let maskLayer = CAShapeLayer()
maskLayer.path = maskPath.cgPath
maskLayer.strokeColor = UIColor.black().cgColor
maskLayer.lineWidth = strokeWidth
maskLayer.fillRule = kCAFillRuleEvenOdd
maskLayer.fillColor = UIColor.clear().cgColor

gradientLayer.mask = maskLayer

containerView.layer.addSublayer(gradientLayer)

class SpinnerAnimator : NSObject, CAAnimationDelegate {
    
    let spinnerAnimationKey = "spin"
    lazy var animationGroup : CAAnimationGroup = {
        let animationDuration : Double = 2.0
        
        let animateForward = CABasicAnimation(keyPath: "strokeStart")
        animateForward.fromValue = 0.0
        animateForward.toValue = 1.0
        animateForward.duration = animationDuration/2.0
        animateForward.isRemovedOnCompletion = false
        
        let animateBackward = CABasicAnimation(keyPath: "strokeEnd")
        animateBackward.fromValue = 0.0
        animateBackward.toValue = 1.0
        animateBackward.duration = animationDuration/2.0
        animateBackward.beginTime = animationDuration/2.0
        animateBackward.isRemovedOnCompletion = false
        
        let group = CAAnimationGroup()
        group.animations = [animateForward, animateBackward]
        group.duration = animationDuration
        group.isRemovedOnCompletion = false
        group.autoreverses = false
        group.fillMode = kCAFillModeForwards
        group.repeatCount = Float.infinity
        
        return group
    }()
    
    func startAnimating() {
        maskLayer.add(animationGroup, forKey:spinnerAnimationKey)
    }
    func stopAnimating() {
        maskLayer.removeAnimation(forKey: spinnerAnimationKey)
    }
    func animateForTime(_ seconds: Double) {
        let animationTime = DispatchTime.now() + seconds
        self.startAnimating()
        DispatchQueue.main.after(when: animationTime, execute: { self.stopAnimating() })
    }
}
let spinnerAnimator = SpinnerAnimator()
spinnerAnimator.startAnimating()

