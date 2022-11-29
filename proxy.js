const httpProxy = require("http-proxy");

httpProxy
  .createProxyServer({
    logLevel: 'debug',
    logProvider: 'console',
    //pathRewrite: {'^/js9Helper' : ''},
    //target: "http://0.0.0.0:8888/js9Helper/socket.io",
    target: "http://localhost:2718",
    ws: true,
  })
  .listen(3718);