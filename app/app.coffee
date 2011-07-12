require("lib/jquery.touch")
SlidingNavigationController = require("lib/sliding_navigation")
Sidebar     = require("controllers/sidebar")
User        = require("models/user")
UserProfile = require("controllers/users")
Contact     = require("controllers/contact")

class App extends Spine.Controller
  elements:
    "#content": "content"
    "#email-form":"contact"

  constructor: ->
    super
    
    document.addEventListener('touchmove', -> (e) e.preventDefault() , false);   

    @slidingNavigation = new SlidingNavigationController(el: @content)
    
    @sidebar = new Sidebar()
    @slidingNavigation.push(@sidebar,65,2)
        
    @contact = new Contact(el: @contact)
    
    $.getJSON "fixtures.json", (data) =>
      User.refresh(data)
      @profile = new UserProfile(1)
      @slidingNavigation.push(@profile,2)
    
    $.preventDefaultTouch()
    $.setupTouch()
    
    @routes
      "/contact" : (params) => 
        @slidingNavigation.el.queueNext =>
          @slidingNavigation.el.gfx(translateY: "200px")
      
      "/"        : (params) ->
        @slidingNavigation.el.queueNext =>
          @slidingNavigation.el.gfx(translateY: "0px")
    
module.exports = App