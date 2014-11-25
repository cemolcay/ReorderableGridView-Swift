//
//  ViewController.swift
//  ReorderableGridView-Swift
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
    
    var gridView : ReorderableGridView?
    var itemCount: Int = 0

    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderColor = RGBColor(233, g: 233, b: 233)
        bgColor = RGBColor(242, g: 242, b: 242)
        bottomColor = RGBColor(65, g: 65, b: 65)
        
        self.title = "Reorderable Grid"
        self.navigationItem.title = "Reorderable Grid View Demo"
        self.view.backgroundColor = bgColor
        
        setupGridView()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if let grid = gridView {
            grid.invalidateLayout()
        }
    }
    
    
    
    // MARK: Grid View
    
    func setupGridView () {
        let add = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPressed:")
        let remove = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "removePressed:")
        
        self.navigationItem.leftBarButtonItem = add
        self.navigationItem.rightBarButtonItem = remove
        
        gridView = ReorderableGridView(frame: self.view.frame, itemWidth: 180, verticalPadding: 20)
        self.view.addSubview(gridView!)
        
        for _ in 0..<20 {
            gridView!.addReorderableView(itemView())
        }
    }
    
    func itemView () -> ReorderableView {
        let w : CGFloat = 180
        let h : CGFloat = 100 + CGFloat(arc4random()%100)
        
        let view = ReorderableView (x: 0, y: 0, w: w, h: h)
        view.tag = itemCount++
        view.layer.borderColor = borderColor?.CGColor
        view.layer.backgroundColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        let topView = UIView(x: 0, y: 0, w: view.w, h: 50)
        view.addSubview(topView)
        
        let itemLabel = UILabel (frame: topView.frame)
        itemLabel.center = topView.center
        itemLabel.font = UIFont.HelveticaNeue(.Thin, size: 20)
        itemLabel.textAlignment = NSTextAlignment.Center
        itemLabel.textColor = bottomColor?
        itemLabel.text = "\(view.tag)"
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


    
    // MARK: Add/Remove
    
    func addPressed (sender: AnyObject) {
        //gridView?.addReorderableView(itemView())
        gridView?.addReorderableView(itemView(), gridPosition: GridPosition (x: 0, y: 1))
    }
    
    func removePressed (sender: AnyObject) {
        gridView?.removeReorderableViewAtGridPosition(GridPosition (x: 0, y: 0))
        //gridView?.removeReorderableView(gridView!.ReorderableViews[2])
    }
    
    
    
    // MARK: Interface Rotation

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let w = UIScreen.mainScreen().bounds.size.width
        let h = UIScreen.mainScreen().bounds.size.height
        
        gridView?.setW(h, h: w)
        gridView?.invalidateLayout()
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

