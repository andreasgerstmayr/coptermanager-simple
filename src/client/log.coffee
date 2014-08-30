EventEmitter = require('events').EventEmitter
colors = require 'colors'
moment = require 'moment'
_ = require 'underscore'

Loglevel = {
  ERROR: 0,
  INFO: 1,
  ARDUINO: 2,
  DEBUG: 3
}

Logger = class Logger

  _.extend @prototype, EventEmitter.prototype

  constructor: (@loglevel, @startTime) ->

  print: (message) ->
    timeElapsed = moment().diff(@startTime)
    durationStr = moment.utc(timeElapsed).format("mm:ss.SSS")
    @emit 'log', '[' + durationStr.grey + '] ' + message

  printLevel: (level, level_name, message) ->
    if @loglevel >= level
      @print('[' + level_name.cyan + '] ' + message);

  error: (message) -> @printLevel(Loglevel.ERROR, 'ERROR', message)
  info: (message) -> @printLevel(Loglevel.INFO, 'INFO', message)
  arduino: (message) -> @printLevel(Loglevel.ARDUINO, 'ARDUINO', message)
  debug: (message) -> @printLevel(Loglevel.DEBUG, 'DEBUG', message)

module.exports =
  Logger: Logger,
  Loglevel: Loglevel
