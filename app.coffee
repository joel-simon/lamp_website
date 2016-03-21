express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'

app.set 'views', __dirname+'/views'
app.set 'view engine', 'jade'
app.use express.static(__dirname+'/public')

app.use coffeeMiddleware {
  src: __dirname+'/public'
  compress: false
  encodeSrc: false
  force: true
  debug: true
  bare: true
}

lamps = (num for num in [1..10])

app.get '/', (req, res) ->
  res.render 'index.jade', { lamps }

# catch 404 and forward to error handler
app.get '*', (req, res, next) ->
  res.redirect '/'

# app.use (err, req, res, next) ->
#   res.status err.status || 500
#   res.render 'error', {
#     message: err.message,
#     error: {}
#   }

server = app.listen 3000, ()->
  host = server.address().address
  port = server.address().port
  console.log 'Luminating http://%s:%s', host, port
