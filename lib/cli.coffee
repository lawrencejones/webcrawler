#/usr/bin/env coffee

path = require('path')

{ logger } = require('webcrawler/lib/logger')
{ HTMLPage } = require('webcrawler/lib/html_page')

webcrawler = require('commander')
webcrawler

  .version(require(path.join(__dirname, '..', 'package.json'))['version'])
  .option '-r, --recursive', 'recursively crawl pages'

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

webcrawler.parse(process.argv)
