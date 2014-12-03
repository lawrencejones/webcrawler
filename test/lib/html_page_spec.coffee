url = require('url')

{ HTMLPage } = require('webcrawler/lib/html_page')

loadMock = _.memoize (fileName) ->
  fs.readFileSync(path.join(__dirname, '..', 'mocks', fileName), 'utf8')

pageWithBody = (body) -> """
<html>
  <head></head>
  <body>#{body}</body>
</html>"""

pageWithHead = (head) -> """
<html>
  <head>#{head}</head>
  <body></body>
</html>"""

describe 'HTMLPage', ->

  before ->
    @fourLinks = {
      url: 'http://localhost:8080/mocks/four_links.html'
      body: loadMock('four_links.html')
    }

  it 'should exist', ->
    expect(HTMLPage).to.exist

  describe 'constructor', ->

    describe '@request', ->

      integ 'should resolve promise for https://gocardless.com', ->
        HTMLPage.request(url: 'https://gocardless.com').then (page) ->
          expect(page).to.be.ok

      integ 'should reject for https://dashboard.gocardless.com/api/user', ->
        expect(HTMLPage.request({
          url: 'https://dashboard.gocardless.com/api/user'
        }))
          .to.be.rejected

    describe '#new', ->

      it 'should successfully new', ->
        expect(new HTMLPage(@fourLinks)).to.be.ok

  describe 'method', ->

    before -> @mockUrl = 'http://domain.com'

    describe '#resolveLink', ->

      before -> @page = new HTMLPage(url: @mockUrl)

      it 'should resolve relative link', ->
        expect(@page.resolveLink('/relative_page.html'))
          .to.equal "#{@page.url}/relative_page.html"

      it 'should remove query params', ->
        expect(@page.resolveLink('/relative_page.html?hello=5'))
          .to.equal "#{@page.url}/relative_page.html"

      it 'should leave absolute urls untouched', ->
        expect(@page.resolveLink('http://google.com/'))
          .to.equal 'http://google.com/'

    describe '#parseStaticAssets', ->

      it 'should return an array', ->
        page = new HTMLPage(url: @mockUrl)
        expect(page.parseStaticAssets()).to.be.an.array

      context 'for specific tag', ->

        before -> @expectMock = (page, resource) ->
          expect(page.parseStaticAssets()).to.eql [
            url.resolve(@mockUrl, resource)
          ]

        it 'should detect <img src={URL}>', ->
          @expectMock new HTMLPage({
            url: @mockUrl
            body: pageWithBody('<img src="image.jpg">')
          }), 'image.jpg'

        it 'should detect <script src={URL}>', ->
          @expectMock new HTMLPage({
            url: @mockUrl
            body: pageWithHead('<script src="/js/app.js">')
          }), 'js/app.js'

        it 'should detect <link href={URL}>', ->
          @expectMock new HTMLPage({
            url: @mockUrl
            body: pageWithHead('<link href="/css/app.css">')
          }), 'css/app.css'


    describe '#parseLinks', ->

      it 'should return an array', ->
        page = new HTMLPage(url: 'http://google.com')
        expect(page.parseLinks()).to.be.an.array

      it 'should detect <a href={URL}>', ->
        page = new HTMLPage({
          url: @mockUrl
          body: pageWithBody('<a href="/page.html">Anchor</a>')
        })
        expect(page.parseLinks()).to.eql [
          url.resolve(@mockUrl, '/page.html')
        ]


