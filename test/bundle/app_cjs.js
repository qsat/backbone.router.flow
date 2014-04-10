(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var BackboneRouterFlow, Deferred;

  Deferred = $.Deferred;

  BackboneRouterFlow = (function() {
    BackboneRouterFlow.prototype.defs = [];

    BackboneRouterFlow.prototype.visited = [];

    BackboneRouterFlow.prototype.debug = true;

    function BackboneRouterFlow(route) {
      var r;
      this.router = r = new Backbone.Router();
      _.each(route, (function(_this) {
        return function(e, i) {
          return r.route(i, "inner_routes_" + i, function(arg) {
            return _this.activate(e, arg);
          });
        };
      })(this));
    }

    BackboneRouterFlow.prototype.start = function(opt) {
      if (opt == null) {
        opt = null;
      }
      return Backbone.history.start(opt);
    };

    BackboneRouterFlow.prototype.getCurrentUrl = function(l) {
      if (l == null) {
        l = location;
      }
      return l.pathname.replace(Backbone.history.root, "/") + l.search + l.hash;
    };

    BackboneRouterFlow.prototype.pushDefer = function(defer) {
      if (defer && defer.done) {
        this.defs.push(defer);
        return defer;
      } else {
        return new Deferred().resolve();
      }
    };

    BackboneRouterFlow.prototype.log = function() {
      if (this.debug) {
        return console.log.apply(console, arguments);
      }
    };

    BackboneRouterFlow.prototype.isFirstTime = function() {
      return this.prevDefer === void 0;
    };

    BackboneRouterFlow.prototype.navigate = function(fragment, interrupt, options) {
      if (options == null) {
        options = true;
      }
      if (interrupt === true) {
        this.interrupt();
      }
      Backbone.history.navigate(fragment, options);
      return this;
    };

    BackboneRouterFlow.prototype.activate = function(c, args) {
      var defer, hasPrev, url, _args;
      if (args == null) {
        args = null;
      }
      this.log("\n=================", this.url = url = this.getCurrentUrl());
      this.prevDefer = this.pushDefer(this.isFirstTime() ? typeof this.firstTime === "function" ? this.firstTime(c, url) : void 0 : this.prevDefer);
      _args = {
        args: args,
        url: url,
        prevView: this.prevObj,
        prevUrl: this.prevUrl,
        router: this,
        view: c
      };
      hasPrev = this.prevUrl || this.prevObj;
      defer = this.prevDefer.then((function(_this) {
        return function() {
          if (!hasPrev) {
            return;
          }
          _this.log("  LEAVING", _this.prevUrl);
          return _this.pushDefer(typeof _this.beforeEachLeave === "function" ? _this.beforeEachLeave.apply(_this, [_args]) : void 0);
        };
      })(this)).then((function(_this) {
        return function() {
          var d, _ref;
          if (!hasPrev) {
            return;
          }
          d = _this.pushDefer((_ref = _this.prevObj) != null ? typeof _ref.leave === "function" ? _ref.leave.apply(_ref, [_args]) : void 0 : void 0);
          return d.done(function() {
            return _this.log("  LEAVED", _this.prevUrl);
          });
        };
      })(this)).then((function(_this) {
        return function() {
          if (!hasPrev) {
            return;
          }
          return _this.pushDefer(typeof _this.afterEachLeave === "function" ? _this.afterEachLeave.apply(_this, [_args]) : void 0);
        };
      })(this)).then((function(_this) {
        return function() {
          return _this.pushDefer(typeof _this.beforeEachEnter === "function" ? _this.beforeEachEnter.apply(_this, [_args]) : void 0);
        };
      })(this)).then((function(_this) {
        return function() {
          var d;
          _this.log("  ENTERING", url);
          d = _this.pushDefer(c != null ? typeof c.enter === "function" ? c.enter.apply(c, [_args]) : void 0 : void 0);
          return d.done(function() {
            return _this.log("  ENTERED", url);
          });
        };
      })(this)).then((function(_this) {
        return function() {
          var d;
          d = _this.pushDefer(typeof _this.afterEachEnter === "function" ? _this.afterEachEnter.apply(_this, [_args]) : void 0);
          _this.prevObj = null;
          _this.prevUrl = url;
          return d;
        };
      })(this));
      return this.prevDefer = defer.done((function(_this) {
        return function() {
          _this.prevObj = c;
          _this.visited.push(_args);
          return _this.log("------- ACTIVATED " + url + "\n\n");
        };
      })(this));
    };

    BackboneRouterFlow.prototype.interrupt = function() {
      this.defs = _.filter(this.defs, function(i) {
        return (i != null ? typeof i.state === "function" ? i.state() : void 0 : void 0) === 'pending';
      });
      if (this.defs.length === 0) {
        return;
      }
      this.log("------ Interrupted " + this.prevUrl, this.defs.map(function(i) {
        return i.name + '::' + i.state();
      }));
      _.each(this.defs, function(j) {
        return j.reject();
      });
      this.prevObj = null;
      return this.prevDefer = new Deferred().resolve();
    };

    return BackboneRouterFlow;

  })();

  module.exports = BackboneRouterFlow;

}).call(this);

},{}],2:[function(require,module,exports){
(function() {
  var Brf, navigate, pageobj, seq, wait;

  Brf = require("../backbone.router.flow");

  wait = function(ms) {
    var d, tid;
    d = new $.Deferred();
    tid = setTimeout((function() {
      return d.resolve();
    }), ms);
    d.name = "wait" + ms;
    d.fail(function() {
      clearTimeout(tid);
      return console.log(d.name, "rejected");
    });
    return d;
  };

  pageobj = {
    enter: function(args) {
      var d, prevUrl, url;
      d = wait(800);
      url = args.url, prevUrl = args.prevUrl;
      console.log("    process enter", [url, prevUrl], arguments);
      return d.fail((function(_this) {
        return function() {
          return console.log("       ( interrupt process enter )");
        };
      })(this));
    },
    leave: function(args) {
      var d, prevUrl, url;
      url = args.url, prevUrl = args.prevUrl;
      d = wait(800);
      console.log("    process leave", [url, prevUrl]);
      return d.fail((function(_this) {
        return function() {
          return console.log("       ( interrupt process leave )");
        };
      })(this));
    }
  };

  new Brf({
    '': pageobj,
    'post/': pageobj,
    'post/:id': pageobj
  }).start({
    pushState: false
  });

  navigate = function(path) {
    return Backbone.history.navigate(path, true);
  };

  seq = wait(2000).done(function() {
    return navigate("/post/");
  }).then(function() {
    var d;
    return d = wait(1500);
  }).done(function() {
    return navigate("/post/1", true);
  }).then((function() {
    return wait(2500);
  }), function() {
    return console.log(arguments);
  }).done(function() {
    return navigate("/post/2");
  }).then(function() {
    return wait(1100);
  }).done(function() {
    return navigate("/#");
  });

}).call(this);

},{"../backbone.router.flow":1}]},{},[2]);