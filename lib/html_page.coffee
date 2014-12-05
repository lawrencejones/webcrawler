_ = require('underscore')
P = require('bluebird')
url = require('url')
request = P.promisify(require('request'))
cheerio = require('cheerio')

{ logger } = require('webcrawler/lib/logger')

class HTMLPage

  @STATIC_ELEMENTS: {
    'script': 'src'
    'link': 'href'
    'img': 'src'
  }

  @LINK_ELEMENTS: {
    'a': 'href'
  }

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

  # Parses the page to produce an array of all links to other pages.
  parseLinks: ->
    @parseElementAttributes(HTMLPage.LINK_ELEMENTS, @resolveLink.bind(@))

  # Parses page to find all static resources used.
  parseStaticAssets: ->
    @parseElementAttributes(HTMLPage.STATIC_ELEMENTS, @resolveLink.bind(@))

  # Given a mapping of tag to attribute, will extract from all found tags
  # the value of the set attribute.
  #
  #   TAG_ATTRIBUTES {Object} tag:attr pairs
  #   transform {Function|Null} optional function to map over attributes
  #
  # Returns array of all discovered attribute values.
  parseElementAttributes: (TAG_ATTRIBUTES, transform) ->

    attributes = []

    for own tag, attr of TAG_ATTRIBUTES
      @_$(tag).map -> attributes.push(@attribs[attr]) if @attribs[attr]

    if 'function' is typeof transform
      attributes = attributes.map(transform)

    _.compact(_.unique(attributes))

  # Resolves link to the pages url, removing query.
  #
  #   link {String} link to resolve
  #
  resolveLink: (link) ->

    {
      protocol, host, pathname
    } = url.parse(url.resolve(@url, link))

    "#{protocol}//#{host}#{pathname ? ''}".replace(/\/$/, '')

module.exports = { HTMLPage }

