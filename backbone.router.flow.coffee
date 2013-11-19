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
      log: -> console.log.apply console, arguments if @debug
      
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
              @activate.apply @, [name, fragments]

          @route i, name, callback

      navigate: (fragment, interrupt, options=true) ->
        @interrupt() if interrupt is true
        Backbone.history.navigate(fragment, options)
        @

      activate: (c, args = null) ->
        @log "\n=================", @url = url = @getCurrentUrl()

        @prevDefer = @pushDefer if @isFirstTime() then @firstTime?(c, url) else @prevDefer

        defer = @prevDefer
          .then =>
            return unless @prevUrl or @prevObj
            @log "  LEAVING", @prevUrl
            @pushDefer @beforeEachLeave?(@prevObj, url, @prevUrl)

          .then =>
            return unless @prevUrl or @prevObj
            d = @pushDefer @prevObj?.leave(@)
            d.done => @log "  LEAVED", @prevUrl

          .then =>
            return unless @prevUrl or @prevObj
            @pushDefer @afterEachLeave?(@, @prevObj, url, @prevUrl)
            
          .then =>
            @pushDefer @beforeEachEnter?(@, c, url, @prevUrl)

          .then =>
            @log "  ENTERING", url
            args = _.compact [].concat [@, args, c, url, @prevUrl]
            d = @pushDefer c.enter.apply c, args
            d.done => @log "  ENTERED", url

          .then =>
            d = @pushDefer @afterEachEnter?(@, c, url, @prevUrl)
            @prevObj = null
            @prevUrl = url
            @visited.push url
            d

        @prevDefer = defer.then =>
          @prevObj = c
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
