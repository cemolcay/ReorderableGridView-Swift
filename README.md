ReordableGridView-Swift
=======================

reorderable grid view solution implemented with swift. <br>
its UIScrollView subclass, its not a collection view layout.<br>
automatically sets horizontal item spacing by item widths. so items must be fixed-width.<br>
also sets automatically its content size. <br>
if you call `gridView?.invalidateLayout()` after orientation changed, it will lays out the grid by new orientation.


Demo
----

![alt tag](https://raw.githubusercontent.com/cemolcay/ReordableGridView-Swift/master/demo.gif)

Usage
-----

copy & paste the `ReordableGridView.swift` into your project. <br>

      gridView = ReordableGridView(frame: self.view.frame, itemWidth: 180, verticalPadding: 20)
      self.view.addSubview(gridView!)

Grid view ready !

now you can add it `ReordableView` instances 
      
      let itemView = ReordableView (x: 0, y: 0, w: 200, h: 250)
      ...
      gridView?.addReordableView(itemView)
      

or  remove them

    gridView?.removeReordableViewAtGridPosition(GridPosition (x: 0, y: 0))
    


> **Design Tip**  
> View itself don't have any margin padding.  
> It uses all frame width to calculate how many `ReorderableView`s can fit and
> what should be their horizontal padding in a row.   
> Padding between columns (vertical padding) can be set in init method,    
> which is 10 by default.  
> You can have a container view and use something like   
> `CGRectInset (containerView.frame, marginX, marginY)`  
> when init grid with margin



Optional Values
---------------

      var reordable : Bool = true
      var draggable : Bool = true
      var draggableDelegate: Draggable?

set them if you want your grid editable or not

**Draggable Protocol**

    func didDragStartedForView (reordableGridView: ReordableGridView, view: ReordableView)
    func didDraggedView (reordableGridView: ReordableGridView, view: ReordableView)
    func didDragEndForView (reordableGridView: ReordableGridView, view: ReordableView)


set `gridView.draggableDelegate = self` and implement `Draggable` protocol functions if you want to access info about dragging actions in grid.   
This can be useful for multiple grid layouts.  
Example included in second tab of demo.
