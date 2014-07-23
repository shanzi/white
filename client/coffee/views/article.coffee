$ = require 'jquery'
_ = require 'underscore'
utils = require '../utils'
Backbone = require 'backbone'
EditableBlockView = require './editableBlock'


ArticleView = Backbone.View.extend
  currentEditingBlock: null

  initialize: ->
    $(document).on 'mouseup', (e) => @checkTextSelection(e)

  checkTextSelection: (e) ->
    selection = window.getSelection()
    return if selection.rangeCount == 0
    range = selection.getRangeAt(0)
    commonAncester = range.commonAncestorContainer
    if @$el.has(commonAncester).length or commonAncester == @el
      return if not @shouldRequestEdit(commonAncester)

      oldBlock = @currentEditingBlock
      @currentEditingBlock = new EditableBlockView()
      range = selection.getRangeAt(0)

      startNode = range.startContainer
      endNode = range.endContainer

      start = $(startNode).closest('article>*')
      end = $(endNode).closest('article>*')
      all = start.nextAll().andSelf()

      requestRange = all[0.._.indexOf(all, end.get(0))]
      @currentEditingBlock.requestEdit requestRange, =>
        oldBlock.resignEdit() if oldBlock
    else
      @resignCurrent()

  insertParagraphAfter: (elem) ->
    if @currentEditingBlock
      @currentEditingBlock.resignEdit()
      @currentEditingBlock.remove()
    @currentEditingBlock = new EditableBlockView()
    @currentEditingBlock.requestNew elem, =>
      if elem
        @currentEditingBlock.$el.insertAfter elem
      else
        @currentEditingBlock.$el.prependTo @$el

  resignCurrent: ->
    if @currentEditingBlock
      @currentEditingBlock.resignEdit()
      @currentEditingBlock.remove()
      @currentEditingBlock = null

  shouldRequestEdit: (element) ->
    section = $(element).closest('section')
    return true if section.length == 0
    if @currentEditingBlock
      blockEle = @currentEditingBlock.$el
      if blockEle.has(element) and blockEle.children().length > 1
        utils.selection.save()
        @resignCurrent()
        utils.selection.restore()
        return true
    return false


module.exports = ArticleView
