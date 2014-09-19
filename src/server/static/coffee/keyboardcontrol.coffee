KeyCodes =
  Up: 38
  Down: 40
  Left: 37
  Right: 39
  W: 87
  S: 83
  A: 65
  D: 68
  L: 76
  F: 70


class @KeyboardControl

  constructor: (@endpoint, copterid) ->
    @reset()

    $(document).on 'keydown', @keyDown
    $('#takeoffBtn').on 'click', @takeoffBtnClicked
    $('#landBtn').on 'click', @landBtnClicked
    $('#resetLink').on 'click', @resetLinkClicked

    setInterval @updateBindingState, 3000

  reset: ->
    @throttle = 15
    @rudder = 0x7F
    @aileron = 0x7F
    @elevator = 0x7F
    @led = 'on'
    @flip = 'off'
    $('#stateVal').text('not bound')
    @updateStatus()

  updateStatus: ->
    for name in ['throttle', 'rudder', 'aileron', 'elevator', 'led', 'flip']
      $("##{name}Val").text(this[name])
    return

  updateBindingState: =>
    $.ajax
      type: 'GET'
      url: @endpoint + '/state',
      success: (data) ->
        $('#stateVal').text(if data.bound then 'bound' else 'not bound')

  sendCommand: (method) ->
    $.ajax
      type: 'POST'
      url: @endpoint + method,
      success: (data) ->
        data = [].concat(data) # if data is not an array, make it an array
        for d in data # one element per command
          if d.result != 'success'
            if d.error
              alert d.error
            else
              alert "unknown error"

  keyDown: (e) =>
    switch e.keyCode
      when KeyCodes.W
        @throttle += 10
        @throttle = 0xFF if @throttle > 0xFF
        @sendCommand("/control?throttle=#{@throttle}")
      when KeyCodes.S
        @throttle -= 10
        @throttle = 0 if @throttle < 0
        @sendCommand("/control?throttle=#{@throttle}")

      when KeyCodes.A
        @rudder -= 10
        @rudder = 0x34 if @rudder < 0x34
        @sendCommand("/control?rudder=#{@rudder}")
      when KeyCodes.D
        @rudder += 10
        @rudder = 0xCC if @rudder > 0xCC
        @sendCommand("/control?rudder=#{@rudder}")

      when KeyCodes.Up
        @elevator += 10
        @elevator = 0xBC if @elevator > 0xBC
        @sendCommand("/control?elevator=#{@elevator}")
      when KeyCodes.Down
        @elevator -= 10
        @elevator = 0x3E if @elevator < 0x3E
        @sendCommand("/control?elevator=#{@elevator}")

      when KeyCodes.Left
        @aileron -= 10
        @aileron = 0x45 if @aileron < 0x45
        @sendCommand("/control?aileron=#{@aileron}")
      when KeyCodes.Right
        @aileron += 10
        @aileron = 0xC3 if @aileron > 0xC3
        @sendCommand("/control?aileron=#{@aileron}")

      when KeyCodes.L
        @led = if @led == 'on' then 'off' else 'on'
        @sendCommand("/setting?led=#{@led}")

      when KeyCodes.F
        @flip = if @flip == 'on' then 'off' else 'on'
        @sendCommand("/setting?flip=#{@flip}")

    @updateStatus()

  resetLinkClicked: (e) =>
    @sendCommand '/reset'
    @reset()

  takeoffBtnClicked: (e) =>
    @sendCommand('client.takeoff()')

  landBtnClicked: (e) =>
    @sendCommand('client.land()')
