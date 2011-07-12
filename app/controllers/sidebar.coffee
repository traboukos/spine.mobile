UserProfile = require("controllers/users")

class Sidebar extends Spine.Controller
  
  constructor: ->
    super
    @el.addClass("sidebar")
    
  events:
    "tap li":"selectionChange"
    "tap a.email-button":"contact"
    
  render: -> 
    @el.html(require("views/sidebar")())
    
  selectionChange: (event) ->
    @$("li.selected").removeClass("selected")
    @$(event.target).addClass("selected")
    
    @navigationController.popTo(@)
     
    profile = new UserProfile(1)
    @navigationController.push(profile,2)
    
  remove: ->
    @el.remove()
    
  contact: ->
    @navigate("/contact")
      
module.exports = Sidebar