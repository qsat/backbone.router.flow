module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-este-watch'
 
  grunt.initConfig

    esteWatch:
      options:
        dirs: ['test/*', '*']
        livereload:
          enabled: false
          port: 35729
          extensions: ['js', 'css']

      coffee: (filepath) -> ['coffee','browserify']

    connect:
      server:
        options:
          port: 8008
          hostname: '0.0.0.0'
          base: 'test'
          #open: true

    coffee:
      compile:
        expand: true
        flatten: false
        src: ['test/**/*.coffee']
        ext: '.js'
      lib:
         files: 
           'backbone.router.flow.js':'backbone.router.flow.coffee'

    browserify: 
      dist: 
        expand: true
        cwd: "test"
        src: 'app_cjs.js'
        dest: 'test/bundle'
        ext: '.js'
        options:
          debug: true
          #transform: ['deamdify', 'uglifyify']
          transform: ['coffeeify']
          #alias: ["./htdocs/zexy/shared/scripts/lib/jade/runtime.js:jade"]
          

  grunt.registerTask 'default', ['coffee', 'browserify', 'connect', 'esteWatch']
