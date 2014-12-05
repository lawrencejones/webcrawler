path = require('path')

P = require('bluebird')
_ = require('underscore')
express = require('express')
coffeeMiddleware = require('coffee-middleware')

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

module.exports = {
  Web: configureServer.call(express())
}

