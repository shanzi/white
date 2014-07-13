gulp = require 'gulp'

gutil = require 'gulp-util'
stylus = require 'gulp-stylus'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
nodemon = require 'gulp-nodemon'

source = require 'vinyl-source-stream'
browserify = require 'browserify'


BUILD = './build'

BUILD_SERVER = "#{BUILD}/server"
BUILD_CLIENT = "#{BUILD}/client"


gulp.task 'client:coffee', () ->
  browserify()
    .require('./bower_components/underscore/underscore.js', {expose: 'underscore'})
    .require('./bower_components/backbone/backbone.js', {expose: 'backbone'})
    .require('./bower_components/jquery/dist/jquery.js', {expose: 'jquery'})
    .add('./client/coffee/main.coffee')
    .transform('coffeeify')
    .bundle({debug: true})
    .pipe(source('client.js'))
    .pipe(gulp.dest("#{BUILD_CLIENT}/js"))
  
gulp.task 'client:stylus',  () ->
  gulp.src('./client/stylus/**/*.styl')
    .pipe(stylus())
    .pipe(concat('style.css'))
    .pipe(gulp.dest("#{BUILD_CLIENT}/css"))

gulp.task 'server:coffee', () ->
  gulp.src('./server/**/*.coffee')
    .pipe(coffee({bare:true}).on('error', gutil.log))
    .pipe(gulp.dest(BUILD_SERVER))

gulp.task 'client', ['client:coffee', 'client:stylus']
gulp.task 'server', ['server:coffee']

gulp.task 'nodemon', ['server'] ,() ->
  nodemon({
    script: './build/server/app.js'
    ignore: ['./build/client/*']
    ext: 'js'
    env: {
      DEVELOPMENT: true
      PORT: 8000
    }
  })

gulp.task 'build', ['client', 'server']
gulp.task 'default', ['client', 'nodemon']

