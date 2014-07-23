$ = require 'jquery'
utils = require '../utils'
Backbone = require 'backbone'
ArticleView = require './article'
TitleView = require './title'
InsertIndicatorView = require './insertIndicator'

EditorView = Backbone.View.extend
  initialize: ->
    @articleView = new ArticleView el: @$el.find('article').get(0)
    @titleView = new TitleView el: @$el.find('header').get(0)
    @insertIndicatorView = new InsertIndicatorView()
    
    @insertIndicatorView.observe(@titleView, @articleView)



module.exports = EditorView
