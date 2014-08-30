express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  res.redirect('copter/keyboard')

router.get '/keyboard', (req, res) ->
  res.render('copter/keyboard', {})

router.get '/code', (req, res) ->
  res.render('copter/code', {})

module.exports = router
