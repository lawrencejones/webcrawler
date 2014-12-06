url = require('url')
{ EventEmitter } = require('events')

_ = require('underscore')
P = require('bluebird')

{ HTMLPage } = require('webcrawler/lib/html_page')
{ logger } = require('webcrawler/lib/logger')

# Provides abstraction around pages in a website. All links are transformed
# from https to http to enable hashing.
class SiteMapCache

  constructor: (@key = 'name') ->
    @cache = {}

  canonicalUrl: (url) ->
    url.replace(/^https/, 'http').replace(/\/+$/, '')

  set: (node) ->
    key = node[@key] = @canonicalUrl(node[@key])
    @cache[key] = node

  get: (key) ->
    @cache[@canonicalUrl(key)]

  remove: (key) ->
    delete @cache[@canonicalUrl(key)]

class SiteMap extends EventEmitter

  constructor: (@host) ->
    @cache = new SiteMapCache('name')
    @pendingRequests = @totalRequests = 0

  # Initiates crawling for pages. Starts with the @host target, then
  # recurses on all parsed links.
  #
  # If the given target is listed as an asset, then that listing will be
  # replaced.
  crawl: (target = @host) ->

    cachedNode = @cache.get(target)
    cachedNode = null if cachedNode?.type is 'asset'

    if !cachedNode and @isHttp(target) and @isSameHost(target)

      @cache.set(name: target)
      ++@pendingRequests
      ++@totalRequests

      HTMLPage
        .request(url: target).bind(@)
        .then @addPage
        .catch (err) ->
          console.log err
          @cache.remove(target)
        .finally -> --@pendingRequests

    return @

  addPage: (page) ->

    logger.debug "Adding page #{page.url} ..."

    pageNode = @cache.set {
      name: page.url
      type: 'page'
      links: page.parseLinks()
      assets: page.parseStaticAssets()
    }

    @emit('nodeAdded', pageNode)

    # Recurse on all links
    pageNode.links.map(@crawl.bind(@))

    # Ensure all assets have been accounted
    pageNode.assets.map (asset) =>
      if !@cache.get(asset)?
        @emit 'nodeAdded', @cache.set {
          name: asset
          type: 'asset'
        }

    # For elegance, decrement of pendingRequests occurs in the .finally clause
    # of request promises. As a result, at this point, pending requests will be
    # pending + current, and so terminate on 1.
    @emit('done', @cache.cache) if @pendingRequests is 1

  isSameHost: (testUrl) ->
    url.parse(testUrl).host is url.parse(@host).host

  isHttp: (testUrl) ->
    /https?/.test(url.parse(testUrl).protocol)

module.exports = { SiteMap, SiteMapCache }

