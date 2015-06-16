Items = new Mongo.Collection 'items'

if Meteor.isServer

  # Global API configuration
  Restivus.configure
    useAuth: true
    prettyJson: true

  # Generates: GET, POST, DELETE on /api/items and GET, PUT, DELETE on
  # /api/items/:id for Items collection
  Restivus.addCollection Items

  # Generates: GET, POST on /api/users and GET, DELETE /api/users/:id for
  # Meteor.users collection
  Restivus.addCollection Meteor.users,
    excludedEndpoints: ['deleteAll', 'put']
    routeOptions:
      authRequired: true
    endpoints:
      post:
        authRequired: false
      delete:
        roleRequired: 'admin'

  # Maps to: /api/posts/:id
  Restivus.addRoute 'posts/:id', authRequired: true,
    get: ->
      post = Posts.findOne @urlParams.id
      if post
        status: 'success', data: post
      else
        statusCode: 404
        body: status: 'fail', message: 'Post not found'
    post:
      roleRequired: ['author', 'admin']
      action: ->
        post = Posts.findOne @urlParams.id
        if post
          status: "success", data: post
        else
          statusCode: 400
          body: status: "fail", message: "Unable to add post"
    delete:
      roleRequired: 'admin'
      action: ->
        if Posts.remove @urlParams.id
          status: "success", data: message: "Item removed"
        else
          statusCode: 404
          body: status: "fail", message: "Item not found"