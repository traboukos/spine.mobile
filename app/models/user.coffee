class User extends Spine.Model
  @configure "User", "name", "username", "bio","following_ids","follower_ids"
 
  following: -> 
    User.select (user) =>
      parseInt(user.id) in @following_ids
      
  followers: -> 
    User.select (user) =>
      parseInt(user.id) in @follower_ids
  

module.exports = User