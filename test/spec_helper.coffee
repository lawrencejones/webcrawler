# Global population of frameworks for testing

chai = require('chai')
chai.use(require('chai-as-promised'))

{ logger: transports: console: console } = require('webcrawler/lib/logger')
console.level = process.env['LOG_LEVEL'] ? console.level

# Define new keyword for integration tests only. If the environment variable
# INTEG is set, then the test will run.
integ = ->
  it.apply(this, arguments) if process.env['INTEG']

exports = {
  _: require('underscore')
  P: require('bluebird')
  expect: chai.expect
  integ
}

exports._.extend(global, exports)
