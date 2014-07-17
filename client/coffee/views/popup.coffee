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
    y -= @$el.height() + 5
    @$el.offset {left:x, top:y}

  toggleDisplay: utils.debounce 300, (show, x, y) ->
    if show and @$el.hasClass('hidden')
      @moveTo x, y
      @$el.removeClass('hidden')
    else
      @$el.addClass('hidden')
      utils.delay 250, =>
        @toggleDisplay(show, x, y) if show
        @moveTo -999, -999

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
    y = boundary.top + window.pageYOffset
    return [x, y]

  windowResizing: utils.throttle 70, ->
    [x, y] = @positionForRange()
    @moveTo(x, y)


sharedPopup = new PopupView()

exports.show = ->
  sharedPopup.checkTextSelection()

exports.hide = ->
  sharedPopup.hide()
