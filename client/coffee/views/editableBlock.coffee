$ = require 'jquery'
utils = require '../utils'
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
      utils.selection.save()
      callback()
      utils.selection.restore()

  requestEdit: (range, callback) ->
    @_safeExec =>
      callback()
      @loadContents range
      @$el.attr('contentEditable', true)
      @$el.focus()
      @startObserveMutation()
    popup.show()

  requestNew: (elem, callback) ->
    @$el.html('<p><br/></p>')
    callback()
    @$el.attr('contentEditable', true)
    @$el.focus()
    @startObserveMutation()

  resignEdit: ->
    @clearContents()
    @stopObserveMutation()
    @releaseContents()
    @$el.blur()
    @$el.removeAttr('contentEditable')

  mutationCallback: (mutations) ->
    console.log mutations
    for _, mutation of mutations
      @handleMutation(mutation)

  handleMutation: (mutation) ->
    target = mutation.target
    if mutation.type == 'characterData'
      targetp = target.parentElement
      ptagname = targetp.tagName.toLowerCase() if targetp
      if ptagname == 'p'
        if mutation.oldValue == '1.' and target.wholeText.match(/\s*1\.\s/)
          @replaceAsList(targetp, 'ol')
        if mutation.oldValue == '*' and target.wholeText.match(/\s*\*\s/)
          @replaceAsList(targetp, 'ul')
      else if ptagname == 'section'
        document.execCommand 'formatBlock', false, 'p'
        utils.selection.placeCursor @$el.find('p').get(0)

  replaceAsList: (node, type) ->
    li = $('<li></li>')
    if type=='ul'
      obj = $('<ul></ul>')
    else if type=='ol'
      obj = $('<ol></ol>')
    obj.append li
    obj.insertAfter node
    $(node).remove()
    utils.selection.placeCursor(li.get(0))

  startObserveMutation: ->
    if not @observer
      @observer = new MutationObserver((m) => @mutationCallback(m))
    @observer.observe @el, {childList: true, characterData: true, subtree: true, characterDataOldValue: true}
    @observer.takeRecords()

  stopObserveMutation: ->
    @observer.disconnect() if @observer

  clearContents: ->
    children = @$el.children()
    children.each (_, ele) =>
      element = $(ele)
      element.remove() if not element.text().trim()
      
  releaseContents: ->
    children = @$el.children()
    @$el.children().remove()
    children.insertAfter(@$el)
    @$el.remove()

  loadContents: (contents) ->
    @$el.insertBefore(contents[0])
    $(contents).appendTo(@el)

module.exports = EditableBlockView
