# Global population of frameworks for testing

chai = require('chai')
chai.use(require('chai-as-promised'))
chai.use(require('sinon-chai'))

# Define new keyword for integration tests only. If the environment variable
# INTEG is set, then the test will run.
integ = ->
  it.apply(this, arguments) if process.env['INTEG']

exports = {
  fs: require('fs')
  path: require('path')
  _: require('underscore')
  P: require('bluebird')
  sinon: require('sinon')
  expect: chai.expect
  integ
}

exports._.extend(global, exports)
