$ = require 'jquery'
_ = require 'underscore'
utils = require '../utils'
Backbone = require 'backbone'


template = _.template '''
<div class="options">
  <div>
  <button class="link">a</button>
  <button class="bold">B</button>
  <button class="italic">I</button>
  <button class="underline">U</button>
  <button class="header">h</button>
  <button class="quote">“</button>
  <button class="comment">c</button>
  </div>
</div>
'''

PopupView = Backbone.View.extend
  tagName: 'div'
  article: null
  template: template
  className: 'white-popup hidden'
  composing: false
  
  initialize: ->
    $(document).on 'compositionstart', => @composing = true
    $(document).on 'compositionend', => @composing = false
    $(window).on 'resize', => @windowResizing()
    $(document.body).on 'mouseup', => @checkTextSelection()
    @render()

  render: _.once ->
    @$el.html(@template())
    $(document.body).append(@el)

  moveTo: (x, y) ->
    @$el.offset {left:x, top: y}

  toggleDisplay: utils.debounce 200, (show, x, y) ->
    if show
      if @$el.hasClass('hidden')
        @moveTo x, y
        @$el.removeClass('hidden')
      else
        offset = @$el.offset()
        if Math.abs(offset.left - x) > 100 or Math.abs(offset.top - y) > 100
          @$el.addClass('hidden')
          utils.delay 150, => @toggleDisplay(show, x, y) if show
        else
          @moveTo x, y
    else
      @$el.addClass('hidden')
      utils.delay 150, => @moveTo -999, -999

  showAtPoint: (x, y) ->
    @toggleDisplay true, x, y

  hide: ->
    @toggleDisplay false

  checkTextSelection: ()->
    selection = window.getSelection()
    if selection.isCollapsed == false and @composing == false
      range = selection.getRangeAt(0)
      if $(range.commonAncestorContainer).closest('.white article').length > 0
        [x, y] = @positionForRange(range)
        @showAtPoint(x, y)
        return
    @hide()

  positionForRange: (range) ->
    range ?= window.getSelection().getRangeAt(0)
    boundary = range.getBoundingClientRect()
    x = (boundary.left + boundary.right)/2
    y = boundary.top + window.pageYOffset - 60
    console.log y
    return [x, y]

  windowResizing: ->
    [x, y] = @positionForRange()
    @moveTo(x, y)


sharedPopup = new PopupView()

exports.show = ->
  sharedPopup.checkTextSelection()

exports.hide = ->
  sharedPopup.hide()
