class Contact extends Spine.Controller
  
  events:
    "tap header a" : "close"
    
  constructor: ->
    super
    
  close: =>
    @navigate("/")
      
module.exports = Contact