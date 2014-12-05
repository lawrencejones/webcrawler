angular.module('webcrawler', [])

.controller 'AppCtrl', ($scope, $log, $http) ->

  isHostname = (hostname) -> (url) ->
    new URL(url).hostname is hostname

  getPathname = (url) ->
    new URL(url).pathname

  restrictAndKey = (urls = []) ->
    urls
      .filter(isHostname('gocardless.com'))
      .map(getPathname)

  $http.get('/gocardless.json').success (data) ->

    $log.info 'Received data'

    $scope.gcData = _.values(data).map (node) -> {
      name: getPathname(node.name)
      assets: restrictAndKey(node.assets)
      links: restrictAndKey(node.links)
    }
