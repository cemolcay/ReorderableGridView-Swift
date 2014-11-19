//
//  ReordableGridView.swift
//  ReordableGridView-Swift
//
//  Created by Cem Olcay on 19/11/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit


extension UIView {
    
    // MARK: Frame Extensions
    
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var w: CGFloat {
        return self.frame.size.width
    }
    
    var h: CGFloat {
        return self.frame.size.height
    }
    
    
    var left: CGFloat {
        return self.x
    }
    
    var right: CGFloat {
        return self.x + self.w
    }
    
    var top: CGFloat {
        return self.y
    }
    
    var bottom: CGFloat {
        return self.y + self.h
    }
    
    
    func setX (x: CGFloat) {
        self.frame = CGRect (x: x, y: self.y, width: self.w, height: self.h)
    }
    
    func setY (y: CGFloat) {
        self.frame = CGRect (x: self.x, y: y, width: self.w, height: self.h)
    }
    
    func setX (x: CGFloat, y: CGFloat) {
        self.frame = CGRect (x: x, y: y, width: self.w, height: self.h)
    }
    
    
    func setW (w: CGFloat) {
        self.frame = CGRect (x: self.x, y: self.y, width: w, height: self.h)
    }
    
    func setH (h: CGFloat) {
        self.frame = CGRect (x: self.x, y: self.y, width: self.w, height: h)
    }
    
    func setW (w: CGFloat, h: CGFloat) {
        self.frame = CGRect (x: self.x, y: self.y, width: w, height: h)
    }
    
    func setSize (size: CGSize) {
        self.frame = CGRect (x: self.x, y: self.y, width: size.width, height: size.height)
    }
    
    func setPosition (position: CGPoint) {
        self.frame = CGRect (x: position.x, y: position.y, width: self.w, height: self.h)
    }
    
    
    func leftWithOffset (offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    func rightWithOffset (offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    func topWithOffset (offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    func botttomWithOffset (offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
    
}


protocol Reordable {
    func didReorderStartedForView (view: ReordableView)
    func didReorderingView (view: ReordableView)
    func didReordererdView (view: ReordableView)
}


struct GridPosition {
    var x: Int?
    var y: Int?
}


class ReordableView: UIView {
    
    var delegate: Reordable! = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var doubleTap = UITapGestureRecognizer (target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTap)
        
        var longPress = UILongPressGestureRecognizer (target: self, action: "longPressed:")
        longPress.numberOfTouchesRequired = 1
        self.addGestureRecognizer(longPress)
        
        var pan = UIPanGestureRecognizer (target: self, action: "pan:")
        self.addGestureRecognizer(pan)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func longPressed (gesture: UITapGestureRecognizer) {
        delegate?.didReorderStartedForView(self)
    }
    
    func doubleTapped (gesture: UITapGestureRecognizer) {
        delegate?.didReorderStartedForView(self)
    }
    
    func pan (gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            delegate.didReorderStartedForView(self)
            
        case .Cancelled, .Failed, .Ended:
            delegate.didReordererdView(self)
            
        case .Changed:
            delegate.didReorderingView(self)
        
        default:
            return
        }
    }
}


class ReordableGridView: UIScrollView, Reordable {
    
    
    // MARK: Properties
    
    var currentCol: Int = 0 {
        didSet {
            if currentCol > colsInRow!-1 {
                currentCol = 0
                currentRow++
            } else if currentCol < 0 {
                currentCol = colsInRow!-1
                currentRow--
            }
        }
    }
    
    var currentRow: Int = 0 {
        didSet {
            if currentRow < 0 {
                currentRow = 0
            }
        }
    }
    
    var itemWidth: CGFloat?
    var verticalPadding: CGFloat?
    var horizontalPadding: CGFloat?
    var colsInRow: Int?
    
    var reordable : Bool = true
    var draggable : Bool = true
    
    var reordableViews : [ReordableView] = []
    
    
    
    // MARK: Lifecycle
    
    init (frame: CGRect, itemWidth: CGFloat, verticalPadding: CGFloat = 10) {
        super.init(frame: frame)
        self.itemWidth = itemWidth
        self.verticalPadding = verticalPadding
        
        colsInRow = Int (self.w / itemWidth)
        horizontalPadding = (self.w - (CGFloat(colsInRow!) * itemWidth)) / (CGFloat(colsInRow!) - 1)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Adding
    
    func addReordableView (view: ReordableView) {
        super.addSubview(view)
        reordableViews.append(view)
        
        let gridPosition = GridPosition (x: currentCol++, y: currentRow)
        view.delegate = self
        
        let pos = gridPositionToViewPosition(gridPosition)
        view.setX(pos.x, y: pos.y)
    }
    
    func gridPositionToViewPosition (gridPosition: GridPosition) -> CGPoint {
        let w = itemWidth!
        let h = viewHeight
        
        let hp = grid.horizontalPadding!
        let vp = grid.verticalPadding!
        
        let xf = CGFloat (x!)
        let yf = CGFloat (y!)
        
        var posX: CGFloat = (xf*w) + (max(0, xf-1) * hp)
        var posY: CGFloat = (yf*h) + (max(0, yf-1) * vp)
        return CGPointMake(posX , posY)
    }
    
    func heightOfItemAtRow (row: Int, col: Int) -> CGFloat {
        if row < 0 {
            return 0
        } else {
            return reordableViews[max(0, row-1)*col + col].h
        }
    }
    
    
    
    
    // MARK: Removing
    
    func removeReordableViewAtGridPosition (gridPosition: GridPosition) {}
    
    
    
    // MARK: Reordable
    
    func didReorderStartedForView (view: ReordableView) {}
    
    func didReorderingView (view: ReordableView) {}
    
    func didReordererdView (view: ReordableView) {}
}
