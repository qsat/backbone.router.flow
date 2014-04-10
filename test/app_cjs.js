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
