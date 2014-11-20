ReordableGridView-Swift
=======================

reorderable grid view solution implemented with swift. its UIScrollView subclass, its not a collection view layout.<br>
automatically sets horizontal item spacing by item widths. so items must be fixed-width.<br>
also sets automatically its content size. <br>
if you call `gridView?.invalidateLayout()` after orientation changed, it will lays out the grid by new orientation.


Demo
====

![alt tag](https://raw.githubusercontent.com/cemolcay/ReordableGridView-Swift/master/demo.gif)

Usage
=====

copy & paste the `ReordableGridView.swift` into your project. <br>

      gridView = ReordableGridView(frame: self.view.frame, itemWidth: 180, verticalPadding: 20)
      self.view.addSubview(gridView!)

Grid view ready !

now you can add it `ReordableView` instances 

      gridView?.addReordableView(itemView())
      

or  remove them
    gridView?.removeReordableViewAtGridPosition(GridPosition (x: 0, y: 0))


Optional Values
---------------

    var reordable : Bool = true
    var draggable : Bool = true
  
set them if you want your grid editable or not
