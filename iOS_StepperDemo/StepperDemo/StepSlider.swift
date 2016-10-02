//
//  StepperSlider.swift
//  StepSlider
//
//  Created by BinaryBoy on 9/29/16.
//  Copyright © 2016 spromicky. All rights reserved.
//

import UIKit

@IBDesignable class StepSlider: UIControl {

    var trackLayer:CAShapeLayer!
    var sliderCircleLayer:CAShapeLayer!
    var trackCirclesArray:[CAShapeLayer]!
    
    var animateLayouts:Bool = false
    
    var maxRadius:CGFloat?
    var diff:CGFloat?
    
    var startTouchPosition:CGPoint?
    var startSliderPosition:CGPoint?
    
    

    
//    import UIKit
    
//    class StepSlider: UIControl {
        /**
         *  Maximum amount of dots in slider. Must be `2` or greater.
         */
    @IBInspectable var maxCount: Int = 4

        /**
         *  Currnet selected dot index.
         */
    @IBInspectable var index: Int = 2

        /**
         *  Height of the slider track.
         */
    @IBInspectable var trackHeight: Double = 4.0

        /**
         *  Radius of the default dots on slider track.
         */
    @IBInspectable var trackCircleRadius: Double = 5.0

        /**
         *  Radius of the slider main wheel.
         */
    @IBInspectable var sliderCircleRadius: Double = 12.5

        /**
         *  A Boolean value that determines whether user interaction with dots are ignored. Default value is `YES`.
         */
    @IBInspectable var dotsInteractionEnabled: Bool = true

        /**
         *  Color of the slider slider.
         */
    
    @IBInspectable var trackColor: UIColor = UIColor(white: 0.41, alpha: 1.0)

        /**
         *  Color og the slider main wheel.
         */
    @IBInspectable var sliderCircleColor: UIColor = UIColor.white

        /**
         *  Set the `index` property to parameter value.
         *
         *  @param index    The index, that you wanna to be selected.
         *  @param animated `YES` to animate changing of the `index` property.
         */
        
//        func setIndex(_ index: Int, animated: Bool) {
//        }
//    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.generalSetup()

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.addLayers()

    }
    
//    override init() {
//        super.init()
//        
//        self.generalSetup()
//        
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame)
//        self.generalSetup()
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//        self.addLayers()
//        
//    }
    
    func addLayers() {
        self.dotsInteractionEnabled = true
        self.trackCirclesArray = [Any]() as? [CAShapeLayer]
        self.trackLayer = CAShapeLayer()
        self.sliderCircleLayer = CAShapeLayer()
        self.layer.addSublayer(sliderCircleLayer!)
        self.layer.addSublayer(trackLayer!)
    }
    
    func generalSetup() {
        self.addLayers()
        self.maxCount = 4
        self.index = 2
        self.trackHeight = 4.0
        self.trackCircleRadius = 5.0
        self.sliderCircleRadius = 12.5
        self.trackColor = UIColor(white: 0.41, alpha: 1.0)
        self.sliderCircleColor = UIColor.white
        self.setNeedsLayout()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //hamdy
        animateLayouts = false
        layoutLayers(animateLayouts)

    }
    // MARK: - Helpers
    /*
     Calculate distance from trackCircle center to point where circle cross track line.
     */
    
    func updateDiff() {
        let value1 = self.trackHeight / 2.0
        diff = CGFloat(sqrtf(fmaxf(0.0, powf(Float(self.trackCircleRadius), 2.0) - powf(Float(value1), 2.0))))
    }
    
    func updateMaxRadius() {
        maxRadius = CGFloat(fmaxf(Float(self.trackCircleRadius), Float(self.sliderCircleRadius)))
    }
    
    func updateIndex() {
        assert(maxCount > 1, "_maxCount must be greater than 1!")
        if index > (maxCount - 1) {
            self.index = maxCount - 1
            self.sendActions(for: .valueChanged)
        }
    }
    
    func fillingPath() -> CGPath {
        var fillRect = trackLayer?.bounds
        fillRect?.size.width = self.sliderPosition()
        return UIBezierPath(rect: fillRect!).cgPath
    }
    
    func sliderPosition() -> CGFloat {
        return sliderCircleLayer!.position.x - maxRadius!
    }
    
    func trackCirclePosition(_ trackCircle: CAShapeLayer) -> CGFloat {
        return trackCircle.position.x - maxRadius!
    }
    
    func indexCalculate() -> CGFloat {
        let value1:CGFloat =   trackLayer!.bounds.size.width / CGFloat(self.maxCount - 1)
       let value2:CGFloat =    CGFloat(self.sliderPosition() / value1)
        
        return CGFloat(value2)
    }
    
    func trackCircleColor(_ trackCircle: CAShapeLayer) -> CGColor {
        

        
        return self.sliderPosition() + diff! >= self.trackCirclePosition(trackCircle) ? self.tintColor.cgColor : self.trackColor.cgColor
    }
    // MARK: - Touches

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool{
        startTouchPosition = touch.location(in: self)
        startSliderPosition = sliderCircleLayer?.position
        if self.dotsInteractionEnabled {
            for i in 0..<trackCirclesArray.count {
                let dot = trackCirclesArray[i]
                let dotRadiusDiff: CGFloat = CGFloat(22.0 - self.trackCircleRadius)
                let frameToCheck = dotRadiusDiff > 0 ? dot.frame.insetBy(dx: -dotRadiusDiff, dy: -dotRadiusDiff) : dot.frame
                if frameToCheck.contains(startTouchPosition!) {
                    let oldIndex = index
                    self.index = i
                    if oldIndex != index {
                        self.sendActions(for: .valueChanged)
                    }
                    animateLayouts = true
                    self.setNeedsLayout()
                    return false
                }
            }
            return false
        }
        else {
            return sliderCircleLayer!.frame.contains(startTouchPosition!)
        }
    }
    

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool{
        let position: CGFloat = startSliderPosition!.x - (startTouchPosition!.x - touch.location(in: self).x)
        
        let value1 = self.bounds.size.width - maxRadius!
        let limitedPosition: CGFloat = CGFloat(fminf(fmaxf(Float(Float(maxRadius!)), Float(position)),Float(value1)))
        withoutCAAnimation(code: {() -> Void in
            self.sliderCircleLayer?.position = CGPoint(x: limitedPosition, y: (sliderCircleLayer?.position.y)!)
            self.trackLayer?.path = self.fillingPath()
            
            let value2 = (trackLayer?.bounds.size.width)! / CGFloat(self.maxCount - 1)
            let index = (self.sliderPosition() + diff!) / value2
            if index != index {
                for trackCircle: CAShapeLayer in trackCirclesArray! {
                    trackCircle.fillColor = self.trackCircleColor(trackCircle)
                }
                self.index = Int(index)
                self.sendActions(for: .valueChanged)
            }
        })
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.endTouches()
    }
    override func cancelTracking(with event: UIEvent?) {
        self.endTouches()
    }
    
    func endTouches() {
        let newIndex = roundf(Float(Float(self.indexCalculate())))
        if newIndex != Float(index) {
            self.index = Int(newIndex)
            self.sendActions(for: .valueChanged)
        }
        animateLayouts = true
        self.setNeedsLayout()
    }
    // MARK: - Access methods
    
    func setIndex(_ index: Int, animated: Bool) {
        animateLayouts = animated
        self.index = Int(UInt(UInt(index)))
    }
    
    override var tintColor: UIColor!  {
        set{
            super.tintColor = newValue
            self.setNeedsLayout()
        }
        get{
            return super.tintColor
        }
    }

    func layoutLayers(_ animated: Bool) {
        let indexDiff = fabsf(roundf(Float(Float(self.indexCalculate()))) - Float(self.index))
        let left = (roundf(Float(Float(self.indexCalculate()))) - Float(self.index)) < 0
        let contentFrame = CGRect(x: maxRadius!, y: 0.0, width: self.bounds.size.width - 2 * maxRadius!, height: self.bounds.size.height)
        let stepWidth: CGFloat = contentFrame.size.width / CGFloat(self.maxCount - 1)
        let circleFrameSide: CGFloat = CGFloat(self.trackCircleRadius * 2.0)
        let sliderDiameter: CGFloat = CGFloat(self.sliderCircleRadius * 2.0)
        let sliderFrameSide: CGFloat = CGFloat(fmaxf(Float(CGFloat(self.sliderCircleRadius * 2.0)), 44.0))
        let sliderDrawRect = CGRect(x: (sliderFrameSide - sliderDiameter) / 2.0, y: (sliderFrameSide - sliderDiameter) / 2.0, width: sliderDiameter, height: sliderDiameter)
        let oldPosition = sliderCircleLayer?.position
        let oldPath = trackLayer?.path
        if !animated {
            CATransaction.begin()
            CATransaction.setValue((kCFBooleanTrue as Any), forKey: kCATransactionDisableActions)
        }
        self.sliderCircleLayer?.frame = CGRect(x: 0.0, y: 0.0, width: sliderFrameSide, height: sliderFrameSide)
        self.sliderCircleLayer?.path = UIBezierPath(roundedRect: sliderDrawRect, cornerRadius: sliderFrameSide / 2).cgPath
        self.sliderCircleLayer?.fillColor = self.sliderCircleColor.cgColor
        self.sliderCircleLayer?.position = CGPoint(x: contentFrame.origin.x + stepWidth * CGFloat(self.index), y: (contentFrame.size.height) / 2.0)
        
        if animated {
            let basicSliderAnimation = CABasicAnimation(keyPath: "position")
            basicSliderAnimation.duration = CATransaction.animationDuration()
            basicSliderAnimation.fromValue = oldPosition//NSValue(cgPoint:)
            sliderCircleLayer?.add(basicSliderAnimation, forKey: "position")
        }
        self.trackLayer?.frame = CGRect(x: contentFrame.origin.x, y: (CGFloat(contentFrame.size.height) - CGFloat(self.trackHeight)) / 2.0, width: contentFrame.size.width, height: CGFloat(self.trackHeight))
        self.trackLayer?.path = self.fillingPath()
        self.trackLayer?.backgroundColor = self.trackColor.cgColor
        self.trackLayer?.fillColor = self.tintColor.cgColor
        if animated {
            let basicTrackAnimation = CABasicAnimation(keyPath: "path")
            basicTrackAnimation.duration = CATransaction.animationDuration()
            basicTrackAnimation.fromValue = oldPath// ((oldPath) as! id, _Nullable)
            trackLayer?.add(basicTrackAnimation, forKey: "path")
        }
        if (trackCirclesArray?.count)! > self.maxCount {
            for i in self.maxCount..<(trackCirclesArray?.count)! {
                trackCirclesArray?[i].removeFromSuperlayer()
            }
            

            
        self.trackCirclesArray = Array(trackCirclesArray[0..<self.maxCount])

        }
        
        
        
        
        let animationTimeDiff = left ? CATransaction.animationDuration() / Double(indexDiff) : -CATransaction.animationDuration() / Double(indexDiff)
        var animationTime = left ? animationTimeDiff : CATransaction.animationDuration() + animationTimeDiff
        for i in 0..<self.maxCount {
            var trackCircle: CAShapeLayer!
            if i < (trackCirclesArray?.count)! {
                trackCircle = trackCirclesArray?[i]
            }
            else {
                trackCircle = CAShapeLayer()
                self.layer.addSublayer(trackCircle)
                trackCirclesArray.append(trackCircle)
            }
            trackCircle.frame = CGRect(x: 0.0, y: 0.0, width: circleFrameSide, height: circleFrameSide)
            trackCircle.path! = UIBezierPath(roundedRect: trackCircle.bounds, cornerRadius: circleFrameSide / 2).cgPath
            trackCircle.position = CGPoint(x: contentFrame.origin.x + stepWidth * CGFloat( i), y: contentFrame.size.height / 2.0)
            if animated {
                let newColor = self.trackCircleColor(trackCircle)
                let oldColor = trackCircle.fillColor
                if newColor != trackCircle.fillColor {
//                    dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(animationTime * NSEC_PER_SEC)),
                    
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    // your function here
                                    trackCircle.fillColor = newColor
                                    let basicTrackCircleAnimation = CABasicAnimation(keyPath: "fillColor")
                                    basicTrackCircleAnimation.duration = CATransaction.animationDuration() / 2.0
                                    basicTrackCircleAnimation.fromValue = oldColor
                                    trackCircle.add(basicTrackCircleAnimation, forKey: "fillColor")
                        }
                                   
                                   
                                   
//                                   DispatchQueue.main, {() -> Void in
//
//                    })
                    animationTime += animationTimeDiff
                }
            }
            else {
                trackCircle.fillColor = self.trackCircleColor(trackCircle)
            }
        }
        if !animated {
            CATransaction.commit()
        }
        sliderCircleLayer?.removeFromSuperlayer()
        self.layer.addSublayer(sliderCircleLayer!)

    }
    
//    typedef void (^withoutAnimationBlock)(void);
//    void withoutCAAnimation(withoutAnimationBlock code)
//    {
//    [CATransaction begin];
//    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
//    code();
//    [CATransaction commit];
//    }
    func withoutCAAnimation(code:()->()){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue as AnyObject, forKey: kCATransactionDisableActions)
        code()
        CATransaction.commit()
    }
    
    #define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
    - (void)SETTER:(TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
    _##PROPERTY = PROPERTY; \
    UPDATER \
    [self setNeedsLayout]; \
    } \
    }
}
