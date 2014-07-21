$ = require 'jquery'
_ = require 'underscore'
utils = require '../utils'
Backbone = require 'backbone'


template = _.template '''
<div class="options">
  <div>
    <div class="group group-link">
      <div>
        <button class="link"><%= icon('chain') %></button>
        <input type="link" placeholder="http://example.com">
        <button class="confirm-link"><%= icon('circle-check') %></button>
        </input>
      </div>
    </div>
    <div class="group group-style">
      <div>
        <button class="bold"><%= icon('bold') %></button>
        <button class="italic"><%= icon('italic') %></button>
        <button class="underline"><%= icon('underline') %></button>
      </div>
    </div>
    <div class="group group-type">
      <div>
        <button class="header1"><%= icon('h1') %></button>
        <button class="header2"><%= icon('h2') %></button>
        <button class="quote"><%= icon('quote-left') %></button>
      </div>
    </div>
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
    @render()
    @options = @$el.find('.options')
    @linkInput = @options.find('.group-link input').first()
    $(document).on 'compositionstart', => @composing = true
    $(document).on 'compositionend', => @composing = false
    $(window).on 'resize', => @windowResizing()
    $(document.body).on 'mouseup', => @checkTextSelection()

  render: _.once ->
    @$el.html(@template(icon:utils.icon))
    $(document.body).append(@el)

  preparePopup: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    commonAncester = $(range.commonAncestorContainer)

    @options.removeClass('status-header').removeClass('status-link')
    @options.find('button').removeClass 'active'
    if commonAncester.closest('h1').length
      @options.find('.header1').addClass 'active'
      @switchToHeaderMode()
    else if commonAncester.closest('h2').length
      @options.find('.header2').addClass 'active'
      @switchToHeaderMode()
    else if commonAncester.closest('ul').length
      @options.find('.list-ul').addClass 'active'
    else if commonAncester.closest('ol').length
      @options.find('.list-ol').addClass 'active'
    else if commonAncester.closest('blockquote').length
      @options.find('.quote').addClass 'active'

    start = $(range.startContainer)
    end = $(range.endContainer)

    for _, obj of [start, end]
      if obj.closest('b').length
        @options.find('.bold').addClass 'active'
      if obj.closest('i').length
        @options.find('.italic').addClass 'active'
      if obj.closest('u').length
        @options.find('.underline').addClass 'active'

    link = commonAncester.closest('a')
    if link.length
      @options.find('.link').addClass 'active'
      url = link.attr('href')
      @linkInput.val(url)

  moveTo: (x, y) ->
    @$el.offset {left:x, top: y}

  toggleDisplay: utils.debounce 200, (show, x, y) ->
    if show
      if @$el.hasClass('hidden')
        @preparePopup()
        @moveTo x, y
        @$el.removeClass('hidden')
      else
        offset = @$el.offset()
        if Math.abs(offset.left - x) > 100 or Math.abs(offset.top - y) > 1
          @$el.addClass('hidden')
          utils.delay 150, => @toggleDisplay(show, x, y) if show
        else
          @moveTo x, y
    else
      @$el.addClass('hidden')
      utils.delay 150, =>
        @moveTo -999, -999
        @options.removeClass('status-link', 'status-header')

  showAtPoint: (x, y) ->
    @toggleDisplay true, x, y

  hide: ->
    @toggleDisplay false

  checkTextSelection: ()->
    selection = window.getSelection()
    if selection.isCollapsed == false and @composing == false
      range = selection.getRangeAt(0)
      if $(range.commonAncestorContainer).parent().closest('section').length > 0
        [x, y] = @positionForRange(range)
        @showAtPoint(x, y)
        return
    @hide()

  positionForRange: (range) ->
    range ?= window.getSelection().getRangeAt(0)
    boundary = range.getBoundingClientRect()
    x = (boundary.left + boundary.right)/2
    y = boundary.top + window.pageYOffset - 50
    return [x, y]

  windowResizing: ->
    [x, y] = @positionForRange()
    @moveTo(x, y)

  toggleLinkMode: ->
    @options.toggleClass 'status-link'
    if @options.hasClass 'status-link'
      utils.selection.save()
      utils.delay 150, => @linkInput.focus()
    else
      @linkInput.blur()
      utils.selection.restore()

  confirmLink: ->
    @toggleLinkMode()
    val = @linkInput.val().trim()
    if val
      console.log window.getSelection()
      document.execCommand 'createLink', false, val
    else
      document.execCommand 'unlink'

  showing: ->
    return not @$el.hasClass('hidden')

  switchToHeaderMode: ->
    @options.removeClass('status-link').addClass('status-header')

  textStyle: (e) ->
    target = $(e.currentTarget)
    for _, classname of ['bold', 'italic', 'underline']
      if target.hasClass classname
        document.execCommand classname
        break
    @preparePopup()

  blockType: (e) ->
    target = $(e.currentTarget)
    tag = 'p'
    if not target.hasClass 'active'
      if target.hasClass 'header1'
        tag = 'h1'
      else if target.hasClass 'header2'
        tag = 'h2'
      else if target.hasClass 'quote'
        tag = 'blockquote'
      document.execCommand 'formatBlock', false, 'p'
    document.execCommand 'outdent'
    document.execCommand 'formatBlock', false, tag
    @preparePopup()

  eventMask: ->
    return false

  events:
    'mouseup': 'eventMask'
    'click .link': 'toggleLinkMode'
    'click .confirm-link' : 'confirmLink'
    'click .group-style button' : 'textStyle'
    'click .group-type button' : 'blockType'


sharedPopup = new PopupView()

exports.show = ->
  sharedPopup.checkTextSelection()

exports.hide = ->
  sharedPopup.hide()

exports.showing = ->
  sharedPopup.showing()
