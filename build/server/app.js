var io;

io = require('socket.io').listen(process.env.PORT || 8000);

io.of('test').on('connection', function(socket) {
  console.log('connected');
  socket.emit('test', {
    msg: 'Hello World'
  });
  socket.on('res', function(from, data) {
    return console.log(from, data);
  });
  return socket.on('disconnect', function() {
    return console.log('User disconnected');
  });
});
