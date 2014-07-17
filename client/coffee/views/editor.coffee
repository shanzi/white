$ = require 'jquery'
utils = require '../utils'
Backbone = require 'backbone'
ArticleView = require './article'

EditorView = Backbone.View.extend
  initialize: ->
    @articleView = new ArticleView({el: @$el.find('article').get(0)})

module.exports = EditorView
