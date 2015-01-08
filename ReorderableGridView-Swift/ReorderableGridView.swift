//
//  ReorderableGridView.swift
//  ReorderableGridView-Swift
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
        if (frame.origin == position) {
            return
        }
        
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


protocol Reorderable {
    func didReorderStartedForView (view: ReorderableView)
    func didReorderedView (view: ReorderableView, pan: UIPanGestureRecognizer)
    func didReorderEndForView (view: ReorderableView, pan: UIPanGestureRecognizer)
}


protocol Draggable {
    func didDragStartedForView (ReorderableGridView: ReorderableGridView, view: ReorderableView)
    func didDraggedView (ReorderableGridView: ReorderableGridView, view: ReorderableView)
    func didDragEndForView (ReorderableGridView: ReorderableGridView, view: ReorderableView)
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


class ReorderableView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    var delegate: Reorderable! = nil
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
            delegate.didReorderEndForView(self, pan: pan!)
            
        case .Changed:
            delegate.didReorderedView(self, pan: pan!)
        
        default:
            return
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}


class ReorderableGridView: UIScrollView, Reorderable {
    
    
    // MARK: Properties
    
    var itemWidth: CGFloat?
    var verticalPadding: CGFloat?
    var horizontalPadding: CGFloat?
    var colsInRow: Int?
    
    var visibleRect: CGRect?
    
    var reorderable : Bool = true
    var draggable : Bool = true
    
    var draggableDelegate: Draggable?
    
    var reorderableViews : [ReorderableView] = []
    
    
    
    // MARK: Observers
    
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

    override var contentOffset: CGPoint {
        didSet {
            visibleRect? = CGRect (origin: contentOffset, size: frame.size)
            checkReusableViews()
        }
    }
    
    
    
    // MARK: Lifecycle
    
    init (frame: CGRect, itemWidth: CGFloat, verticalPadding: CGFloat = 10) {
        super.init(frame: frame)
        self.itemWidth = itemWidth
        self.verticalPadding = verticalPadding
        self.visibleRect = frame
        
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

    func isViewInVisibleRect (view: ReorderableView) -> Bool {
        if let rect = visibleRect {
            return CGRectIntersectsRect(view.frame, rect)
        } else {
            return false
        }
    }
    
    func checkReusableViews () {
        for view in reorderableViews {
            if isViewInVisibleRect(view) {
                // is already added to view stack
                if let superView = view.superview {
                    if superView == self {
                        // already added
                        continue
                    } else {
                        // FIXME: another view is super !
                        continue
                    }
                } else {
                    if let gridPos = view.gridPosition {
                        // add
                        addSubview(view)
                        placeView(view, toGridPosition: gridPos)
                    } else {
                        // not initilized yet
                        continue
                    }
                }
            } else {
                // should removed
                if let superView = view.superview {
                    if superView == self {
                        // remove
                        view.removeFromSuperview()
                    } else {
                        // FIXME: another view is super !
                        continue
                    }
                } else {
                    // already removed 
                    continue
                }
            }
        }
    }
    
    
    
    // MARK: Layout
    
    func invalidateLayout () {
        colsInRow = Int (self.w / itemWidth!)
        horizontalPadding = (self.w - (CGFloat(colsInRow!) * itemWidth!)) / (CGFloat(colsInRow!) - 1)
        contentSize.height = contentOffset.y + h
        
        currentCol = 0
        currentRow = 0

        if reorderableViews.isEmpty {
            return
        }
        
        for i in 0...reorderableViews.count-1 {
            let y = currentRow
            let x = currentCol++
            let gridPosition = GridPosition (x: x, y: y)
            
            placeView(reorderableViews[i], toGridPosition: gridPosition)
        }
    }
    
    func placeView (view: ReorderableView, toGridPosition: GridPosition) {
        view.gridPosition = toGridPosition
        view.delegate = self
        
        let pos = gridPositionToViewPosition(toGridPosition)
        view.setPosition(pos)
        
        let height = view.botttomWithOffset(verticalPadding!)
        if height > contentSize.height {
            setContentHeight(height)
        }
    }
    
    func insertViewAtPosition (view: ReorderableView, position: GridPosition) {
        if (view.gridPosition == position) {
            return
        }
    
        reorderableViews.removeAtIndex(view.gridPosition!.arrayIndex(colsInRow!))
        reorderableViews.insert(view, atIndex: position.arrayIndex(colsInRow!))
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
    
    func viewAtGridPosition (gridPosition: GridPosition) -> ReorderableView? {
        let index = gridPosition.arrayIndex(colsInRow!)
        if (index < reorderableViews.count) {
            return reorderableViews[index]
        } else {
            return nil
        }
    }
    
    
    
    // MARK: Adding
    
    func addReorderableView (view: ReorderableView) {
        super.addSubview(view)
        reorderableViews.append(view)
        invalidateLayout()
    }
    
    func addReorderableView (view: ReorderableView, gridPosition: GridPosition) {
        super.addSubview(view)
        
        var addingIndex = gridPosition.arrayIndex(colsInRow!)
        if addingIndex >= reorderableViews.count {
            addingIndex = reorderableViews.count
        }
        
        reorderableViews.insert(view, atIndex: addingIndex)
        invalidateLayout()
    }
    
    
    
    // MARK: Removing
    
    func removeReorderableViewAtGridPosition (gridPosition: GridPosition) {
        if let view = viewAtGridPosition(gridPosition) {
            reorderableViews.removeAtIndex(gridPosition.arrayIndex(colsInRow!))
            
            view.removeFromSuperview()
            invalidateLayout()
        }
    }
    
    func removeReorderableView (view: ReorderableView) {
        if let pos = view.gridPosition {
            removeReorderableViewAtGridPosition(pos)
        } else {
            println ("view is not in grid hierarchy")
        }
    }
    
    
    
    // MARK: Reorderable
    
    func didReorderStartedForView (view: ReorderableView) {
        draggableDelegate?.didDragStartedForView(self, view: view)
    }
    
    func didReorderedView (view: ReorderableView, pan: UIPanGestureRecognizer) {
    
        if !draggable {
            return
        } else {
            draggableDelegate?.didDraggedView(self, view: view)
        }
        
        let location = pan.locationInView(self)
        view.center = location
    
        
        if !reorderable {
            return
        }
        
        let col : Int = min(Int(location.x) / Int(itemWidth! + horizontalPadding!), colsInRow!-1)
        let rowCount : Int = reorderableViews.count/colsInRow!
        
        var gridPos = GridPosition (x: col, y: 0)
        for (var row = 0; row < reorderableViews.count/colsInRow!; row++) {
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
    
    func didReorderEndForView (view: ReorderableView, pan: UIPanGestureRecognizer) {
        if reorderable {
            invalidateLayout()
        }
        
        if draggable {
            draggableDelegate?.didDragEndForView(self, view: view)
        }
    }
}
