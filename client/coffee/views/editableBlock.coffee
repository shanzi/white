$ = require 'jquery'
popup = require './popup'
Backbone = require 'backbone'

EditableBlockView = Backbone.View.extend
  tagName: 'section'
  observer: null
  editingByUser: null

  _safeExec: (callback) ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    commonAncester = range.commonAncestorContainer
    if @el == commonAncester or @$el.has(commonAncester)
      sc = range.startContainer
      so = range.startOffset
      ec = range.endContainer
      eo = range.endOffset
      callback()
      range = document.createRange()
      range.setStart(sc, so)
      range.setEnd(ec, eo)
      selection.removeAllRanges()
      selection.addRange(range)
      @$el.focus()
      popup.show()

  requestEdit: (range, callback) ->
    @_safeExec =>
      callback()
      @loadContents range
      @$el.attr('contentEditable', true)

  resignEdit: ->
    @releaseContents()
    @$el.blur()
    @$el.removeAttr('contentEditable')

  mutationCallback: (mutations) ->
    # callback for mutations
    console.log mutations

  startObserveMutation: ->
    observer = @observer or (new MutationObserver((m) => @mutationCallback(m)))
    observer.observe @el, {childList: true, charactorData: true}
    observer.takeRecords()

  stopObserveMutation: ->
    @observe.disconnect() if @observe

  releaseContents: ->
    children = @$el.children()
    @$el.children().remove()
    children.insertAfter(@$el)
    @$el.remove()

  loadContents: (contents) ->
    @$el.insertBefore(contents[0])
    $(contents).appendTo(@el)

module.exports = EditableBlockView