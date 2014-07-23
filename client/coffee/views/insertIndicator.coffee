$ = require 'jquery'
_ = require 'underscore'
utils = require '../utils'
Backbone = require 'backbone'

template = _.template """<%= icon('circle-plus') %>"""

InsertIndicatorView = Backbone.View.extend
  tagName: 'div'
  className: 'white-insert-indicator hidden'

  initialize: -> @render()

  render: ->
    @$el.html(template(icon:utils.icon))
    @$el.appendTo 'body'

  observe: (headerView, articleView) ->
    @headerView = headerView
    @articleView = articleView
    @headerView.$el.on 'mouseover',(e) => @showForElem e.currentTarget
    @articleView.$el.on 'mouseover', '>*', (e) => @showForElem e.currentTarget
    @headerView.$el.on 'mouseout', (e) => @hideIndicator()
    @articleView.$el.on 'mouseout', '>*',(e) => @hideIndicator()
    @articleView.$el.on 'mousedown',(e) => @hideIndicator()

  showForElem: (elem) ->
    clearTimeout(@hideTimeout)
    topFix = 10
    topFix = 0 if elem.tagName.toLowerCase() in ['h1', 'h2']
    @showingElem = $(elem)
    offset = @showingElem.offset()
    @$el.offset
      left: offset.left - @$el.width() - 5
      top: offset.top + @showingElem.height() - @$el.height()/2 + topFix
    @$el.removeClass 'hidden'

  hideIndicator: ->
    clearTimeout @hideTimeout
    @$el.addClass('hidden')
    @hideTimeout = setTimeout (=>
      @showingElem = null
      @$el.offset {left:-999, height:-999}
      ), 2500

  mouseOverEvent: ->
    clearTimeout @hideTimeout
    @$el.removeClass 'hidden'

  addParagraph: ->
    if @showingElem.length
      elem = @showingElem.get(0)
      if elem == @headerView.el
        @articleView.insertParagraphAfter(null)
      else
        @articleView.insertParagraphAfter(elem)
    return false

  events:
    'mouseover': 'mouseOverEvent'
    'mouseout': 'hideIndicator'
    'click': 'addParagraph'

module.exports = InsertIndicatorView
