path = require('path')

P = require('bluebird')
_ = require('underscore')
express = require('express')
coffeeMiddleware = require('coffee-middleware')

{ logger } = require('webcrawler/src/logger')
{ SiteMap } = require('webcrawler/src/site_map')

app = express()
server = require('http').Server(app)
io = require('socket.io').listen(server)

# Patch the express server to start socket.io also
app.start = app.listen = ->
  server.listen.apply(server, arguments)

configureServer = ->

  @set 'title', 'Webcrawler'
  @set 'views', path.join(__dirname, 'views')
  @set 'view engine', 'jade'

  @get '/', (req, res) ->
    res.render('index')

  @use express.static(path.join(__dirname, 'public'))

  @use coffeeMiddleware({
    src: path.join(__dirname, 'scripts')
    encodeSrc: false
  })

  return @

configureSocket = ->

  @on 'connection', (socket) ->

    REMOTE = socket.request.connection.remoteAddress
    logger.info "Request from #{REMOTE}"

    socket.on 'crawl', ({ url }) ->

      logger.info "Crawl request from #{REMOTE}"

      sm = new SiteMap(url).crawl()

      sm.on 'nodeAdded', (page) ->
        socket.emit 'nodeAdded', {
          total: sm.totalRequests
          pending: sm.pendingRequests
          page: page
        }

      sm.on 'done', socket.emit.bind(socket, 'done')

module.exports = {
  Web: configureServer.call(app)
  io: configureSocket.call(io)
}

