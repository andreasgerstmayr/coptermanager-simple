EventEmitter = require('events').EventEmitter
SerialPort = require('serialport').SerialPort
_ = require 'underscore'

module.exports = class SerialPortDriver

  _.extend @prototype, EventEmitter.prototype

  constructor: ->
    @receiveBuffer = ""
    
  dataReceived: (data) =>
    @receiveBuffer += data.toString()
    lines = @receiveBuffer.split("\r\n")
    @receiveBuffer = lines.pop()

    for line in lines
      @emit 'line', line

  openSerialPort: (port, baudrate = 115200, cb = (->)) ->
    @serialPort = new SerialPort port, {baudrate: baudrate}, true, (error) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        @serialPort.on 'data', @dataReceived
        @sendStatePacket(cb)

  sendPacket: (packet, cb = (->)) ->
    @serialPort.write packet, (error, results) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        cb(result: 'success')


  sendControlPacket: (throttle, rudder, aileron, elevator, cb = (->)) ->
    buffer = new Buffer([0x03, throttle, rudder, aileron, elevator])
    @sendPacket(buffer, cb)

  sendSettingsPacket: (cmd, cb = (->)) ->
    buffer = new Buffer([0x04, cmd, 0, 0, 0])
    @sendPacket(buffer, cb)

  sendStatePacket: (cb = (->)) ->
    buffer = new Buffer([0x01, 0, 0, 0, 0])
    @sendPacket(buffer, cb)

  sendResetPacket: (cb = (->)) ->
    buffer = new Buffer([0x02, 0, 0, 0, 0])
    @sendPacket(buffer, cb)

  closeSerialPort: (cb = (->)) ->
    @serialPort.close(cb)
