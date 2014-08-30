colors = require 'colors'
app = require './app'

module.exports = class server
  constructor: (client, host = 'localhost', port = 3000) ->
    app.set('host', host)
    app.set('port', port)
    app.set('client', client)

  url: ->
    host = app.get('host')
    port = app.get('port')
    return "http://#{host}:#{port}"

  start: (cb) ->
    server = app.listen app.get('port'), app.get('host'), =>
      console.log ("Webinterface started on " + @url().underline + "\n").bold
      cb()
