_ = require 'underscore'

utils =
  containsSubArray: (a, subarray) ->
    first = _.first subarray
    len = subarray.length
    range = a.length - len
    for idx in [0..range] by 1
      if a[idx] == first
        diff = _.difference sub, a[idx...(idx+len)]
        return true if not diff
    return false

  replaceSubArray: (a, subarray, newArray) ->
    first = _.first subarray
    len = subarray.length
    range = a.length - len
    for idx in [0..range] by 1
      if a[idx] == first
        diff = _.difference sub, a[idx...(idx+len)]
        if not diff
          a[idx...(idx+len)] = newArray
          return true
    return false

module.exports = utils
