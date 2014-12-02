_ = require('underscore')
P = require('bluebird')
url = require('url')
request = P.promisify(require('request'))
cheerio = require('cheerio')

{ logger } = require('webcrawler/lib/logger')

class HTMLPage

  @LINKED_ELEMENTS: {
    'a': 'href'
    'script': 'src'
    'link': 'href'
    'img': 'src'
  }

  # Constructs new HTMLPage.
  #
  # params {Object} {
  #   url {String} url of page request
  #   body {String} body of response
  # }
  #
  constructor: ({ @url, body }) ->
    logger.debug "Parsing webpage: #{@url}..."
    @_$ = cheerio.load(body ? '')

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

      new HTMLPage { url, body }

  # Parses the page to produce an array of all links contained within any
  # elements.
  parseLinks: ($ = @_$) ->

    links = []

    for own tag, attr of HTMLPage.LINKED_ELEMENTS
      $(tag).map -> links.push(@attribs[attr])

    _.compact(_.unique(links)).map(url.resolve.bind(null, @url))

module.exports = { HTMLPage }
