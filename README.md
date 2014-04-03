backbone.router.flow
====================

SPAの構築を補助するシーン、遷移管理ライブラリ

Installation
============

```
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="http://underscorejs.org/underscore-min.js"></script>
<script src="http://backbonejs.org/backbone.js"></script>
<script src="https://raw.githubusercontent.com/qsat/backbone.router.flow/master/backbone.router.flow.js"></script>
```

or bower

```
bower install backbone.router.flow
```

Example
=======

Backbone.Routerをざっくり拡張してしまう。（課題）
Routerをextendしてこのように。
例は、require.js と使った場合。scriptタグで読み込んだ場合は、冒頭5行不要。

###app.coffee

```
define [
  'backbone'
  'backbone.router.flow'
  'scene/indexScene'
  'scene/aboutScene'
  ], (Backbone, flow, indexScene, aboutScene) ->

    AppRouter = Backbone.Router.extend
      debug: false
      routes:
        '': indexScene
        'about/': aboutScene
        'about/:id': aboutScene


      firstTime: ->
        # 初回同期ロード時のみ処理

      beforeEachEnter: (args) ->
        navView.setActive args
        indexScene.leave args

    # 下層への直リンク禁止
    location.replace('#/')

    r = new AppRouter()

    Backbone.history.start root: "/"
    Backbone.router = r
    r
```

###scene/indexScene.coffee
```
define [
  'jquery'
  'backbone'
  ], ($, Backbone) ->

    IndexScene = Backbone.View.extend

      enter: (args)->
        {prevUrl, url} = args
        @$el.fadeIn(2000).promise()

      leave: (args)->
        {prevUrl, url} = args
        @$el.eq(1).fadeOut().promise()

    new IndexScene el: '.container'
```

###scene/aboutScene.coffee
```
define [
  'jquery'
  'backbone'
  'scene/indexScene'
  ], ($, Backbone) ->

    AboutScene = Backbone.View.extend
      initialize: ->

      el: '.about'

      enter: (args)->
        {prevUrl, url} = args
        @$el.fadeIn( 1000 ).promise()

      leave: (args)->
        {prevUrl, url} = args
        @$el.hide().empty()

    new AboutScene
```
##処理フロー

1.「/」にアクセス 
2. indexSceneの「enter」メソッドが呼び出される
3. そのあと「/about」に遷移
4. indexSceneの「leave」が呼び出される
5. fadeOutのプロミスを待つ
6. aboutScene の「enter」が呼び出される

コンソールにもろもろデバッグ出力が出る
