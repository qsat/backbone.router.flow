  do (window, document, jQuery, Backbone)->
    $ = jQuery
    Deferred = $.Deferred

    Backbone.Router = Backbone.Router.extend
      defs: []
      visited: []
      pushDefer: (defer)->
        if defer and defer.done
          @defs.push defer
          defer
        else
          new Deferred().resolve()

      debug: true
      log: -> console.log arguments... if @debug
      
      isFirstTime: -> @prevDefer is undefined

      getCurrentUrl: (l = location)->
        l.pathname.replace(Backbone.history.root, "/")+l.search+l.hash

      _bindRoutes: ->
        return if not @routes
        @routes = _.result @, 'routes'
        routes = _.keys @routes

        _.each routes, (i) =>
          name = @routes[i]
          if not _.isString name and not _.isFunction name
            callback = (fragments)=>
              @activate [name, fragments]...

          @route i, name, callback

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
        #@log @defs
        @defs = _.filter @defs, (i)-> i?.state?() is 'pending'

        return if @defs.length == 0

        @log "------ Interrupted #{@prevUrl}", @defs.map (i)->
          i.name + '::' + i.state()

        _.each @defs, (j) -> j.reject()
        @prevObj = null
        @prevDefer = new Deferred().resolve()
