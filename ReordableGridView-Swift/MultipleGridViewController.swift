//
//  MultipleGridViewController.swift
//  ReordableGridView-Swift
//
//  Created by Cem Olcay on 21/11/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit

class MultipleGridViewController: UIViewController, Draggable {

    // MARK: Properties
    @IBOutlet var selectedItemsGridContainerView: UIView!
    @IBOutlet var itemsGridContainerView: UIView!
    
    var selectedItemsGrid: ReordableGridView?
    var itemsGrid: ReordableGridView?
    var itemCount: Int = 0
    
    var borderColor: UIColor?
    var bgColor: UIColor?
    var bottomColor: UIColor?
    
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderColor = RGBColor(233, g: 233, b: 233)
        bgColor = RGBColor(242, g: 242, b: 242)
        bottomColor = RGBColor(65, g: 65, b: 65)
        
        self.title = "Multiple Grid"
        self.navigationItem.title = "Multiple Grid View Demo"
        self.view.backgroundColor = bgColor
        
        selectedItemsGrid = ReordableGridView (frame: selectedItemsGridContainerView.bounds, itemWidth: 180)
        selectedItemsGrid?.draggableDelegate = self
        selectedItemsGrid?.reordable = false
        selectedItemsGrid?.clipsToBounds = false
        selectedItemsGridContainerView.addSubview(selectedItemsGrid!)

        itemsGrid = ReordableGridView (frame: itemsGridContainerView.bounds, itemWidth: 180)
        itemsGrid?.draggableDelegate = self
        itemsGrid?.clipsToBounds = false
        itemsGrid?.reordable = false
        itemsGridContainerView.addSubview(itemsGrid!)
        
        for _ in 0..<20 {
            itemsGrid?.addReordableView(itemView())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let grid = itemsGrid {
            grid.frame = itemsGridContainerView.bounds
            grid.invalidateLayout()
        }
        
        if let grid = selectedItemsGrid {
            grid.frame = selectedItemsGridContainerView.bounds
            grid.invalidateLayout()
        }
    }
    
    func itemView () -> ReordableView {
        let w : CGFloat = 180
        let h : CGFloat = 100 + CGFloat(arc4random()%100)
        
        let view = ReordableView (x: 0, y: 0, w: w, h: h)
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
    
    
    
    // MARK: Draggable
    
    func didDragStartedForView(reordableGridView: ReordableGridView, view: ReordableView) {
        
    }
    
    func didDraggedView(reordableGridView: ReordableGridView, view: ReordableView) {
        
    }
    
    func didDragEndFonView(reordableGridView: ReordableGridView, view: ReordableView) {
        
        // items grid to selected items grid
        
        if (reordableGridView == itemsGrid!) {
            let convertedPos : CGPoint = self.view.convertPoint(view.center, fromView: itemsGridContainerView)
            if (CGRectContainsPoint(selectedItemsGridContainerView.frame, convertedPos)) {
                itemsGrid?.removeReordableView(view)
                selectedItemsGrid?.addReordableView(view)
            }
        }
        
            
        // selected items grid to items grid
            
        else if (reordableGridView == selectedItemsGrid!) {
            let convertedPos : CGPoint = self.view.convertPoint(view.center, fromView: selectedItemsGridContainerView)
            if (CGRectContainsPoint(itemsGridContainerView.frame, convertedPos)) {
                selectedItemsGrid?.removeReordableView(view)
                itemsGrid?.addReordableView(view)
            }
        }
    }

    
    
    // MARK: Interface Rotation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        selectedItemsGrid?.frame = selectedItemsGridContainerView.bounds
        itemsGrid?.frame = itemsGridContainerView.bounds
        
        selectedItemsGrid?.invalidateLayout()
        itemsGrid?.invalidateLayout()
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
