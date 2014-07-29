_ = require 'underscore'
session = require './session'
utils = require './utils'

class SessionHub

  constructor: (io, name) ->
    @io = io
    @name = name

    @title = ''
    @blockIds = []
    @operations = []

    @usersMap = {}
    @sessionsMap = {}
    @blockContentsMap = {}


  # get contents and properties
  contents: (range) ->
    _.zip([id, @blockContentsMap[id]] for id in range)

  article: ->
    @contents @blockIds

  sessions: ->
    _.values @sessionsMap


  # handler user
  addUser: (username, socket) ->
    socket.join @name
    @removeUser username
    @usersMap[username] = socket
    @bindEvents username
    @resetClient username

  removeUser: (username) ->
    user = @usersMap[username]
    if user
      @resignSessionByUser username
      user.leave @name
      user.emit 'offline', message: 'You have been removed from editing session'
      user.close()
    delete @usersMap[username]

  resetClient: (username) ->
    @emitOperationSingle username, 'reset',
      title: @title
      article: @article()
      sessions: @sessions()

  bindEvents: (username) ->
    user = @usersMap username
    if user
      user.on 'requestSession', (data) => @requestSession username, data
      user.on 'sessionEditing', (data) => @sessionEditing username, data
      user.on 'resignSession', (data) => @resignSession username, data
      user.on 'close', => @disconnected username


  # handle operations
  lastOperationId: ->
    lastOperation = _.last(@operations)
    if lastOperation
      return lastOperation.id
    else
      return null

  genOperationId: ->
    return (new Date()).valueOf()

  operationWithId: (id) ->
    return _.find @operations, (op) => op.id == id

  operationsBetween: (idLeft, idRight) ->
    operations = _.find(@operations, (op) => idLeft < op.id < idRight)
    _.sortBy operations, (op) => op.id

  emitOperation: (type, data) ->
    operation =
      id: @genOperationId()
      prev: @lastOperationId()
      type: type
      data: data
    @operations.push operation
    @io.to(@name).emit type, operation

  emitOperationSingle: (username, type, data) ->
    user = @usersMap[username]
    if user
      operation =
        id: @genOperationId()
        prev: @lastOperationId()
        type: type
        data: data
      user.emit type, operation


  # handle sessions
  collidedSession: (range) ->
    for _, session of @sessionsMap
      if session.colide(range)
        return session
    return null

  addSession: (username, clientId, range) ->
    collidedSession = @collidedSession range
    return null if collidedSession and collidedSession.user != username
    @resignSessionByUser username
    if utils.containsSubArray @range, range
      contents = @contents range
      session = new Session(uuid.v4(), clientId, username, range, contents)
      sessionsMap[session.id] = session
      return session

  removeSessionById: (id) ->
    session = sessionsMap[id]
    delete sessionsMap[id]
    return session

  resignSessionById: (id, save) ->
    session = @removeSessionById(id)
    if session
      if save
        if session.update this
          @emitOperation 'sessionResigned', session
        else
          @emitOperation 'sessionUpdateError', session
      else
        @emitOperation 'sessionCancelled', session

  resignSessionByUser: (username) ->
    sessions = _.filter _.values(@sessionsMap), (session)=> session.user == user
    for session in sessions
      @resignSessionById session.id


  # handle events
  requestSession: (username, data) ->
    user = @usersMap[username]
    if user
      session = @addSession username, data.clientId, data.range
      if session
        @emitOperation 'sessionAssigned', session
      else
        @emitOperationSingle username, 'sessionRequestRejected', data.clientId

  resignSession: (username, data) ->
    save = false || data
    @resignSessionByUser username, save

  sessionEditing: (username, data) ->
    console.log username, 'edited files'

  disconnected: (username) ->
    @resignSession username
    @removeUser username


module.exports = SessionHub

