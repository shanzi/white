$ = require 'jquery'
EditableBlockView = require './editableBlock'

TitleView = EditableBlockView.extend
  tagName: 'header'
  initialize: ->
    @render()
    @placeholder = @$el.children('.placeholder')
    @content = @$el.children('.content')
    $(document).on 'mouseup', (e) => @checkTextSelection()

  selectContent: ->
    selection = window.getSelection()
    range = document.createRange()
    node = @content.get(0)
    range.setStart(@content.get(0), 0)
    range.setEnd(@content.get(0), 0)
    selection.removeAllRanges()
    selection.addRange range

  requestEdit: () ->
    @_safeExec =>
      @content.attr 'contentEditable', true
      @content.focus()
    if not @content.text().trim()
      @selectContent()
    @startObserveMutation()
  
  resignEdit: ->
    @stopObserveMutation()
    @content.blur()
    @content.removeAttr 'contentEditable'

  releaseContents: ->
    return

  loadContents: ->
    return

  contentChanges: ->
    if not @content.text().trim()
      @placeholder.addClass 'show'
    else
      @placeholder.removeClass 'show'

  checkTextSelection: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    commonAncester = range.commonAncestorContainer
    if @$el.has(commonAncester).length or commonAncester == @el
      @requestEdit()
    else
      @resignEdit()

  clearReturn: (e) ->
    if e.keyCode == 13
      return false

  events:
    'keyup .content': 'contentChanges'
    'keydown .content': 'clearReturn'

module.exports = TitleView
