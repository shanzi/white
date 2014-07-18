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

  requestEdit: (range, callback) ->
    @_safeExec =>
      callback()
      @loadContents range
      @$el.attr('contentEditable', true)
      @$el.focus()
      @startObserveMutation()
    popup.show()

  resignEdit: ->
    @stopObserveMutation()
    @releaseContents()
    @$el.blur()
    @$el.removeAttr('contentEditable')

  mutationCallback: (mutations) ->
    # callback for mutations
    console.log mutations

  startObserveMutation: ->
    @observer ?= new MutationObserver((m) => @mutationCallback(m))
    @observer.observe @el, {childList: true, characterData: true, subtree: true}
    @observer.takeRecords()

  stopObserveMutation: ->
    @observer.disconnect() if @observer

  releaseContents: ->
    children = @$el.children()
    @$el.children().remove()
    children.insertAfter(@$el)
    @$el.remove()

  loadContents: (contents) ->
    @$el.insertBefore(contents[0])
    $(contents).appendTo(@el)

module.exports = EditableBlockView
