KeyCodes =
  Up: 38
  Down: 40
  Left: 37
  Right: 39
  W: 87
  S: 83
  A: 65
  D: 68

class @KeyboardControl

  constructor: (@endpoint, copterid) ->
    @throttle = 15
    @rudder = 0x7F
    @aileron = 0x7F
    @elevator = 0x7F
    @updateStatus()

    $(document).on 'keydown', @keyDown
    $('#takeoffBtn').on 'click', @takeoffBtnClicked
    $('#landBtn').on 'click', @landBtnClicked

  updateStatus: ->
    for name in ['throttle', 'rudder', 'aileron', 'elevator']
      $("##{name}Val").text(this[name])
    return

  sendCommand: (code) ->
    $.ajax
      type: 'POST'
      dataType: 'json'
      url: @endpoint,
      data: {code: code},
      success: (data) ->
        console.log data

  keyDown: (e) =>
    switch e.keyCode
      when KeyCodes.W
        @throttle += 10
        @throttle = 0xFF if @throttle > 0xFF
        @sendCommand("client.throttle(#{@throttle})")
      when KeyCodes.S
        @throttle -= 10
        @throttle = 0 if @throttle < 0
        @sendCommand("client.throttle(#{@throttle})")

      when KeyCodes.A
        @rudder -= 10
        @rudder = 0x34 if @rudder < 0x34
        @sendCommand("client.rudder(#{@rudder})")
      when KeyCodes.D
        @rudder += 10
        @rudder = 0xCC if @rudder > 0xCC
        @sendCommand("client.rudder(#{@rudder})")

      when KeyCodes.Up
        @elevator += 10
        @elevator = 0xBC if @elevator > 0xBC
        @sendCommand("client.elevator(#{@elevator})")
      when KeyCodes.Down
        @elevator -= 10
        @elevator = 0x3E if @elevator < 0x3E
        @sendCommand("client.elevator(#{@elevator})")

      when KeyCodes.Left
        @aileron -= 10
        @aileron = 0x45 if @aileron < 0x45
        @sendCommand("client.aileron(#{@aileron})")
      when KeyCodes.Right
        @aileron += 10
        @aileron = 0xC3 if @aileron > 0xC3
        @sendCommand("client.aileron(#{@aileron})")

    @updateStatus()

  takeoffBtnClicked: (e) =>
    @sendCommand('client.takeoff()')

  landBtnClicked: (e) =>
    @sendCommand('client.land()')
