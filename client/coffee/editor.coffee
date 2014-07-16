$ = require 'jquery'
Backbone = require 'backbone'
PopupView = require './popup.coffee'
utils = require './utils.coffee'


EditorView = Backbone.View.extend

  initialize: ->
    @composing = false
    @popupView = new PopupView()
    $(document).on 'compositionstart', => @composing = true
    $(document).on 'compositionend', => @composing = false
    $(window).on 'resize', => @windowResizing()

  events:
    'mouseup': 'checkTextSelection'
    'mousedown': 'checkTextSelection'

  checkTextSelection: (e) ->
    selection = window.getSelection()
    
    if selection.isCollapsed == false and @composing == false
      if @$el.has(selection.focusNode)
        [x, y] = @positionForSelection(selection)
        @popupView.showAtPoint(x, y)
    else
      @popupView.hide()

  positionForSelection: (selection) ->
    selection ?= window.getSelection()
    range = selection.getRangeAt(0)
    boundary = range.getBoundingClientRect()
    x = (boundary.left + boundary.right)/2
    y = boundary.top + window.pageYOffset
    return [x, y]

  windowResizing: utils.throttle 70, ->
    [x, y] = @positionForSelection()
    @popupView.moveTo(x, y)

module.exports = EditorView
