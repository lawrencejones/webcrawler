angular.module('webcrawler', [])

.controller 'AppCtrl', ($scope, $log, $http) ->

  $scope.assetColorRules = (d) ->
    ext = d.name.match(/\.([^.]+)$/)?[1]
    console.log d
    switch ext
      when 'js' then 'red'
      when 'css' then 'green'
      when 'jpg', 'png' then 'blue'
      else 'black'

  isHostname = (hostname, url) ->
    new URL(url).hostname is hostname

  isGocardless = isHostname.bind(null, 'gocardless.com')

  getPathname = (url) ->
    return new URL(url).pathname
    if path is '/' then return 'home'
    else "home#{path}"

  restrictAndKey = (urls = []) ->
    urls
      .filter(isGocardless)
      .map(getPathname)

  $http.get('/gocardless.json').success (data) ->

    $log.info 'Received data'

    $scope.gcData = _.values(data)
      .filter (node) -> isGocardless(node.name)
      .map (node) -> {
        name: getPathname(node.name)
        assets: restrictAndKey(node.assets)
        links: restrictAndKey(node.links)
      }
