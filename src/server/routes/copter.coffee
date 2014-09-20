express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  userAgent = req.headers['user-agent']
  if /mobile/i.test(userAgent)
  	res.redirect('copter/mobile')
  else
  	res.redirect('copter/keyboard')

router.get '/keyboard', (req, res) ->
  res.render('copter/keyboard', {})

router.get '/code', (req, res) ->
  res.render('copter/code', {})

router.get '/mobile', (req, res) ->
  res.render('copter/mobile', {})

module.exports = router
