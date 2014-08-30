
class @CodeControl
  
  constructor: (@endpoint) ->
    window.onerror = @javascriptError

    @setupEditor()
    $('#executeBtn').on 'click', @executeBtnClick
    $('#emergencyBtn').on 'click', @emergencyBtnClick

  setupEditor: ->
    @editor = ace.edit('codeeditor')
    @editor.getSession().setUseWorker(false)
    @editor.setTheme('ace/theme/xcode')
    @editor.getSession().setMode('ace/mode/javascript')

  executeBtnClick: =>
    code = @editor.getSession().getValue()
    @executeCode code

  emergencyBtnClick: =>
    @executeCode('client.disconnect()')

  showExecuteBtn: =>
    if @isFading
      setTimeout @showExecuteBtn, 2000
    else
      @isFading = true
      $('#runningBtn').fadeOut complete: =>
        $('#runningBtn').addClass('hide')
        $('#executeBtn').fadeIn complete: =>
          @isFading = false

  showRunningBtn: ->
    if @isFading
      setTimeout @showRunningBtn, 2000
    else
      @isFading = true
      $('#executeBtn').fadeOut complete: =>
        $('#runningBtn').hide().removeClass('hide').fadeIn complete: =>
          @isFading = false

  executeCode: (code) ->
    @showRunningBtn()
    $('#consoleContainer').empty()

    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = =>
      if xhr.status == 200
        $('#consoleContainer').text(xhr.responseText)
        if xhr.readyState == 4
          @showExecuteBtn()

    xhr.open('POST', @endpoint, true)
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhr.send($.param({code: code}))

  javascriptError: (error, file, lineno) ->
    $('#consoleContainer').append "<p class='text-danger'>JavaScript error: #{error}, lineno: #{lineno}</p>"
