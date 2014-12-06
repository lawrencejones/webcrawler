angular.module('webcrawler', [])

.controller 'AppCtrl', ($scope, $log, $http, $timeout, IO, SiteMap) ->
  angular.extend $scope, {

    init: ->
      $scope.progress = { total: 0, current: 0 }
      $scope.siteData = null

    assetColorRules: (d) ->
      switch d.name.match(/\.([^.]+)$/)?[1]
        when 'js' then 'red'
        when 'css' then 'green'
        when 'jpg', 'png' then 'blue'
        else 'black'

    crawlWebsite: (domain) ->

      $scope.init()

      IO.emit 'crawl', { url: domain }
      IO.on 'nodeAdded', ({ url, total, pending }) ->
        $scope.progress = {
          total, current: total - pending
        }
        $scope.$apply()

      IO.on 'done', (nodes) ->
        $scope.progress.current = $scope.progress.total
        $scope.$apply()
        $timeout ->
          $scope.siteData = new SiteMap(domain, nodes).nodes
        , 1250  # wait for progress animation

  }

    .init()

.directive 'progressCircle', ->

  restrict: 'E'
  replace: true

  template: """
  <div class="progress-circle">
  </div>"""

  scope: {
    total: '='
    current: '='
  }

  link: ($scope, $cont, attr) ->

    $cont.css {
      height: "#{attr.size}px"
      width: "#{attr.size}px"
    }

    circleParams = angular.extend {
      color: '#1f77b4'
      trailColor: '#ddd'
      strokeWidth: 2
    }, $scope.$eval(attr.circleParams)

    circle = new ProgressBar.Circle($cont[0], circleParams)

    $header = $("<header class=\"progress-circle-text\"></header>")
    $header.css(color: circleParams.color)
    $cont.append($header)

    $scope.$watch (-> $scope.current / $scope.total), (pct) ->
      pct = 0 if _.isNaN(pct)
      $header.text "#{$scope.current}/#{$scope.total}"
      circle.animate(pct)

.service 'IO', -> @__proto__ = io.connect(window.location.origin)

.value 'SiteMap', class SiteMap

  constructor: (url, data) ->
    @domain = new URL(url).host
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

