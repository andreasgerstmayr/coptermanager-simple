JOYSTICK_RADIUS = 120

class @MobileControl

  constructor: (@endpoint) ->
    @joystickRight = new VirtualJoystick({
      container: document.body,
      strokeStyle: 'cyan',
      limitStickTravel: true,
      stickRadius: JOYSTICK_RADIUS
    })
    @joystickRight.addEventListener 'touchStartValidation', (event) ->
      touch = event.changedTouches[0]
      if touch.pageX < window.innerWidth/2 
        return false
      return true

    @joystickLeft = new VirtualJoystick({
      container: document.body,
      strokeStyle: 'orange',
      limitStickTravel: true,
      stickRadius: JOYSTICK_RADIUS
    })
    @joystickLeft.addEventListener 'touchStartValidation', (event) ->
      touch = event.changedTouches[0]
      if touch.pageX >= window.innerWidth/2 
        return false
      return true

    setInterval @observe, 50

  sendCommand: (method) ->
    $('#debug').text(method)

    $.ajax
      type: 'POST'
      url: @endpoint + method,
      success: (data) ->
        $('#error').text('')

        data = [].concat(data) # if data is not an array, make it an array
        for d in data # one element per command
          if d.result != 'success'
            if d.error
              $('#error').text(d.error)
            else
              $('#error').text("unknown error")

  observe: =>
    ldy = @joystickLeft.deltaY() / JOYSTICK_RADIUS  # normalize
    ldx = @joystickLeft.deltaX() / JOYSTICK_RADIUS
    rdy = @joystickRight.deltaY() / JOYSTICK_RADIUS
    rdx = @joystickRight.deltaX() / JOYSTICK_RADIUS

    if ldy >= 0
      throttle = 15 - (15 - 0) * ldy
    else
      throttle = 15 + (0xFF - 15) * (-ldy)

    if ldx >= 0
      rudder = 0x7F - (0x7F - 0x34) * ldx
    else
      rudder = 0x7F + (0xCC - 0x7F) * (-ldx)

    if rdx >= 0
      aileron = 0x7F - (0x7F - 0x45) * rdx
    else
      aileron = 0x7F + (0xC3 - 0x7F) * (-rdx)

    if rdy >= 0
      elevator = 0x7F - (0x7F - 0x34) * rdy
    else
      elevator = 0x7F + (0xCC - 0x7F) * (-rdy)

    @sendCommand("/control?throttle=#{throttle}&rudder=#{rudder}&aileron=#{aileron}&elevator=#{elevator}")
