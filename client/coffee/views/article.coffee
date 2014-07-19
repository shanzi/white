$ = require 'jquery'
_ = require 'underscore'
utils = require '../utils'
Backbone = require 'backbone'
EditableBlockView = require './editableBlock'


ArticleView = Backbone.View.extend
  currentEditingBlock: null

  initialize: ->
    $(document).on 'mouseup', (e) => @checkTextSelection()

  checkTextSelection: ->
    selection = window.getSelection()
    return if selection.rangeCount == 0
    range = selection.getRangeAt(0)
    commonAncester = range.commonAncestorContainer
    console.log selection
    console.log range
    if @$el.has(commonAncester).length or commonAncester == @el
      return if $(commonAncester).closest('section').length > 0

      oldBlock = @currentEditingBlock
      @currentEditingBlock = new EditableBlockView()

      startNode = range.startContainer
      endNode = range.endContainer

      start = $(startNode).closest('article>*')
      end = $(endNode).closest('article>*')
      all = start.nextAll().andSelf()

      requestRange = all[0.._.indexOf(all, end.get(0))]
      @currentEditingBlock.requestEdit requestRange, =>
        oldBlock.resignEdit() if oldBlock
    else
      @currentEditingBlock.resignEdit() if @currentEditingBlock
      @currentEditingBlock = null
      

module.exports = ArticleView
