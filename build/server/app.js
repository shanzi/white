var app, express, io, path, server;

express = require('express');

path = require('path');

app = express();

server = require('http').Server(app);

io = require('socket.io')(server);

app.use('/', express["static"](path.join(__dirname, '../client/')));

server.listen(process.env.PORT || 8000);
