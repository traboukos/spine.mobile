class SlidingNavigationController extends Spine.Controller
  
  children         : []
  childrenWidth    : 0
  offsetWidth      : 0
  topChildIndex    : 0
  topChild         : null
  
  events:
    "mousewheel" : "mousewheel"
    "swipeLeft"  : "swipeleft"
    "swipeRight" : "swiperight"
    
  mousewheel: (e) ->
    if e.wheelDelta > 0
      @swiperight(e)
    else
      @swipeleft(e)
  
  swiperight: (e) ->
    return if @children.length == 1 or @fullyExpanded()
    
    @offsetWidth += @topChild.currentOverlap
      
    console.log("swiperight #{@offsetWidth}")
    @repositionChildren()
          
  swipeleft: (e) ->
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

  push: (child,margin=0,defaultOverlap=0) ->
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
    
    @repositionChildren()
        
  repositionChildren: -> 
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
          
        child.controller.el.gfx(translateX:"#{-1 * child.translateX}px")
        
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
    
