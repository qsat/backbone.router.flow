Deferred = $.Deferred
#namedParam    = /:\w+/g
#splatParam    = /\*\w+/g
#escapeRegExp  = /[-[\]{}()+?.,\\^$|#\s]/g
#
#  _routeToRegExp: (route) ->
#    route = route.replace(escapeRegExp, '\\$&')
#                 .replace(namedParam, '([^\/]+)')
#                 .replace(splatParam, '(.*?)')
#    new RegExp '^' + route + '$'

class BackboneRouterFlow

  defs: []
  visited: []
  debug: true
  
  constructor: (route)->
    @router = r = new Backbone.Router()
    _.each route, (e, i) =>
      r.route i, "inner_routes_#{i}", (arg)=> @activate e, arg

  start: (opt = null) -> Backbone.history.start opt

  getCurrentUrl: (l = location)->
    l.pathname.replace(Backbone.history.root, "/")+l.search+l.hash

  pushDefer: (defer)->
    if defer and defer.done
      @defs.push defer
      defer
    else
      new Deferred().resolve()

  log: -> console.log arguments... if @debug
  
  isFirstTime: -> @prevDefer is undefined

  navigate: (fragment, interrupt, options=true) ->
    @interrupt() if interrupt is true
    Backbone.history.navigate(fragment, options)
    @

  activate: (c, args = null) ->
    @log "\n=================", @url = url = @getCurrentUrl()

    @prevDefer = @pushDefer if @isFirstTime() then @firstTime?(c, url) else @prevDefer

    _args = args: args, url: url, prevView: @prevObj, prevUrl: @prevUrl, router: @, view: c
    hasPrev = @prevUrl or @prevObj

    defer = @prevDefer
      .then =>
        return unless hasPrev
        @log "  LEAVING", @prevUrl
        @pushDefer @beforeEachLeave? [_args]...

      .then =>
        return unless hasPrev
        d = @pushDefer @prevObj?.leave? [_args]...
        d.done => @log "  LEAVED", @prevUrl

      .then =>
        return unless hasPrev
        @pushDefer @afterEachLeave? [_args]...
        
      .then =>
        @pushDefer @beforeEachEnter? [_args]...

      .then =>
        @log "  ENTERING", url
        d = @pushDefer c?.enter? [_args]...
        d.done => @log "  ENTERED", url

      .then =>
        d = @pushDefer @afterEachEnter? [_args]...
        @prevObj = null
        @prevUrl = url
        d

    @prevDefer = defer.done =>
      @prevObj = c
      @visited.push _args
      @log "------- ACTIVATED #{url}\n\n"

  interrupt: ->
    @defs = _.filter @defs, (i)-> i?.state?() is 'pending'

    return if @defs.length == 0

    @log "------ Interrupted #{@prevUrl}", @defs.map (i)->
      i.name + '::' + i.state()

    _.each @defs, (j) -> j.reject()
    @prevObj = null
    @prevDefer = new Deferred().resolve()

module.exports = BackboneRouterFlow

