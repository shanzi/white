express = require 'express'
path = require 'path'

app = express()
server = require('http').Server(app)
io = require('socket.io')(server)


app.use('/', express.static(path.join(__dirname, '../client/')))

#io.of('/test').on 'connection', (socket) ->
#  console.log 'connected'
#  socket.on 'disconnect', () ->
#    console.log 'User disconnected'
#
server.listen(process.env.PORT || 8000)
