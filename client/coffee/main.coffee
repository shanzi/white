$ = require 'jquery'
Backbone = require 'backbone'

socket = io 'http://localhost:8000/test'

socket.on 'test', (data) ->
  console.log 'received data', data
  socket.emit 'res', msg: 'test response'
