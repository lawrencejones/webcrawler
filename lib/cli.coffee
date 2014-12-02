#/usr/bin/env coffee

path = require('path')

{ logger } = require('webcrawler/lib/logger')
{ HTMLPage } = require('webcrawler/lib/html_page')

webcrawler = require('commander')
webcrawler

  .version(require(path.join(__dirname, '..', 'package.json'))['version'])
  .option '-r, --recursive', 'recursively crawl pages'

webcrawler
  .command('crawl <url>')
  .description 'crawl the given href and output all links'
  .action (url) ->
    logger.info "Requesting #{url} ..."
    HTMLPage.request({url}).then (page) ->
      links = page.parseLinks()
      logger.info "Found #{links.length} links!"
      logger.info JSON.stringify(links, null, 2)

webcrawler.parse(process.argv)
