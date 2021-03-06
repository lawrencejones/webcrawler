{ SiteMap, SiteMapCache } = require('webcrawler/src/site_map')

describe 'SiteMap', ->

  testUrl = 'http://gocardless.com'
  testDomain = 'gocardless.com'

  beforeEach -> @map = new SiteMap(testUrl)

  it 'should exist', ->
    expect(SiteMap).to.exist

  describe 'constructor', ->

    it 'should set the domain value', ->
      expect(@map.siteDomain).to.equal(testDomain)

    it 'should create new cache', ->
      expect(@map.cache).to.be.ok

    it 'should initially have 0 pending requests', ->
      expect(@map.pendingRequests).to.equal 0

    it 'should initially have 0 total requests', ->
      expect(@map.pendingRequests).to.equal 0

  describe 'method', ->

    describe '#crawl', ->

      beforeEach ->
        @cacheGetStub = sinon.stub(@map.cache, 'get').returns(true)  # cache hit

      it 'defaults to `entryUrl` when no target is supplied', ->
        @map.crawl()
        expect(@cacheGetStub)
          .to.have.been.calledOnce
        expect(@cacheGetStub)
          .to.have.been.calledWith(@map.entryUrl)

    describe '#isSameDomain', ->

      it 'should equate different paths', ->
        expect(@map.isSameDomain("#{testUrl}/path"))
          .to.be.true

      it 'should not equate different domains', ->
        expect(@map.isSameDomain('http://different-host.entirely'))
          .to.be.false

    describe '#isHttp', ->

      it 'should return true for http request', ->
        expect(@map.isHttp('http://some-domain.com/path'))
          .to.be.true

      it 'should return true for https request', ->
        expect(@map.isHttp('https://some-domain.com/path'))
          .to.be.true

      it 'should return false for a mailto: link', ->
        expect(@map.isHttp('mailto://email@domain.com'))
          .to.be.false

    describe '#addPage', ->

      mockPage = {
        url: "#{testUrl}/page"
        parseLinks: -> []
        parseStaticAssets: -> []
      }

      # Configure the site map to be expecting two more pages
      beforeEach -> @map.totalRequests = @map.pendingRequests = 2

      context 'when adding a page', ->

        # Listen for nodeAdded event
        beforeEach ->
          @map.on 'nodeAdded', @pageAddedCb = sinon.spy(->)

        it 'should emit nodeAdded with page', ->
          @map.addPage(mockPage)
          expect(@pageAddedCb).to.have.been.called

      context 'when adding last remaining page', ->

        # Configure @map to be on last request
        beforeEach ->
          @map.pendingRequests = 1
          @map.on 'done', @doneCb = sinon.spy(->)

        it 'should emit done event, with map of added pages', ->
          @map.addPage(mockPage)
          expect(@doneCb).to.have.been.called
          nodes = @doneCb.firstCall.args[0]
          expect(nodes[mockPage.url]).to.contain.keys 'name', 'type'

