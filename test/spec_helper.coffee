# Global population of frameworks for testing

chai = require('chai')
chai.should()

exports = {
  _: require('underscore')
  P: require('bluebird')
}

exports._.extend(global, exports)
