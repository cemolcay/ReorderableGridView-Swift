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
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame = CGRect (x: self.x, y: y, width: self.w, height: self.h)
        })
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
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame = CGRect (x: position.x, y: position.y, width: self.w, height: self.h)
        })
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
    
    
    func setScale (x: CGFloat, y: CGFloat, z: CGFloat) {
        self.transform = CGAffineTransformMakeScale(x, y)
    }
    
    convenience init (x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init (frame: CGRect (x: x, y: y, width: w, height: h))
    }
}


protocol Reordable {
    func didReorderStartedForView (view: ReordableView)
    func didReorderingView (view: ReordableView, pan: UIPanGestureRecognizer)
    func didReordererdView (view: ReordableView, pan: UIPanGestureRecognizer)
}


func == (lhs: GridPosition, rhs: GridPosition) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

struct GridPosition: Equatable {
    var x: Int?
    var y: Int?
    
    
    func col () -> Int {
        return x!
    }
    
    func row () -> Int {
        return y!
    }
    
    
    func arrayIndex (colsInRow: Int) -> Int {
        let index = row()*colsInRow + col()
        return index
    }
    
    
    func up () -> GridPosition? {
        if y <= 0 {
            return nil
        } else {
            return GridPosition(x: x!, y: y!-1)
        }
    }
    
    func down () -> GridPosition {
        return GridPosition(x: x!, y: y!+1)
    }

    func left () -> GridPosition? {
        if x <= 0 {
            return nil
        } else {
            return GridPosition (x: x!-1, y: y!)
        }
    }
    
    func right () -> GridPosition {
        return GridPosition (x: x!+1, y: y!)
    }
    
    
    func string () -> String {
        return "\(x!), \(y!)"
    }
    
    func detailedString () -> String {
        return "x: \(x!), y: \(y!)"
    }
}


class ReordableView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    var delegate: Reordable! = nil
    var pan: UIPanGestureRecognizer?
    var gridPosition: GridPosition?
    
    let animationDuration: NSTimeInterval = 0.2
    let reorderModeScale: CGFloat = 1.1
    let reorderModeAlpha: CGFloat = 0.6
    
    var isReordering : Bool = false {
        didSet {
            if isReordering {
                startReorderMode()
            } else {
                endReorderMode()
            }
        }
    }
    
    
    
    // MARK: Lifecycle
    
    convenience init (x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init (frame: CGRect (x: x, y: y, width: w, height: h))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var doubleTap = UITapGestureRecognizer (target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delegate = self
        
        self.addGestureRecognizer(doubleTap)
        
        
        var longPress = UILongPressGestureRecognizer (target: self, action: "longPressed:")
        longPress.numberOfTouchesRequired = 1
        longPress.delegate = self
        
        self.addGestureRecognizer(longPress)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: Animations
    
    func startReorderMode () {
        addPan()
        
        superview?.bringSubviewToFront(self)

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.alpha = self.reorderModeAlpha
            self.setScale(self.reorderModeScale, y: self.reorderModeScale, z: self.reorderModeScale)
        })
    }
    
    func endReorderMode () {
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.alpha = 1
            self.setScale(1, y: 1, z: 1)
        }) { finished -> Void in
            self.removePan()
        }
    }
    
    
    
    // MARK: Gestures
    
    func addPan () {
        pan = UIPanGestureRecognizer (target: self, action: "pan:")
        self.addGestureRecognizer(pan!)
    }
    
    func removePan () {
        self.removeGestureRecognizer(pan!)
    }
    
    
    func longPressed (gesture: UITapGestureRecognizer) {
        if isReordering { return } else { isReordering = true }
        delegate?.didReorderStartedForView(self)
    }
    
    func doubleTapped (gesture: UITapGestureRecognizer) {
        isReordering = !isReordering
        
        if isReordering {
            delegate?.didReorderStartedForView(self)
        }
    }
    
    func pan (gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            isReordering = false
            delegate.didReordererdView(self, pan: pan!)
            
        case .Changed:
            delegate.didReorderingView(self, pan: pan!)
        
        default:
            return
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
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
    
        invalidateLayout()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: ScrollView
    
    func setContentHeight (height: CGFloat) {
        contentSize = CGSize (width: w, height: height)
    }
    
    func addContentHeight (height: CGFloat) {
        setContentHeight(contentSize.height + height)
    }

    
    
    // MARK: Layout
    
    func invalidateLayout () {
        colsInRow = Int (self.w / itemWidth!)
        horizontalPadding = (self.w - (CGFloat(colsInRow!) * itemWidth!)) / (CGFloat(colsInRow!) - 1)
        contentSize.height = 0
        
        currentCol = 0
        currentRow = 0

        if reordableViews.isEmpty {
            return
        }
        
        for i in 0...reordableViews.count-1 {
            placeView(reordableViews[i])
        }
    }
    
    func placeView (view: ReordableView) {
        let y = currentRow
        let x = currentCol++
        
        let gridPosition = GridPosition (x: x, y: y)
        view.delegate = self
        view.gridPosition = gridPosition
        
        let pos = gridPositionToViewPosition(gridPosition)
        view.setPosition(pos)
        

        let height = view.botttomWithOffset(verticalPadding!)
        if height > contentSize.height {
            setContentHeight(height)
        }
    }
    
    func insertViewAtPosition (view: ReordableView, position: GridPosition) {
        if (view.gridPosition == position) {
            return
        }
    
        reordableViews.removeAtIndex(view.gridPosition!.arrayIndex(colsInRow!))
        reordableViews.insert(view, atIndex: position.arrayIndex(colsInRow!))
        invalidateLayout()
    }
    
    
    
    // MARK: Grid
    
    func gridPositionToViewPosition (gridPosition: GridPosition) -> CGPoint {
        var x : CGFloat = (CGFloat(gridPosition.x! - 1) * (itemWidth! + verticalPadding!)) + itemWidth!
        var y : CGFloat = 0
        
        if let up = gridPosition.up() {
            y = viewAtGridPosition(up)!.bottom + verticalPadding!
        }
        
        return CGPoint (x: x, y: y)
    }
    
    func viewAtGridPosition (gridPosition: GridPosition) -> ReordableView? {
        let index = gridPosition.arrayIndex(colsInRow!)
        if (index < reordableViews.count) {
            return reordableViews[index]
        } else {
            return nil
        }
    }
    
    func heightOfCol (col: Int) -> CGFloat {
        var height: CGFloat = 0
        
        // TODO: fix this func
        
        return height
    }
    
    
    
    // MARK: Adding
    
    func addReordableView (view: ReordableView) {
        super.addSubview(view)
        reordableViews.append(view)
        invalidateLayout()
    }
    
    
    
    // MARK: Removing
    
    func removeReordableViewAtGridPosition (gridPosition: GridPosition) {
        if let view = viewAtGridPosition(gridPosition) {
            reordableViews.removeAtIndex(gridPosition.arrayIndex(colsInRow!))
            
            view.removeFromSuperview()
            invalidateLayout()
        }
    }
    
    
    
    // MARK: Reordable
    
    func didReorderStartedForView (view: ReordableView) {
        
    }
    
    func didReorderingView (view: ReordableView, pan: UIPanGestureRecognizer) {
        let location = pan.locationInView(self)
        view.center = location
        
        let col : Int = min(Int(location.x) / Int(itemWidth! + horizontalPadding!), colsInRow!-1)
        let rowCount : Int = reordableViews.count/colsInRow!
        
        
        var gridPos = GridPosition (x: col, y: 0)
        for (var row = 0; row < reordableViews.count/colsInRow!; row++) {
            gridPos.y = row
            
            if let otherView = viewAtGridPosition(gridPos) {
                if otherView == view {
                    continue
                }
                
                if CGRectContainsPoint(otherView.frame, location) {
                    //println("im at \(col), \(row), im " + view.gridPosition!.string())
                    insertViewAtPosition(view, position: gridPos)
                }
            }
        }
    }
    
    func didReordererdView (view: ReordableView, pan: UIPanGestureRecognizer) {
        invalidateLayout()
    }
}
