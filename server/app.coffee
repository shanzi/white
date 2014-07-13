io = require('socket.io').listen(process.env.PORT || 8000)

io.of('test').on 'connection', (socket) ->
  console.log 'connected'
  socket.emit 'test', msg: 'Hello World'
  socket.on 'res', (from, data) ->
    console.log from, data
  socket.on 'disconnect', () ->
    console.log 'User disconnected'
