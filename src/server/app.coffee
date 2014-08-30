express = require('express');
path = require('path');
bodyParser = require('body-parser');
swig = require('swig');
routes = require('./routes/index');
copter = require('./routes/copter');
api = require('./routes/api');

app = express();

# view engine setup
app.engine('html', swig.renderFile);

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');
app.set('view cache', false);
swig.setDefaults({ cache: false });

app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/copter', copter);
app.use('/api', api);

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Not Found');
  err.status = 404;
  next(err);

# error handlers

# development error handler
# will print stacktrace
if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });

module.exports = app;
