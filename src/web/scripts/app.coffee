angular.module('webcrawler', [])

# Hook up the socket.io connection to localhost
.service 'IO', -> @__proto__ = io.connect(window.location.origin)

# Controls the web view, implementing logic for coloring of nodes and
# communication via socket.io to initiate/monitor site crawling.
.controller 'AppCtrl', ($scope, $timeout, IO, SiteMap) ->
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

# Wraps around the progressbar.js library to allow directive to trigger
# creation of progress circles.
#
# Example usage.
#
#     <progress-circle
#       size="150"
#       total="progress.total"
#       current="progress.current"
#       circle-params="{ color: 'black', strokeWidth: 3 }">
#     </progress-circle>
#
# Will create a circular progress bar of diameter 50px, with the given
# circle parameters. progress.total, progress.current are respectively
# the total to calculate progress on and the count through that total.
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


