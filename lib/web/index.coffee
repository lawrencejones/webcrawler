path = require('path')

P = require('bluebird')
_ = require('underscore')
express = require('express')
coffeeMiddleware = require('coffee-middleware')

configureServer = ->

  @set 'title', 'Webcrawler'
  @set 'views', path.join(__dirname, 'views')
  @set 'view engine', 'jade'

  @use coffeeMiddleware({
    src: path.join(__dirname, 'scripts')
  })

  @use express.static(path.join(__dirname, 'public'))

  @get '/', (req, res) ->
    res.render('index')

  return @

module.exports = {
  Web: configureServer.call(express())
}

