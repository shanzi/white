_ = require 'underscore'


exports.debounce = (time, func) ->
  _.debounce func, time

exports.delay = (time, func) ->
  _.delay func, time

exports.throttle = (time, func) ->
  _.throttle func, time

exports.icon = (id) ->
  return "<svg class='icon icon-#{id}'><use xlink:href='css/icons/svg-symbols.svg##{id}'#icon-1></use></svg>"
