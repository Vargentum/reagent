gulp     = require('gulp')
$        = require('gulp-load-plugins')()
pkg      = require('./package.json')
config   = require('./config.json')
pngquant = require('imagemin-pngquant')
jeet     = require('jeet')
del      = require('del')
vinylPaths = require('vinyl-paths')


path = 
  css:
    src: [
      './src/{,**/}*.styl'
      "!**/icon-map-template.styl"
    ]
    dest: './app/assets/css'

  img:
    src: './src/graphics/images/{,**/}*.{png,jpg,gif}'
    dest: './app/assets/img'

  sprites:
    src: './src/graphics/sprites/{,**/}*.png'
    dest:
      css: './src/base-styles'

  scripts:
    plugins: './src/{,**/}*.js'
    coffee: './src/{,**/}*.coffee'
    dest: './app/assets/js'

  jade:
    all: './src/{,**/}*.jade'
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
      fontName: pkg.name + '-font'
      path: path.iconFont.css.template
      targetPath: path.iconFont.css.src
      fontPath: '../fonts/'
    ))
    .pipe($.iconfont(
      fontName: pkg.name + '-font'
      normalize: on
    ))
    .pipe(gulp.dest(path.iconFont.dest))



gulp.task 'jade', ->
  gulp.src(path.jade.pages)
    .pipe($.plumber())
    .pipe($.jade())
    .pipe($.htmlmin())
    .pipe(gulp.dest(path.jade.dest))



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
    .pipe($.cssmin())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.css.dest))



gulp.task 'img-retinafy', ->
  gulp.src(path.img.src)
    .pipe($.changed(path.img.dest))
    .pipe($.imageResize(
      width: '200%'
      height: '200%'
    ))
    .pipe($.rename(
      suffix: '_2x'
    ))
    .pipe($.imagemin(
      optimizationLevel: 3
      progressive: on
      interlaced: on
      use: [pngquant()]
    ))
    .pipe(gulp.dest(path.img.dest))


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
    .pipe($.imageResize(
      width: '200%'
      height: '200%'
    ))
    .pipe($.rename(
      suffix: '_2x'
    ))
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
    .pipe($.uglify())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.scripts.dest))


gulp.task 'coffee', ->
  gulp.src(path.scripts.coffee)
    .pipe($.plumber())
    .pipe($.concat(pkg.name + '-scripts.coffee'))
    .pipe($.coffee())
    .pipe(gulp.dest(path.scripts.dest))
    .pipe($.uglify())
    .pipe($.rename(
      suffix: '.min'
    ))
    .pipe(gulp.dest(path.scripts.dest))


gulp.task 'webserver', ->
  gulp.src('app')
    .pipe($.serverLivereload(
      livereload: on
      host: config.server.host
      port: config.server.port
    ))



gulp.task 'watch', ->
  $.watch(path.css.src, ->
    gulp.start 'styles'
  )
  $.watch(path.img.src, ->
    gulp.start 'img-retinafy'
    gulp.start 'img-minify'
  )
  $.watch(path.sprites.src, ->
    gulp.start 'sprites'
  )
  $.watch(path.scripts.plugins, ->
    gulp.start 'plugins'
  )
  $.watch(path.scripts.coffee, ->
    gulp.start 'coffee'
  )
  $.watch(path.jade.all, ->
    gulp.start 'jade'
  )
  $.watch(path.iconFont.src, ->
    gulp.start 'iconFont'
  )
  $.watch('./Gulpfile.coffee', ->
    gulp.start 'build'
  )


gulp.task 'build', [
  'clean'
  'jade'
  'styles'
  'icon-font'
  'img-retinafy'
  'img-minify'
  'sprites'
  'plugins'
  'coffee'
]

gulp.task 'server', [
  'build'
  'watch'
  'webserver'
]

gulp.task 'default', ['server']
