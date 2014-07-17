$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

do _.once () ->
  Backbone.$ = $
  EditorView = require './views/editor'
  editorView = new EditorView({el: $('.white').get(0)})

