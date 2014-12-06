angular.module('webcrawler', [])

.controller 'AppCtrl', ($scope, $log, $http, SiteMap) ->
  angular.extend $scope, {

    assetColorRules: (d) ->
      switch d.name.match(/\.([^.]+)$/)?[1]
        when 'js' then 'red'
        when 'css' then 'green'
        when 'jpg', 'png' then 'blue'
        else 'black'

    crawlWebsite: (domain) ->
      $http.get('/gocardless.json').success (data) ->
        $log.info 'Received data'
        $scope.gcData = new SiteMap('gocardless.com', data).nodes

  }

    .crawlWebsite('http://gocardless.com')

.value 'SiteMap', class SiteMap

  constructor: (@domain, data) ->
    @nodes = _.values(data)
      .filter (n) => @isDomain(n.name)
      .map (node) => {
        name: @getPathname(node.name)
        assets: @restrictAndKey(node.assets)
        links: @restrictAndKey(node.links)
      }

  isDomain: (url) ->
    new URL(url).hostname is @domain

  getPathname: (url) ->
    new URL(url).pathname

  restrictAndKey: (urls = []) ->
    urls.filter(@isDomain.bind(@)).map(@getPathname.bind(@))

