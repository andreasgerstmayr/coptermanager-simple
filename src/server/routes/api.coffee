express = require('express')
async = require('async')
_ = require('underscore')
stripColorCodes = require('stripcolorcodes')
router = express.Router()

router.post '/execute', (req, res) ->
  code = req.body.code
  client = req.app.get('client')

  outputFn = (data) ->
    res.write(stripColorCodes(data)+'\n')

  fn = new Function('client', code)

  client.log.on 'log', outputFn
  res.setHeader('Content-Type', 'text/plain')

  fn(client)

  client.after 0, ->
    client.log.removeListener 'log', outputFn
    client.resetAfterOffset()
    res.end()

router.post '/control', (req, res) ->
  client = req.app.get('client')
  validPropertyNames = _.intersection(_.keys(req.query), ['throttle', 'rudder', 'aileron', 'elevator'])

  async.concatSeries validPropertyNames, (name, cb) ->
    value = parseInt(req.query[name])
    client[name] value, (data) ->
      client.resetAfterOffset()
      cb(null, data)
  , (err, results) ->
    res.json(results)

router.post '/setting', (req, res) ->
  client = req.app.get('client')
  validPropertyNames = _.intersection(_.keys(req.query), ['led', 'flip'])
  
  async.concatSeries validPropertyNames, (name, cb) ->
    fn = 'set' + name.charAt(0).toUpperCase() + name.slice(1)
    value = req.query[name]
    client[fn] value, (data) ->
      client.resetAfterOffset()
      cb(null, data)
  , (err, results) ->
    res.json(results)

module.exports = router
