"use strict"
LIVERELOAD_PORT = 35729
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    project:
      src: "./src"
      app: "./app"
      temp: "./temp"
      assets: "<%= project.app %>/assets"
      styles: "<%= project.src %>/styles/{,*/}*.styl"
      components: "<%= project.src %>/scripts/components/{,*/}*.coffee"
      plugins: "<%= project.src %>/scripts/plugins/{,*/}*.js"
      views: "<%= project.src %>/views/{,*/}*.html"
      sprites: "<%= project.assets %>/img/sprite/{,*/}*.png"

    tag:
      banner: "/*!\n" + " * <%= pkg.name %>\n" + " * <%= pkg.title %>\n" + " * @author <%= pkg.author %>\n" + " * <%= pkg.url %>\n" + " */\n"

    connect:
      options:
        port: 9000
        hostname: "127.0.0.1"

      livereload:
        options:
          middleware: (connect) ->
            [
              lrSnippet
              mountFolder(connect, "app")
            ]

    clean: [
      "<%= project.temp %>/"
      "<%= project.assets %>/css/"
      "<%= project.assets %>/js/"
    ]

    concat:
      plugins:
        src: ["<%= project.plugins %>"]
        dest: "<%= project.temp %>/temp-plugins.js"

      components:
        src: ["<%= project.components %>"]
        dest: "<%= project.temp %>/temp-components.coffee"

      styles:
        src: [
          "<%= project.src %>/styles/settings.styl"
          "<%= project.src %>/styles/base/mixins.styl"
          "<%= project.src %>/styles/base/sprite-map.styl"
          "<%= project.src %>/styles/base/extends.styl"
          "<%= project.src %>/styles/base/fonts.styl"
          "<%= project.src %>/styles/base/reset.styl"
          "<%= project.src %>/styles/base/defaults.styl"
          "<%= project.src %>/styles/base/layout.styl"
          "<%= project.src %>/styles/components/{,*/}*.styl"
        ]
        dest: "<%= project.temp %>/temp-styles.styl"

      options:
        stripBanners: true
        nonull: true

    coffee:
      components:
        src: ["<%= concat.components.dest %>"]
        dest: "<%= project.temp %>/temp-components.js"

    uglify:
      plugins:
        src: ["<%= concat.plugins.dest %>"]
        dest: "<%= project.assets %>/js/<%= pkg.name %>-plugins.min.js"

      components:
        src: ["<%= coffee.components.dest %>"]
        dest: "<%= project.assets %>/js/<%= pkg.name %>-components.min.js"

      options:
        sourceMap: yes

    stylus:
      styles:
        src: ["<%= concat.styles.dest %>"]
        dest: "<%= project.temp %>/temp-styles.css"

        options:
          paths: [
            "<%= project.assets %>/css/"
            "<%= project.assets %>/fonts/"
            "<%= project.assets %>/img/"
            "node_modules/jeet/stylus/"
          ]
          import: [
            "jeet"
          ]
          compress: no
          urlfunc: "data"

    autoprefixer:
      styles:
        src: ["<%= stylus.styles.dest %>"]
        dest: "<%= project.assets %>/css/<%= pkg.name %>-styles.css"

        options:
          browsers: [
            "last 2 version"
            "ie 9"
          ]

    cssmin:
      styles:
        src: [
          "<%= pkg.name %>-styles.css"
        ]
        cwd: "<%= project.assets %>/css/"
        dest: "<%= project.assets %>/css/"
        ext: ".min.css"
        expand: true

    includes:
      files:
        cwd: "<%= project.src %>/views"
        src: ["*.html"]
        dest: "<%= project.app %>"
        options:
          flatten: true
          silent: true
          filenameSuffix: ".html"


    sprite:
      images:
        src: ['<%= project.sprites %>']
        destImg: '<%= project.assets %>/img/<%= pkg.name %>-sprite.png'
        destCSS: '<%= project.src %>/styles/base/sprite-map.styl'
        imgPath: '../img/<%= pkg.name %>-sprite.png'
        algorithm: 'binary-tree'
        padding: 2
        engine: 'pngsmith'
        cssFormat: 'stylus'

    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"

    watch:
      stylus:
        files: "<%= project.styles %>"
        tasks: ["process-styles"]

      plugins:
        files: "<%= project.plugins %>"
        tasks: ["process-plugins"]

      components:
        files: "<%= project.components %>"
        tasks: ["process-components"]

      includes:
        files: "<%= project.views %>"
        tasks: ["process-html"]

      sprites:
        files: "<%= project.sprites %>"
        tasks: ["process-images"]

      livereload:
        options:
          livereload: LIVERELOAD_PORT

        files: ["<%= project.app %>/**"]

  grunt.registerTask "process-html", [
    "includes"
  ]
  grunt.registerTask "process-images", [
    "sprite"
  ]
  grunt.registerTask "process-styles", [
    "concat:styles"
    "stylus"
    "autoprefixer"
    "cssmin"
  ]
  grunt.registerTask "process-plugins", [
    "concat:plugins"
    "uglify:plugins"
  ]
  grunt.registerTask "process-components", [
    "concat:components"
    "coffee"
    "uglify:components"
  ]
  grunt.registerTask "build", [
    "clean"
    "process-images"
    "concat"
    "process-styles"
    "process-html"
    "process-plugins"
    "process-components"
  ]
  grunt.registerTask "default", ["build"]
  grunt.registerTask "server", [
    "build"
    "connect:livereload"
    "open"
    "watch"
  ]
  return