//
//  ViewController.swift
//  ReordableGridView-Swift
//
//  Created by Cem Olcay on 19/11/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum FontType: String {
        case Regular = "Regular"
        case Bold = "Bold"
        case Light = "Light"
        case UltraLight = "UltraLight"
        case Italic = "Italic"
        case Thin = "Thin"
    }
    
    enum FontName: String {
        case HelveticaNeue = "HelveticaNeue"
        case Helvetica = "Helvetica"
        case Futura = "Futura"
        case Menlo = "Menlo"
    }

    class func Font (name: FontName, type: FontType, size: CGFloat) -> UIFont {
        return UIFont (name: name.rawValue + "-" + type.rawValue, size: size)!
    }
    
    class func HelveticaNeue (type: FontType, size: CGFloat) -> UIFont {
        return Font(.HelveticaNeue, type: type, size: size)
    }
}

class ViewController: UIViewController {

    // MARK: Properties
    
    var borderColor: UIColor?
    var bgColor: UIColor?
    var bottomColor: UIColor?
    
    var gridView : ReordableGridView?
    var itemCount: Int = 0
    
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderColor = RGBColor(233, g: 233, b: 233)
        bgColor = RGBColor(242, g: 242, b: 242)
        bottomColor = RGBColor(65, g: 65, b: 65)
        
        gridView = ReordableGridView(frame: self.view.frame, itemWidth: 150)
        gridView!.backgroundColor = bgColor
        
        self.view.addSubview(gridView!)
        
        for _ in 0...40 {
            gridView!.addReordableView(itemView())
        }
    }
    
    func itemView () -> ReordableView {
        var w : CGFloat = 150
        var h : CGFloat = 100 + CGFloat(arc4random()%100)
        
        let view = ReordableView (frame: CGRect(x: 0, y: 0, width: w, height: h))
        view.tag = itemCount++
        view.layer.borderColor = borderColor?.CGColor
        view.layer.backgroundColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: view.w, height: 50))
        view.addSubview(topView)
        
        let itemLabel = UILabel (frame: CGRect(x: 0, y: 0, width: topView.h/2, height: topView.h/2))
        itemLabel.center = topView.center
        itemLabel.font = UIFont.HelveticaNeue(.Thin, size: 20)
        itemLabel.textAlignment = NSTextAlignment.Center
        itemLabel.textColor = bottomColor?
        itemLabel.text = "\(view.tag)"
        itemLabel.layer.borderColor = borderColor?.CGColor
        itemLabel.layer.borderWidth = 1
        itemLabel.layer.cornerRadius = itemLabel.w/2
        itemLabel.layer.masksToBounds = true
        topView.addSubview(itemLabel)
        
        let sepLayer = CALayer ()
        sepLayer.frame = CGRect (x: 0, y: topView.bottom, width: topView.w, height: 1)
        sepLayer.backgroundColor = borderColor?.CGColor
        topView.layer.addSublayer(sepLayer)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: topView.bottom, width: view.w, height: view.h-topView.h))
        let bottomLayer = CALayer ()
        bottomLayer.frame = CGRect (x: 0, y: bottomView.h-5, width: bottomView.w, height: 5)
        bottomLayer.backgroundColor = bottomColor?.CGColor
        bottomView.layer.addSublayer(bottomLayer)
        bottomView.layer.masksToBounds = true
        view.addSubview(bottomView)
        
        return view
    }


    
    // MARK Interface Rotation

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let w = UIScreen.mainScreen().bounds.size.width
        let h = UIScreen.mainScreen().bounds.size.height
        
        if (fromInterfaceOrientation.isPortrait) {
            gridView?.setW(h, h: w)
            gridView?.invalidateLayout()
        } else {
            gridView?.setW(w, h: h)
            gridView?.invalidateLayout()
        }
    }
    
    
    
    // MARK: Utils
    
    func randomColor () -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor (red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
    
    func RGBAColor (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor (red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}

