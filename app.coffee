express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
fs = require 'fs'
app.set 'views', __dirname+'/views'
app.set 'view engine', 'jade'
app.use express.static(__dirname+'/public')
path = require 'path'

app.use coffeeMiddleware {
  src: __dirname+'/public'
  compress: false
  encodeSrc: false
  force: true
  debug: true
  bare: true
}

# lamps = fs.readdirSync('public/lamps')
#   .map( (file) -> path.join('public/lamps', file) )
#   .filter( (file) -> fs.statSync(file).isDirectory() )
#   .map (file) ->
#     files = fs.readdirSync(file).map((f) -> path.join(file, f))
#     type: file.match(/\/([a-z]+)/)[1]
#     name: file.split('/')[2]
#     img: files.filter((f) -> f.indexOf('.jpg') > -1)
#     obj: files.filter((f) -> f.indexOf('.obj') > -1)[0]
#     mtl: files.filter((f) -> f.indexOf('.mtl') > -1)[0]

# console.log lamps

app.get '/', (req, res) ->
  res.render 'index.jade', { lamps }

# catch 404 and forward to error handler
app.get '*', (req, res, next) ->
  res.redirect '/'

server = app.listen 3000, ()->
  host = server.address().address
  port = server.address().port
  console.log 'Luminating http://%s:%s', host, port
