_ = require 'underscore'


exports.debounce = (time, func) ->
  _.debounce func, time

exports.delay = (time, func) ->
  _.delay func, time

exports.throttle = (time, func) ->
  _.throttle func, time
