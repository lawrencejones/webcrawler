url = require('url')

{ HTMLPage } = require('webcrawler/lib/html_page')

loadMock = _.memoize (fileName) ->
  fs.readFileSync(path.join(__dirname, '..', 'mocks', fileName), 'utf8')

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

    describe '#parseLinks', ->

      it 'should return an array', ->
        page = new HTMLPage(url: 'http://google.com')
        expect(page.parseLinks()).to.be.an.array

      context 'for specific tag', ->

        mockUrl = 'http://localhost:8080'

        expectMock = (page, resource) ->
          expect(page.parseLinks()).to.eql [ url.resolve(mockUrl, resource) ]

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

        it 'should detect <a href={URL}>', ->
          expectMock new HTMLPage({
            url: mockUrl
            body: pageWithBody('<a href="/page.html">Anchor</a>')
          }), 'page.html'

        it 'should detect <img src={URL}>', ->
          expectMock new HTMLPage({
            url: mockUrl
            body: pageWithBody('<img src="image.jpg">')
          }), 'image.jpg'

        it 'should detect <script src={URL}>', ->
          expectMock new HTMLPage({
            url: mockUrl
            body: pageWithHead('<script src="/js/app.js">')
          }), 'js/app.js'

        it 'should detect <link href={URL}>', ->
          expectMock new HTMLPage({
            url: mockUrl
            body: pageWithHead('<link href="/css/app.css">')
          }), 'css/app.css'

      context 'on mocks/four_links.html content', ->

        beforeEach -> @page = new HTMLPage(@fourLinks)

        it 'should extract all four links', ->
          expect(@page.parseLinks().length).to.equal 4

        it 'should resolve all links to localhost', ->
          @page.parseLinks().map (link) =>
            expect(link).to.contain(url.parse(@fourLinks.url).hostname)



