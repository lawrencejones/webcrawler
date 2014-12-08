winston = require('winston')

logger = new winston.Logger(exitOnError: true)
logger.add winston.transports.Console, {
  level: process.env['LOG_LEVEL'] ? 'info'
  json: false
  colorize: true
  prettyPrint: true
}

module.exports = { logger }
