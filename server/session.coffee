_ = require 'underscore'
uuid = require 'uuid'
utils = require './utils'

class Session

  constructor: (id, clientId, user, range, contents) ->
    @id = id
    @user = user
    @clientId = clientId

    @initialRange = range
    @initialContents = contents

    @range = range
    @contents = contents

  # block manipulations
  setBlockContent: (blockId, content) ->
    block = @contents[blockId]
    block.content = content if block

  removeBlock: (blockId) ->
    delete @contents[blockId]

  setRange: (range) ->
    @range = range

  collide: (range) ->
    ids = @retriveIds()
    _.intersection ids, range

  update: (hub) ->
    if _.update hub.blockContentsMap, @contents
      utils.replaceSubArray hub.range, @initialRange, @range
      return true
    return false

  toString: ->
    data =
      id: @id
      clientId: @clientId
      user: @user
      range: @range
      contents: @contents
      initialRange: @initalRange
      initialContents: @initialContents
    JSON.stringify data

module.exports = Session
