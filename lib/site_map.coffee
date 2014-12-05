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

  resolveNodeKey: (key) ->
    key.replace(/^https/, 'http').replace(/\/$/, '')

  cacheNode: (node) ->
    key = node.name = @resolveNodeKey(node.name)
    @nodes[key] = node

  getCacheNode: (key) ->
    @nodes[@resolveNodeKey(key)]

  # Initiates crawling for pages. Starts with the @host target, then
  # recurses on all parsed links.
  crawl: (target = @host) ->

    cachedNode = @getCacheNode(target)
    cachedNode = null if cachedNode?.type is 'asset'

    if !cachedNode and @isHttp(target) and @isSameHost(target)

      @cacheNode(name: target)
      ++@pendingRequests

      HTMLPage.request(url: target).then (page) =>

        @addPage {
          name: target
          type: 'page'
          links: page.parseLinks()
          assets: page.parseStaticAssets()
        }

      .finally => --@pendingRequests

    return @

  addPage: (pageNode) ->

    logger.debug "Adding page #{pageNode.name} ..."

    @cacheNode(pageNode)
    @emit('pageAdded', pageNode)

    # Recurse on all links
    pageNode.links.map(@crawl.bind(@))

    # Ensure all assets have been accounted
    pageNode.assets.map(@addAsset.bind(@))

    # For elegance, decrement of pendingRequests occurs in the .finally clause
    # of request promises. As a result, at this point, pending requests will be
    # pending + current, and so terminate on 1.
    @emit('done', @nodes) if @pendingRequests is 1

  addAsset: (asset) ->
    if !@getCacheNode(asset)?
      @cacheNode {
        name: asset
        type: 'asset'
      }

  isSameHost: (testUrl) ->
    url.parse(testUrl).host is url.parse(@host).host

  isHttp: (testUrl) ->
    /https?/.test(url.parse(testUrl).protocol)

module.exports = { SiteMap }

