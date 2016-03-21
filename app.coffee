express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
fs = require 'fs'
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

lamp_imgs = null

fs.readdir 'public/imgs/lamps', (err, files) ->
  lamp_imgs = files

app.get '/', (req, res) ->
  res.render 'index.jade', { lamp_imgs }

# catch 404 and forward to error handler
app.get '*', (req, res, next) ->
  res.redirect '/'

server = app.listen 3000, ()->
  host = server.address().address
  port = server.address().port
  console.log 'Luminating http://%s:%s', host, port
