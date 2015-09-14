gulp     = require('gulp')
$        = require('gulp-load-plugins')()
connect  = require('gulp-connect')
pkg      = require('./package.json')
config   = require('./config.json')
pngquant = require('imagemin-pngquant')
jeet     = require('jeet')
del      = require('del')
vinylPaths = require('vinyl-paths')
runSequence = require('run-sequence')

path = 
  css:
    src: [
      './src/**/*.styl'
      "!**/icon-map-template.styl"
    ]
    dest: './app/assets/css'

  img:
    src: './src/graphics/images/**/*.{png,jpg,gif}'
    dest: './app/assets/img'

  sprites:
    src: './src/graphics/sprites/**/*.png'
    dest:
      css: './src/base-styles'

  scripts:
    plugins: './src/**/*.js'
    coffee: './src/**/*.coffee'
    dest: './app/assets/js'

  jade:
    all: './src/**/*.jade'
    pages: './src/components/*.jade'
    dest: './app/'


  iconFont:
    src: './src/graphics/icon-font/*.svg'
    css:
      template: './src/base-styles/icon-map-template.styl' 
      src: '../../../src/base-styles/icon-map.styl'
    dest: './app/assets/fonts'



gulp.task 'clean', -> 
  gulp.src('./app/*')
    .pipe(vinylPaths(del))


gulp.task 'icon-font', ->
  gulp.src(path.iconFont.src, {base: './app/assets'})
    .pipe($.imagemin())
    .pipe($.iconfontCss(
      fontName: pkg.name + '-icon-font'
      path: path.iconFont.css.template
      targetPath: path.iconFont.css.src
      fontPath: '../fonts/'
    ))
    .pipe($.iconfont(
      fontName: pkg.name + '-icon-font'
      normalize: on
    ))
    .pipe(gulp.dest(path.iconFont.dest))
    .pipe($.livereload())



gulp.task 'jade', ->
  gulp.src(path.jade.pages)
    .pipe($.plumber())
    .pipe($.jade())
    .pipe($.htmlmin())
    .pipe(gulp.dest(path.jade.dest))
    .pipe($.livereload())



gulp.task 'styles', ->
  gulp.src(path.css.src)
    .pipe($.plumber())
    .pipe($.concat(pkg.name + '-styles.styl'))
    .pipe(gulp.dest('temp/' + pkg.name + '-styles.styl'))
    .pipe($.stylus(
      use: [jeet()]
    ))
    .pipe($.autoprefixer())
    .pipe(gulp.dest(path.css.dest))
    .pipe($.livereload())
    .pipe($.cssmin())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.css.dest))
    .pipe($.livereload())



gulp.task 'img-minify', ->
  gulp.src(path.img.src)
    .pipe($.changed(path.img.dest))
    .pipe($.imagemin(
      optimizationLevel: 3
      progressive: on
      interlaced: on
      use: [pngquant()]
    ))
    .pipe(gulp.dest(path.img.dest))
    .pipe($.livereload())


gulp.task 'sprites', ->
  spriteData = gulp.src(path.sprites.src)
    .pipe($.spritesmith(
      imgName: pkg.name + '-sprite.png'
      imgPath: '../img/' + pkg.name + '-sprite.png'
      cssName: 'sprite-map.styl'
      padding: 2
      cssOpts: 
        variableNameTransforms: ['dasherize']
    ))

  spriteData.img
    .pipe($.imagemin(
      use: [pngquant()]
    ))
    .pipe(gulp.dest(path.img.dest))

  spriteData.css
    .pipe(gulp.dest(path.sprites.dest.css))


gulp.task 'plugins', ->
  gulp.src(path.scripts.plugins)
    .pipe($.concat(pkg.name + '-plugins.js'))
    .pipe(gulp.dest(path.scripts.dest))
    .pipe($.livereload())
    .pipe($.uglify())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.scripts.dest))
    .pipe($.livereload())


gulp.task 'coffee', ->
  gulp.src(path.scripts.coffee)
    .pipe($.plumber())
    .pipe($.concat(pkg.name + '-scripts.coffee'))
    .pipe($.coffee())
    .pipe(gulp.dest(path.scripts.dest))
    .pipe($.livereload())
    .pipe($.uglify())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.scripts.dest))
    .pipe($.livereload())



gulp.task 'webserver', ->
  connect.server
    root: 'app'
    host: config.server.host
    port: config.server.port
    middleware: (connect) ->
      return [
        (req, res, next) ->
          res.setHeader('Access-Control-Allow-Origin', '*');
          res.setHeader('Access-Control-Allow-Methods', '*');
          next()
      ]


gulp.task 'watch', ->
  $.livereload.listen(
     quiet: on
     )

  $.watch(path.css.src, $.batch (cb) ->
    gulp.start('styles')
    cb()
  )
  $.watch(path.img.src, $.batch (cb) ->
    gulp.start('img-minify')
    cb()
  )
  $.watch(path.sprites.src, $.batch (cb) ->
    gulp.start('sprites')
    cb()
  )
  $.watch(path.scripts.plugins, $.batch (cb) ->
    gulp.start('plugins')
    cb()
  )
  $.watch(path.scripts.coffee, $.batch (cb) ->
    gulp.start('coffee')
    cb()
  )
  $.watch(path.jade.all, $.batch (cb) ->
    gulp.start('jade')
    cb()
  )
  $.watch(path.iconFont.src, $.batch (cb) ->
    gulp.start('iconFont')
    cb()
  )



gulp.task 'build', (callback) ->
  runSequence(
    'clean'
    [
      'icon-font'
      'img-minify'
      'sprites'
      'plugins'
      'coffee'
    ]
    'jade'
    'styles'
    callback
  )

gulp.task 'server', [
  'build'
  'watch'
  'webserver'
]

gulp.task 'default', ['server']
