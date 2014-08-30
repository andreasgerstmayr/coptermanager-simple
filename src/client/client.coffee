repl = require 'repl'
moment = require 'moment'
SerialPortDriver = require './serialportdriver'
colors = require 'colors'
Log = require './log'

magenta = (text) ->
  text.toString().magenta

module.exports = class Client

  constructor: (options = {}) ->
    if not options.serialport
      throw 'please specify a serial port in the options'

    @port = options.serialport
    @baudrate = options.baudrate or 115200

    loglevel = options.loglevel or Log.Loglevel.ARDUINO
    @log = new Log.Logger(loglevel, moment())
    @log.on 'log', console.log

    @driver = new SerialPortDriver
    @driver.on 'line', @lineReceived

    @bound = false
    @reset()

  reset: ->
    @afterOffset = 0
    @state =
      throttle: 0
      rudder: 0x7F
      aileron: 0x7F
      elevator: 0x7F

  lineReceived: (line) =>
    @log.arduino line
    if line == 'Bound'
      @bound = true

  isBound: ->
    return @bound

  requireBound: (cb) ->
    if @isBound()
      return true
    else
      @log.error('this drone is not bound')
      cb(result: 'error', error: 'this drone is not bound')
      return false

  sendControlPacket: (cb) ->
    @driver.sendControlPacket(@state.throttle, @state.rudder, @state.aileron, @state.elevator, cb)

  rangeCheck: (value, min, max, cb) ->
    if 0x00 <= value <= 0xFF
      return true
    else
      @log.info "value #{magenta(value)} out of range (#{magenta(min)} - #{magenta(max)}), skipping..."
      cb(result: 'error', error: "value #{value} out of range (#{min} - #{max})")
      return false

  valueCheck: (value, possibleValues, cb) ->
    if value in possibleValues
      return true
    else
      @log.info "invalid value #{magenta(value)}, possible values: #{magenta(possibleValues)}, skipping..."
      cb(result: 'error', error: "invalid value #{value}, possible values: #{possibleValues}")
      return false

  after: (duration, fn) ->
    setTimeout(fn.bind(this), @afterOffset + duration)
    @afterOffset += duration
    return this

  exit: ->
    @log.info('exiting...')
    process.exit()

  startRepl: ->
    @repl = repl.start({})
    @repl.context.client = this

  pollUntilBound: (cb) ->
    pollFn = =>
      if @bound
        cb()
      else 
        @log.info 'not bound yet, waiting...'
        setTimeout(pollFn, 3000)

    setTimeout(pollFn, 1000)

  bind: (cb) ->
    @log.info("bind")
    @driver.openSerialPort @port, @baudrate, (data) =>
      if data.result == 'error'
        @log.error data.error
        cb(result: 'error')
        @exit()
      else
        @pollUntilBound cb

  throttle: (value, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @rangeCheck(value, 0x00, 0xFF, cb)

    @log.info("throttle #{magenta(value)}")
    @state.throttle = value
    @sendControlPacket cb

  rudder: (value, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @rangeCheck(value, 0x34, 0xCC, cb)

    @log.info("rudder #{magenta(value)}")
    @state.rudder = value
    @sendControlPacket cb

  aileron: (value, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @rangeCheck(value, 0x45, 0xC3, cb)

    @log.info("aileron #{magenta(value)}")
    @state.aileron = value
    @sendControlPacket cb

  elevator: (value, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @rangeCheck(value, 0x3E, 0xBC, cb)
    
    @log.info("elevator #{magenta(value)}")
    @state.elevator = value
    @sendControlPacket cb

  setFlip: (state, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @valueCheck(value, ['on', 'off'], cb)

    @log.info("set flip #{magenta(state)}")
    @driver.sendSettingsPacket (if state == 'on' then 0x07 else 0x08), cb

  flipOn: (cb) -> @setFlip('on', cb)
  flipOff: (cb) -> @setFlip('off', cb)

  setLed: (state, cb = (->)) ->
    return if not @requireBound(cb)
    return if not @valueCheck(value, ['on', 'off'], cb)

    @log.info("set flip #{magenta(state)}")
    @driver.sendSettingsPacket (if state == 'on' then 0x05 else 0x06), cb

  ledOn: (cb) -> @setLed('on', cb)
  ledOff: (cb) -> @setLed('off', cb)

  disconnect: (cb = (->)) ->
    @reset()
    @sendControlPacket =>
      @sendControlPacket =>
        setTimeout @driver.close.bind(@driver, cb), 2000


  # compound API methods

  takeoff: (cb = (->)) ->
    return if not @requireBound(cb)

    @log.info('takeoff')

    # TODO optimize...
    @after 0, ->
      @throttle(15)
    #@after 200, ->
    #  @driver.throttle(50)
    #@after 200, ->
    #  @driver.throttle(80)
    #@after 200, ->
    #  @driver.throttle(120)
    # after ... call cb with this


  land: (cb = (->)) ->
    return if not @requireBound(cb)
      
    @log.info('land')
    # TODO: smooth land
