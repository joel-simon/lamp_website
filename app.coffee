express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
fs = require 'fs'
path = require 'path'
# app.set 'views', __dirname+'/views'
# app.set 'view engine', 'jade'

app.set('view engine', 'jade')
app.set('views', path.join(__dirname, '/views'));

app.use express.static(__dirname+'/public')

app.use coffeeMiddleware {
  src: __dirname+'/public'
  compress: false
  encodeSrc: false
  force: true
  debug: true
  bare: true
}

lamps = []
lamp_path = '/imgs/lamps'

directories = fs.readdirSync('public'+lamp_path).filter((f) -> fs.statSync('public'+lamp_path+"/"+f).isDirectory())

for d in directories
  lamp = []
  for f in fs.readdirSync("public/#{lamp_path}/#{d}")
    lamp.push("#{lamp_path}/#{d}/#{f}")
  lamps.push(lamp)

console.log lamps

app.get '/', (req, res) ->
  res.render 'index.jade', { lamps }

# Catch 404 and forward to error handler.
app.get '*', (req, res, next) ->
  res.redirect '/'

server = app.listen 3001, ()->
  host = server.address().address
  port = server.address().port
  console.log 'Luminating http://%s:%s', host, port
