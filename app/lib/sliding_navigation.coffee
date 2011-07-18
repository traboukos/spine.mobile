class SlidingNavigationController extends Spine.Controller
  
  children         : []
  childrenWidth    : 0
  offsetWidth      : 0
  topChildIndex    : 0
  topChild         : null
  
  touch: {}
  dragging: false
  
  events:
    "swipeLeft"  : "swipeleft"
    "swipeRight" : "swiperight"
    "touchstart" : "touchstart"
    "touchmove"  : "touchmove"
    "mousedown"  : "mousedown"
    "mousemove"  : "mousemove"
    "mouseup"    : "mouseup"
    
  mousedown: (e) ->
    @touch.x1 = e.pageX
    @touch.currentOffsetWidth = @offsetWidth
    @dragging = true
    
  mousemove: (e) ->
    if @dragging
      deltaX = @touch.x1 - e.pageX
      @offsetWidth = @touch.currentOffsetWidth - deltaX

      @repositionChildren(no)
    
  mouseup: (e) ->
    @dragging = false
    deltaX = @touch.x1 - e.pageX
    return if Math.abs(deltaX) < 50
    if deltaX < 0 then @swiperight() else @swipeleft()
  
  swiperight: ->
    return if @children.length == 1 or @fullyExpanded()
    
    @offsetWidth += @topChild.currentOverlap
      
    @repositionChildren()
    
  touchstart: (e) ->
    e = e.originalEvent
    @touch.x1 = e.touches[0].pageX
    @touch.y1 = e.touches[0].pageY
    
    @touch.currentOffsetWidth = @offsetWidth
    
  touchmove: (e) ->
    e = e.originalEvent
    deltaX = @touch.x1 - e.touches[0].pageX
    @offsetWidth = @touch.currentOffsetWidth - deltaX
    
    @repositionChildren(no)
          
  swipeleft: ->
    return if @children.length == 1 or @fullyContracted()

    if @fullyExpanded()
      @offsetWidth = -1 * (@el.width() - @childrenWidth + @children[0].overlapWidth)
    else
      @offsetWidth -= @topChild.overlapWidth
  
    console.log("swipeleft")
    @repositionChildren()

  fullyExpanded: ->
    @children[1].currentOverlap == 0
    
  fullyContracted: ->
    @children[@children.length-1].currentOverlap == @children[@children.length-2].overlapWidth
  
    
  constructor: -> 
    super

  push: (child,margin=0,defaultOverlap=0,animated=yes) ->
    @appendController(child)
    
    childWidth      = child.el.outerWidth()
    @childrenWidth += childWidth
    @offsetWidth    = 0
    
    childInfo = 
      controller     : child
      translateX     : 0
      margin         : margin
      width          : childWidth - defaultOverlap
      overlapWidth   : childWidth - defaultOverlap - margin
      currentOverlap : 0
      
    @children.push(childInfo)
    
    @repositionChildren(animated)
        
  repositionChildren: (animated=yes)-> 
    containerWidth  = @el.width()
    overlapWidth = @childrenWidth - containerWidth - @offsetWidth
    if overlapWidth < 0 then overlapWidth = 0
    
    @topChild = null
    
    previousChild = @children[0]
    for child in @children
      if previousChild == child 
        child.translateX = containerWidth
        child.controller.el.gfx(translateX:"-#{child.translateX}px")
      else
        child.currentOverlap = Math.min(previousChild.overlapWidth , overlapWidth)
        child.translateX = previousChild.translateX - previousChild.width + child.currentOverlap

        if child.currentOverlap > 0
          @topChild = child
          
        if child.currentOverlap == previousChild.overlapWidth 
          child.controller.el.addClass("full-overlap")
        else
          child.controller.el.removeClass("full-overlap") 
          
        fn = if animated then 'gfx' else 'transform'
        child.controller.el[fn](translate3d: "#{-1 * child.translateX}px,0,0")
        
        overlapWidth -= child.currentOverlap  
        previousChild = child
    
  appendController: (controller) ->
    controller.navigationController = @
    controller.render();
    @el.append(controller.el)
    controller.el.css(left: "#{@el.width()}px")
    
  pop: ->
    child = @children.pop()
    @childrenWidth -= child.width
    child.controller.el.remove()
    
  popTo: (viewController) -> 
    for i in [@children.length-1..0]
      if @children[i].controller == viewController
         return 
      
      @pop()
    
module.exports = SlidingNavigationController
    
