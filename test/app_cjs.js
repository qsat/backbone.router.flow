(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Deferred, Router, pageobj, r, wait;

Deferred = $.Deferred;

wait = function(ms) {
  var d, tid;
  d = new Deferred();
  tid = setTimeout((function() {
    return d.resolve();
  }), ms);
  d.name = "wait" + ms;
  d.fail(function() {
    return clearTimeout(tid);
  });
  return d;
};

pageobj = {
  enter: function() {
    var d;
    d = wait(800);
    console.log("    process enter", [r.url, r.prevUrl], arguments);
    return d.fail((function(_this) {
      return function() {
        return console.log("       ( interrupt process enter )");
      };
    })(this));
  },
  leave: function() {
    var d;
    d = wait(800);
    console.log("    process leave", [r.url, r.prevUrl]);
    return d.fail((function(_this) {
      return function() {
        return console.log("       ( interrupt process leave )");
      };
    })(this));
  }
};

Router = Backbone.Router.extend({
  routes: {
    '': pageobj,
    'post/': pageobj,
    'post/:id': pageobj
  },
  firstTime: function() {
    console.log("first time executed");
    console.log("wait 2000ms");
    return wait(2000);
  },
  beforeEachEnter: function() {
    return console.log("-- each time executed", this.url, this.prevUrl);
  },
  afterEachEnter: function() {
    return console.log("-- each time AFTER executed", this.url, this.prevUrl);
  }
});

r = new Router();

Backbone.history.start({
  pushState: false
});

wait(4000).done(function() {
  return r.navigate("/post/");
}).then(function() {
  return wait(4500);
}).done(function() {
  return r.navigate("/post/2");
}).then(function() {
  return wait(4500);
}).done(function() {
  return r.navigate("/");
});

return r;


},{}]},{},[1])