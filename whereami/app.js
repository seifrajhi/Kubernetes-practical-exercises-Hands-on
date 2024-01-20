const http = require('http');
const os = require('os');
console.log("Kubia server starting...");
console.log(process.env);
var handler = function (request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("You've hit " + os.hostname() + " " + "on this node: " + process.env.nodename + "\n");
};
var www = http.createServer(handler);
www.listen(8080);
