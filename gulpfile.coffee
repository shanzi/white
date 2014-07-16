gulp = require 'gulp'

gutil = require 'gulp-util'
stylus = require 'gulp-stylus'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
nodemon = require 'gulp-nodemon'

mold = require 'mold-source-map'
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
    .pipe(mold.transform(
      (sourcemap, callback) ->
        sourcemap.sourceRoot('file://')
        callback(sourcemap.toComment())
    ))
    .pipe(source('client.js'))
    .pipe(gulp.dest("#{BUILD_CLIENT}/js"))
  
gulp.task 'client:stylus',  () ->
  gulp.src('./client/stylus/main.styl')
    .pipe(stylus())
    .pipe(concat('style.css'))
    .pipe(gulp.dest("#{BUILD_CLIENT}/css"))

gulp.task 'client:resource', () ->
  gulp.src('./client/index.html')
    .pipe(gulp.dest(BUILD_CLIENT))

gulp.task 'server:coffee', () ->
  gulp.src('./server/**/*.coffee')
    .pipe(coffee({bare:true}).on('error', gutil.log))
    .pipe(gulp.dest(BUILD_SERVER))

gulp.task 'client', ['client:coffee', 'client:stylus', 'client:resource']
gulp.task 'server', ['server:coffee']

gulp.task 'watch', () ->
  gulp.watch ['./client/stylus/**/*.styl'], ['client:stylus']
  gulp.watch ['./client/coffee/**/*.coffee'], ['client:coffee']
  gulp.watch ['./server/**/*.coffee'], ['server:coffee']
  gulp.watch ['./client/index.html'], ['client:resource']
  return

gulp.task 'nodemon', ['server'] ,() ->
  nodemon({
    script: './build/server/app.js'
    watch: 'build/server/**/*.js'
    ext: 'js'
    env: {
      DEVELOPMENT: true
      PORT: 8000
    }
  })

gulp.task 'build', ['client', 'server']
gulp.task 'default', ['client', 'nodemon', 'watch']

