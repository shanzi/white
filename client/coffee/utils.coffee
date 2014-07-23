_ = require 'underscore'


exports.debounce = (time, func) ->
  _.debounce func, time

exports.delay = (time, func) ->
  _.delay func, time

exports.throttle = (time, func) ->
  _.throttle func, time

exports.icon = (name, id) ->
  """
  <svg class='icon icon-#{name}'>
    <use xlink:href='css/icons/svg-symbols.svg##{name}'></use>
  </svg>
  """

exports.selection =
  _rangeStack: []
  _pushRange: (range)->
    exports.selection._rangeStack.push range
  _popRange: ()->
    return exports.selection._rangeStack.pop()

  save: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    exports.selection._pushRange
      start: range.startContainer
      end: range.endContainer
      startOffset: range.startOffset
      endOffset: range.endOffset

  restore: ->
    _savedRange = exports.selection._popRange()
    if _savedRange
      range = document.createRange()
      range.setStart(_savedRange.start, _savedRange.startOffset)
      range.setEnd(_savedRange.end, _savedRange.endOffset)
      selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(range)

  placeCursor: (node) ->
    module.exports.delay 100, =>
      range = document.createRange()
      range.selectNode(node)
      selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(range)
      selection.collapseToEnd()
      console.log selection.getRangeAt(0)

