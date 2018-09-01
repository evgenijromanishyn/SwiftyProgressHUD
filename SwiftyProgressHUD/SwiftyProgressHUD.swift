//
//  SwiftyProgressHUD.swift
//  SwiftyProgressHUD
//
//  Created by Evgeniy Romanishin on 01.09.2018.
//  Copyright © 2018 Evgeniy Romanishin. All rights reserved.
//

import UIKit

struct ProgressConstants{
    
    static let DefaultPadding = CGFloat(4.0)
    
    static let DefaultLabelFontSize = CGFloat(16.0)
    
    static let DefaultDetailsLabelFontSize = CGFloat(12.0)
    
    static let DefaultContentColor = UIColor(white: 0, alpha: 0.7)
}

//MARK: - Extension

extension UIView {
    public var progressHUD: SwiftyProgressHUD? {
        get {
            return SwiftyProgressHUD.HUDForView(self)
        }
    }
    
    public var isContainsHUD: Bool {
        get {
            return SwiftyProgressHUD.isContainsHUD(self)
        }
    }
    
    public var showHUD: Bool {
        get {
            return isContainsHUD
        } set {
            if newValue {
                if isContainsHUD {
                    return
                }
                
                SwiftyProgressHUD.showInView(self, animated: true)
            } else {
                SwiftyProgressHUD.hide(self, animated: true)
            }
        }
    }
}

public class SwiftyProgressHUD: UIView {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let circleProgress = CircleProgressHUD()
    
    let backgroundView = UIView()
    let bezelView = UIView()
    
    let textLabel = UILabel()
    let detailTextLabel = UILabel()
    
    var text:String? {
        get {
            return textLabel.text
        } set {
            textLabel.text = newValue
            layoutSubviews()
        }
    }
    
    var detailText:String? {
        get {
            return detailTextLabel.text
        } set {
            detailTextLabel.text = newValue
            layoutSubviews()
        }
    }
    
    var progress: CGFloat {
        get {
            return circleProgress.progress
        } set {
            if circleProgress.progress == newValue {
                return
            }
            
            if newValue == 0.0 {
                activityIndicator.isHidden = false
                circleProgress.isHidden = true
            } else {
                activityIndicator.isHidden = true
                circleProgress.isHidden = false
                
                var newProgress = newValue
                
                if newProgress > 1.0 {
                    newProgress = 1.0
                }
                
                circleProgress.progress = newProgress
            }
        }
    }
    
    public class func showInView(_ view : UIView, animated : Bool) {
        let hud = SwiftyProgressHUD()
        view.addSubview(hud)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                hud.alpha = 1
            }
        } else {
            hud.alpha = 1
        }
    }
    
    public class func hide(_ view : UIView, animated : Bool) {
        let hud = SwiftyProgressHUD.HUDForView(view)
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                hud?.alpha = 0
            }, completion: { (completed) in
                hud?.removeFromSuperview()
            })
        } else {
            hud?.removeFromSuperview()
        }
    }
    
    public class func HUDForView(_ view : UIView) -> SwiftyProgressHUD? {
        for subView in view.subviews {
            if subView is SwiftyProgressHUD {
                return subView as? SwiftyProgressHUD
            }
        }
        
        return nil
    }
    
    public class func isContainsHUD(_ view : UIView) -> Bool {
        let swiftHUD = SwiftyProgressHUD.HUDForView(view)
        if swiftHUD == nil {
            return false
        }
        
        return true
    }
    
    // MARK: - Init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupHUD()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setupHUD()
    }
    
    func setupHUD() {
        isOpaque = false
        backgroundColor = UIColor.clear
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(backgroundView)
        addSubview(bezelView)
        addSubview(textLabel)
        addSubview(detailTextLabel)
        addSubview(activityIndicator)
        addSubview(circleProgress)
        
        activityIndicator.color = UIColor.darkGray
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bezelView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bezelView.layer.allowsGroupOpacity = false
        bezelView.addSubview(blurEffectView)
        
        bezelView.backgroundColor = UIColor(white: 0.8, alpha: 0.6)
        bezelView.translatesAutoresizingMaskIntoConstraints = false
        bezelView.layer.cornerRadius = 5
        bezelView.clipsToBounds = true
        
        textLabel.textAlignment = .center
        textLabel.textColor = ProgressConstants.DefaultContentColor
        textLabel.font = UIFont.boldSystemFont(ofSize: ProgressConstants.DefaultLabelFontSize)
        
        detailTextLabel.numberOfLines = 0
        detailTextLabel.textAlignment = .center
        detailTextLabel.textColor = ProgressConstants.DefaultContentColor
        detailTextLabel.lineBreakMode = .byWordWrapping
        detailTextLabel.font = UIFont.systemFont(ofSize: ProgressConstants.DefaultDetailsLabelFontSize)
    }
    
    func updateIndicators() {
        activityIndicator.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        circleProgress.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        circleProgress.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        circleProgress.backgroundColor = UIColor.clear
        
        if circleProgress.progress > 0.0 {
            circleProgress.isHidden = false
            
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        } else {
            circleProgress.isHidden = true
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if superview != nil {
            let superviewFrame = (superview?.frame)!
            
            frame = superviewFrame
            backgroundView.frame = frame
            
            var bezeFrame = CGRect(x: frame.size.width/2-40, y: frame.size.height/2-40, width: 80, height: 80)
            
            if textLabel.text?.isEmpty == false {
                bezeFrame.size.height = bezeFrame.size.height + 10
                
                textLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: CGFloat.greatestFiniteMagnitude)
                textLabel.sizeToFit()
                
                var textFrame = textLabel.frame
                
                textFrame = textLabel.frame
                textFrame.origin.y = bezeFrame.origin.y + 65
                
                if textFrame.size.width < bezeFrame.size.width {
                    textFrame.size.width = bezeFrame.size.width
                } else {
                    bezeFrame.size.width = textFrame.size.width
                }
                
                bezeFrame.size.width = textFrame.size.width + 20
                bezeFrame.origin.x = (frame.size.width-bezeFrame.size.width)/2
                textFrame.origin.x = bezeFrame.origin.x + 10
                
                textLabel.frame = textFrame
            }
            
            if detailTextLabel.text?.isEmpty == false {
                detailTextLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: CGFloat.greatestFiniteMagnitude)
                detailTextLabel.sizeToFit()
                
                var textFrame = detailTextLabel.frame
                textFrame.origin.x = (frame.size.width-textFrame.size.width)/2
                textFrame.origin.y = bezeFrame.size.height + bezeFrame.origin.y-5
                detailTextLabel.frame = textFrame
                
                bezeFrame.size.height = bezeFrame.size.height + textFrame.size.height
                bezeFrame.size.width = textFrame.size.width + 20
                bezeFrame.origin.x = (frame.size.width-bezeFrame.size.width)/2
                
            }
            
            bezelView.frame = bezeFrame
            
            updateIndicators()
        }
    }
    
}

//MARK: - CircleProgressHUD

class CircleProgressHUD: UIView, CAAnimationDelegate {
    
    let circlePathLayer = CAShapeLayer()
    public var trailLineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    func configure() {
        progress = 0
        
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = trailLineColor.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.clear
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    func reveal() {
        circlePathLayer.removeAnimation(forKey: "strokeEnd")
        circlePathLayer.removeFromSuperlayer()
        superview?.layer.mask = circlePathLayer
        
        let circleRadius = (bounds.size.width - circlePathLayer.lineWidth) / 2
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
        let radiusInset = finalRadius - circleRadius
        let outerRect = bounds.insetBy(dx: -radiusInset, dy: -radiusInset)
        let toPath = UIBezierPath(ovalIn: outerRect).cgPath
        
        let fromPath = circlePathLayer.path
        let fromLineWidth = circlePathLayer.lineWidth
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        circlePathLayer.lineWidth = 2*finalRadius
        circlePathLayer.path = toPath
        CATransaction.commit()
        
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = fromLineWidth
        lineWidthAnimation.toValue = 2*finalRadius
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromPath
        pathAnimation.toValue = toPath
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 1
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        groupAnimation.animations = [pathAnimation, lineWidthAnimation]
        groupAnimation.delegate = self
        circlePathLayer.add(groupAnimation, forKey: "strokeWidth")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        superview?.layer.mask = nil
    }
}
