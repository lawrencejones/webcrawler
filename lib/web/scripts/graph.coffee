angular.module('webcrawler')

# Abstraction for a collection of graph dimensions. {rx/ry} represent
# radial dimensions, and are calculated on the fly from {width/height}.
.value 'Dimensions', class Dimensions

  Object.defineProperties Dimensions.prototype, {

    rx: get: -> @width / 2
    ry: get: -> @height / 2

  }

  constructor: ({ @width, @height, @rotate }) ->
    @rotate ?= 0

# Implements logic to draw the dependency graph, using d3 helpers. Requires
# data that conforms to certain constraints - specifically that d3 cluster
# and bundle can identify links between different nodes.
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

    # Cluster all data into groups. Allows for correct ordering of nodes around
    # the graph, and optimises display of dependency splines.
    createCluster: ->
      @cluster = d3.layout.cluster()
        .size([ 360, @dim.ry - 300 ])
        .sort (a, b) ->
          d3.ascending(a.name, b.name)

    # Draws radial line that forms the edge of the dependency graph, along which
    # nodes shall be placed.
    drawLine: ->
      @line = d3.svg.line.radial()
        .interpolate('bundle')
        .tension(.85)
        .radius (d) -> d?.y ? 0
        .angle (d) -> (d?.x ? 0) / 180 * Math.PI

    # Applies necessary styles to the $parentElement that contains the graph,
    # inserting a new div that will become the svg container.
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

    # Appends an svg element to the graph div container, which will be used to
    # draw the graph contents.
    createSvg: ->

      @svg = @div.append('svg:svg')
        .attr('width', @dim.width)
        .attr('height', @dim.height)
        .append('svg:g')
        .attr('transform', "translate(#{@dim.rx},#{@dim.ry})")

      # Circumference of graph
      @svg.append('svg:path')
        .attr('class', 'arc')
        .attr('d',
          d3.svg.arc()
            .outerRadius(@dim.ry - 120)
            .innerRadius(0)
            .startAngle(0)
            .endAngle(2 * Math.PI))

      return @svg

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

      # Draw all links between nodes
      path = @svg.selectAll('path.link')
        .data(links)
        .enter().append('svg:path')
        .attr('class', (d) -> "link source-#{d.source.key} target-#{d.target.key}")
        .attr('d', (d, i) => @line(splines[i]))

      # Format all nodes as a function of their data
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

# Wrap the graph in a directive.
#
# Example usage.
#
#     <dependency-graph
#       graph-data="siteData"
#       id-key="name"
#       dep-key="assets"
#       node-color-rules="nodeColorRules"
#       width="1800"
#       height="1800">
#     </dependency-graph>
#
# The above would create a dep. graph on siteData, using 'name' as a key into
# each node that would yield a unique value. The dependencies for each node
# are calculated as links to every node whose key appears in the node['assets']
# array.
#
# nodeColorRules allow custom coloring of each label around the graph as a
# function of the data point. For example, a function that yields 'red' or
# 'blue' dependent on if the nodes 'name' key ends in .js or .css.
#
# Width and height values are respected as set dimensions. d3 only allows these
# to be drawn once, so no binding on dynamic values.
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
