#!/usr/bin/env coffee

fs = require('fs')
path = require('path')

{ logger } = require('webcrawler/lib/logger')
{ SiteMap } = require('webcrawler/lib/site_map')
{ HTMLPage } = require('webcrawler/lib/html_page')
{ Web } = require('webcrawler/lib/web')

webcrawler = require('commander')
webcrawler._name = 'webcrawler'

webcrawler

  .version(require(path.join(__dirname, '..', 'package.json'))['version'])

webcrawler
  .command('links <url>')
  .description 'scrape the given href and output all links'
  .action (url) ->
    logger.info "Requesting #{url} ..."
    HTMLPage.request({url}).then (page) ->
      links = page.parseLinks()
      logger.info "Found #{links.length} links!"
      logger.info JSON.stringify(links, null, 2)

webcrawler
  .command('assets <url>')
  .description 'scrape the given href and output all assets'
  .action (url) ->
    logger.info "Requesting #{url} ..."
    HTMLPage.request({url}).then (page) ->
      assets = page.parseStaticAssets()
      logger.info "Found #{assets.length} assets!"
      logger.info JSON.stringify(assets, null, 2)

webcrawler
  .command('crawl <url> [jsonFile]')
  .description 'recursively crawls a given url'
  .action (url, jsonFile) ->

    logger.info "Initiating crawl on #{url} ..."

    siteMap = new SiteMap(url).crawl()

    siteMap.on 'nodeAdded', ({name}) ->
      logger.info "+ #{name}"

    siteMap.on 'done', (nodes) ->

      logger.info """
      Finished crawl. Found #{Object.keys(nodes).length} nodes."""

      if jsonFile?
        logger.info "Writing results in json to #{jsonFile} ..."
        jsonOutput = JSON.stringify(nodes, null, 2)
        fs.writeFileSync(path.resolve(jsonFile), jsonOutput, 'utf8')
        logger.info 'Write complete!'

      else
        logger.info(nodes)

webcrawler
  .command('serve [port]')
  .description 'starts server on port <port>'
  .action (port = 3000) ->
    Web.listen port, (err) ->
      logger.info "Server started on port #{port}"

webcrawler.parse(process.argv)
webcrawler.outputHelp() if process.argv.length < 3
