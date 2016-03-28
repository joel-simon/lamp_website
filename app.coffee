express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
fs = require 'fs'
# app.set 'views', __dirname+'/views'
# app.set 'view engine', 'jade'
app.set('view engine', 'html')
app.use express.static(__dirname+'/public')


app.use coffeeMiddleware {
  src: __dirname+'/public/src'
  compress: false
  encodeSrc: false
  force: true
  debug: true
  bare: true
}

# app.get '/', (req, res) ->
#   res.render 'index.jade', { lamps }

app.get '/', (req, res) ->
  res.render 'index.html'

# catch 404 and forward to error handler
app.get '*', (req, res, next) ->
  res.redirect '/'

server = app.listen 3000, ()->
  host = server.address().address
  port = server.address().port
  console.log 'Luminating http://%s:%s', host, port
