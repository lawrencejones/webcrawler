angular.module('webcrawler')

.value 'Dimensions', class Dimensions

  Object.defineProperties Dimensions.prototype, {

    rx: get: -> @width / 2
    ry: get: -> @height / 2

  }

  constructor: ({ @width, @height, @rotate }) ->
    @rotate ?= 0

.factory 'DependencyGraph', (SiteAssets, Dimensions) ->

  class DependencyGraph

    constructor: ($graph, options) ->

      throw new Error """
      d3 is not present, but is required!!""" unless d3?

      @dim = new Dimensions {
        width: options.width ? 800
        height: options.height ? 800
      }

      @splines = []
      @createCluster()
      @bundle = d3.layout.bundle()

      @drawLine()
      @createDiv($graph)
      @createSvg()

    createCluster: ->
      @cluster = d3.layout.cluster()
        .size([ 360, @dim.ry - 300 ])
        .sort (a, b) ->
          d3.ascending(a.name, b.name)

    createDiv: ($parentElement) ->

      # Center parent element
      $parentElement.css {
        display: 'block'
        marginLeft: 'auto'
        marginRight: 'auto'
        width: "#{@dim.width}px"
        height: "#{@dim.height}px"
      }

      @div = d3.select($parentElement[0])
        .insert('div')
        .style('width', "#{@dim.width}px")
        .style('height', "#{@dim.height}px")
        .style('position', 'absolute')
        .style('-webkit-backface-visibility', 'hidden')

    createSvg: ->

      @svg = @div.append('svg:svg')
        .attr('width', @dim.width)
        .attr('height', @dim.height)
        .append('svg:g')
        .attr('transform', "translate(#{@dim.rx},#{@dim.ry})")

      @svg.append('svg:path')
        .attr('class', 'arc')
        .attr('d',
          d3.svg.arc()
            .outerRadius(@dim.ry - 120)
            .innerRadius(0)
            .startAngle(0)
            .endAngle(2 * Math.PI))

      return @svg

    drawLine: ->
      @line = d3.svg.line.radial()
        .interpolate('bundle')
        .tension(.85)
        .radius (d) -> d?.y ? 0
        .angle (d) -> (d?.x ? 0) / 180 * Math.PI

    # Will draw nodes and the dependency links into the graph.
    #
    # options {Object} {
    #   data {Array} array of objects that have the following structure...
    #                 {
    #                   idKey: <uniqueName>
    #                   depKey: [ <uniqueName>... ]
    #                 }
    #
    #   idKey {String} key of each nodes unique identifier
    #   depKey {String} key of each nodes array of dependencies
    #   nodeColorRules {Funtion} given a node, returns fill color
    #   classifier {Function} generates a classing key from a node
    # }
    #
    renderData: ({ data, idKey, depKey, classifier, nodeColorRules }) ->

      nodes = @cluster.nodes(SiteAssets.buildHierachy(data, classifier))
      links = SiteAssets.dependencies(data, idKey, depKey)
      splines = @bundle(links)

      path = @svg.selectAll('path.link')
        .data(links)
        .enter().append('svg:path')
        .attr('class', (d) -> "link source-#{d.source.key} target-#{d.target.key}")
        .attr('d', (d, i) => @line(splines[i]))

      @svg.selectAll('g.node')
        .data(nodes.filter (n) -> !n.children)
        .enter().append('svg:g')
        .attr('class', 'node')
        .attr('id', (d) -> "node-#{d.key}")
        .attr('transform', (d) -> "rotate(#{d.x - 90})translate(#{d.y})")
        .append('svg:text')
        .attr('dx', (d) -> if d.x < 180 then 8 else -8)
        .attr('dy', '.31em')
        .attr('text-anchor', (d) -> if d.x < 180 then 'start' else 'end')
        .attr('transform', (d) -> if d.x < 180 then null else 'rotate(180)')
        .text(_.property('name'))
        .style('fill', nodeColorRules)

.directive 'dependencyGraph', (DependencyGraph) -> {

  restrict: 'E'
  replace: true

  scope: {
    getGraphData: '&graphData'
    nodeColorRules: '='
  }

  template: """
  <div class="dependency-graph">
  </div>"""

  link: ($scope, $graph, attr) ->

    graph = new DependencyGraph($graph, attr)
    $scope.$watch $scope.getGraphData, (data) ->
      return unless data?
      graph.renderData {
        idKey: attr.idKey
        depKey: attr.depKey
        classifier: _.property(attr.idKey)
        nodeColorRules: $scope.nodeColorRules ? null
        data: data
      }

}
