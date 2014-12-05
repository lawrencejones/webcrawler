class SiteAssets

  # Will split the assets into a hierachy of nodes, based on the classifier
  # function.
  #
  #   assets {Array} nodes with data to be classified
  #   classifier {Function(Node)} when given a node, will generate a string
  #                               value of the form 'grand.parent.child'
  #
  # Each node is classed into common parent/child classes.
  @buildHierachy: (assets, classifier = _.identity, SEP = '/') ->

    levels = {}

    find = (name, data) ->

      node = levels[name]

      if !node

        node = levels[name] = data ? { name, children: [] }
        node.children ?= []

        if name.length > 0  # is not root
          node.parent = find(name.substring(0, i = name.lastIndexOf(SEP)))
          node.parent.children.push(node)
          node.key = name.substring(i + 1)

      return node

    assets.map (a) ->
      find(classifier(a), a)

    return levels['']

  # Will process the assets array into an array of dependency links.
  #
  #   assets {Array} nodes that have unique identifiers and asset array
  #   idKey {String} key for unique identifier of each node
  #   depKey {String} key for dependency array of each node
  #
  # Returns array of { source -> target } links.
  @dependencies: (assets, idKey = 'name', depKey = 'assets') ->

    mappedAssets = {}

    for asset in assets
      mappedAssets[asset[idKey]] = asset

    _.flatten _.compact assets.map (a) ->
      a[depKey]?.map (d) -> {
        source: a
        target: mappedAssets[d]
      }

angular.module('webcrawler').value('SiteAssets', SiteAssets)

