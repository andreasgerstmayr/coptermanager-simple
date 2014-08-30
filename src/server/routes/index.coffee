express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  res.redirect('/copter')

module.exports = router
