User = require("models/user")

class UserList extends Spine.Controller

  events:
    "tap .user": "showUserProfile"

  constructor: (users) ->
    super
    
    @el.addClass("user-list")
    
    @users = users
  
  render: =>
    @el.html(require("views/users/list")(@users))
    
  showUserProfile: (e) ->
    user = $(e.target).item()
    
    @navigationController.popTo(@)
    @navigationController.push(new UserProfile(user.id),2)

class UserProfile extends Spine.Controller
  
  events: 
    "tap .following":"showUserList"
    "tap .followers":"showUserList"
    
  constructor: (userId) ->
    super
    
    @el.addClass("profile")
    @user = User.find(userId)

  render: ->
    @el.html(require("views/users/show")(@user))
    
  showUserList: (e) ->

    @navigationController.popTo(@)
    
    users = if $(e.target).hasClass("following") then @user.following() else @user.followers()
    userList = new UserList(users)
    @navigationController.push(userList,2)      
  
        
module.exports = UserProfile