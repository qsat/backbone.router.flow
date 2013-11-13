  do (window, document, jQuery, Backbone)->
    $ = jQuery
    Deferred = $.Deferred

    Backbone.Router = Backbone.Router.extend
      defs: []
      visited: []
      pushDefer: (defer)->
        @defs.push defer
        defer

      debug: true
      log: -> console.log.apply console, arguments if @debug

      
      isFirstTime: -> @prevDefer is undefined

      getPrevDefer: ->
        d = @firstTime?() if @isFirstTime()
        (@prevDefer || new Deferred().resolve()).then -> d


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

        @prevDefer = @getPrevDefer()

        defer = @prevDefer
          .then =>
            return if not @prevObj
            @log "  LEAVING", @prevUrl if @prevUrl
            d = @pushDefer @prevObj?.leave(@)
            d?.done => @log "  LEAVED", @prevUrl

          .then =>
            @pushDefer @beforeEach?(c, url, @prevUrl)

          .then =>
            @log "  ENTERING", url
            d = @pushDefer c.enter.apply c, Array::concat([@], args)
            d?.done? => @log "  ENTERED", url

          .then =>
            d = @pushDefer @afterEach?(c, url)
            @prevObj = null
            @prevUrl = url
            @visited.push url
            d

        if not defer
          defer = c.enter.apply c, Array::concat([@], args)

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


