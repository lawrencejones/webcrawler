# Global population of frameworks for testing

chai = require('chai')
chai.use(require('chai-as-promised'))

# Define new keyword for integration tests only. If the environment variable
# INTEG is set, then the test will run.
integ = ->
  it.apply(this, arguments) if process.env['INTEG']

exports = {
  fs: require('fs')
  path: require('path')
  _: require('underscore')
  P: require('bluebird')
  expect: chai.expect
  integ
}

exports._.extend(global, exports)
