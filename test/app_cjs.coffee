#browserify -t coffeeify app_cjs.coffee > app_cjs.js   

Brf = require "../backbone.router.flow"

wait = (ms) ->
  d = new $.Deferred()
  tid = setTimeout (-> d.resolve()), ms
  d.name = "wait"+ms
  d.fail ->
    clearTimeout tid
    console.log d.name, "rejected"
  d

pageobj =
  enter: (args)->
    d = wait 800
    {url, prevUrl} = args
    console.log "    process enter", [url, prevUrl], arguments
    d.fail => console.log "       ( interrupt process enter )"
  leave: (args)->
    {url, prevUrl} = args
    d = wait 800
    console.log "    process leave", [url, prevUrl]
    d.fail => console.log "       ( interrupt process leave )"


new Brf(
  ''        : pageobj 
  'post/'   : pageobj 
  'post/:id': pageobj 
).start pushState:false

navigate = (path)-> Backbone.history.navigate path, true

seq = wait(2000)
  .done( -> navigate "/post/" )
  .then( ->
    d = wait 1500 
    #d.reject("!!!!!")
  )
  .done( -> navigate "/post/1", true)
  .then( (-> wait 2500 ), -> console.log arguments)
  .done( -> navigate "/post/2")
  .then( -> wait 1100 )
  .done( -> navigate "/#" )



