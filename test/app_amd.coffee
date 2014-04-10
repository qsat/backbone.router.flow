define [
  'backbone'
  'backbone.router.flow'
  ],
  (Backbone)->
    Deferred = $.Deferred

    wait = (ms) ->
      d = new Deferred()
      tid = setTimeout (-> d.resolve()), ms
      d.name = "wait"+ms
      d.fail -> clearTimeout tid
      d

    pageobj =
      enter: ->
        d = wait 800
        console.log "    process enter", [r.url, r.prevUrl], arguments
        d.fail => console.log "       ( interrupt process enter )"
      leave: ->
        d = wait 800
        console.log "    process leave", [r.url, r.prevUrl]
        d.fail => console.log "       ( interrupt process leave )"

 
    Router = Backbone.Router.extend

      routes:
        ''        : pageobj
        'post/'   : pageobj
        'post/:id': pageobj

      firstTime: ->
        console.log "first time executed"
        console.log "wait 2000ms"
        wait 2000

      beforeEachEnter: ->
        console.log "-- each time executed", @url, @prevUrl

      afterEachEnter: ->
        console.log "-- each time AFTER executed", @url, @prevUrl

     r = new Router()


     Backbone.history.start pushState: false


     wait(4000)
     .done( -> r.navigate "/post/" )
     .then( -> wait 4500 )
     #.done( -> r.navigate "/post/1", true)
     #.then( -> wait 2500 )
     .done( -> r.navigate "/post/2")
     .then( -> wait 4500 )
     .done( -> r.navigate "/" )

     return r

