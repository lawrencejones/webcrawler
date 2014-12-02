P = require('bluebird')
request = P.promisify(require('request'))
cheerio = require('cheerio')

{ logger } = require('webcrawler/lib/logger')

class HTMLPage

  # Constructs new HTMLPage and initiates parsing.
  #
  # params {Object} {
  #   url {String} url of page request
  #   $ {jQuery Context} a jquery handle for page content
  # }
  #
  constructor: ({ @url, $: @_$ }) ->
    logger.debug "Parsing webpage: #{@url}..."
    @parseLinks()

  # Requests page from given url, jquerifying the body.
  #
  # params {Object} {
  #   url {String} url to request
  # }
  #
  # Returns promise that is resolved with new HTMLPage instance.
  @request: ({ url }) ->

    logger.debug "Requesting webpage: #{url}..."

    request(url).then ([{ statusCode, body }]) ->

      logger.debug "Request to #{url} yielded status [#{statusCode}]"

      unless statusCode is 200
        throw new Error("Request failed [#{statusCode}]")

      new HTMLPage {
        url: url
        $: cheerio.load(body)
      }

  parseLinks: ->

module.exports = { HTMLPage }
