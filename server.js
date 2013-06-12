var http = require('http');
var mincer = require('mincer');
var os = require('os');
var util = require('util');

var environment = new mincer.Environment();
environment.appendPath('.');
environment.appendPath('lib');
environment.appendPath('images');
environment.appendPath('scripts');

var port = 8000;
var server = http.createServer(mincer.createServer(environment));
server.listen(port);

console.log(util.format("listening on http://%s:%d", os.hostname(), port));
