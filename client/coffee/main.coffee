$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

do _.once () ->
  Backbone.$ = $
  EditorView = require './editor.coffee'
  editorView = new EditorView({el: $('.white').get(0)})

