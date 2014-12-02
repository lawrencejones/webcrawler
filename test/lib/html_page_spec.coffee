{ HTMLPage } = require('webcrawler/lib/html_page')

describe 'HTMLPage', ->

  it 'should exist', ->
    expect(HTMLPage).to.exist

  describe '@request', ->

    integ 'should resolve promise for https://gocardless.com', ->
      HTMLPage.request(url: 'https://gocardless.com')
        .then (page) ->
          expect(page).to.be.ok

    integ 'should reject for https://dashboard.gocardless.com/api/user', ->
      expect(HTMLPage.request(url: 'https://dashboard.gocardless.com/api/user'))
        .to.be.rejected
