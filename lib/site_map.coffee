url = require('url')
{ EventEmitter } = require('events')

_ = require('underscore')
P = require('bluebird')

{ HTMLPage } = require('webcrawler/lib/html_page')
{ logger } = require('webcrawler/lib/logger')

class SiteMap extends EventEmitter

  @REQUEST_LIMIT: 5

  constructor: (@host) ->
    @nodes = {}
    @pendingRequests = 0

  # Initiates crawling for pages. Starts with the @host target, then
  # recurses on all parsed links.
  crawl: (target = @host) ->

    if !@nodes[target]? and @isHttp(target) and @isSameHost(target)

      @nodes[target] = true
      ++@pendingRequests

      HTMLPage.request(url: target).then (page) =>
        --@pendingRequests
        @addPage {
          name: target
          links: page.parseLinks()
          assets: page.parseStaticAssets()
        }

    return @

  addPage: (pageNode) ->

    logger.debug "Adding page #{pageNode.name} ..."

    @nodes[pageNode.name] = pageNode
    @emit('pageAdded', pageNode)

    pageNode.links.map(@crawl.bind(@))

    @emit('done', @nodes) if @pendingRequests is 0

  isSameHost: (testUrl) ->
    url.parse(testUrl).host is url.parse(@host).host

  isHttp: (testUrl) ->
    /https?/.test(url.parse(testUrl).protocol)

module.exports = { SiteMap }

