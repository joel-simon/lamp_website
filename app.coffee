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

lamps = [
  {
    name: 'Okawara Desk #1',
    icon: 'desk-1/icon.png',
    lead: 'desk-1/screenshot.png',
    images: [
      'desk-1/IMG_4911.jpg',
      'desk-1/IMG_4913.jpg',
      'desk-1/IMG_4917.jpg',
      'desk-1/IMG_4918.jpg',
      'desk-1/IMG_4921.jpg',
      'desk-1/IMG_4923.jpg'
    ]
  }, {
    name: 'Okawara Wall #1',
    icon: 'wall-1/icon.png',
    lead: 'wall-1/screenshot.png',
    images: [
      'wall-1/DSC03269.jpg',
      'wall-1/DSC03276.jpg',
      'wall-1/DSC03278.jpg',
      'wall-1/DSC03318.jpg',
      'wall-1/DSC03326.jpg',
      'wall-1/DSC03361.jpg',
    ]
  }, {
    name: 'Okawara Table #3',
    icon: 'table-3/icon.png',
    lead: 'table-3/lead.png',
    images: [
      'table-3/IMG_2850.jpg'
      'table-3/IMG_2853.jpg'
      'table-3/IMG_2863.jpg'
    ]
  }, {
    name: 'Okawara Table #2',
    icon: 'table-2/icon.png',
    lead: 'table-2/lead.png',
    images: [
      'table-2/IMG_2741.jpg'
      'table-2/IMG_2753.jpg'
      'table-2/IMG_2772.jpg'
    ]
  }
]

# lamps = []
# lamp_path = '/imgs/lamps'

# directories = fs.readdirSync('public'+lamp_path).filter((f) -> fs.statSync('public'+lamp_path+"/"+f).isDirectory())
# # directories = [
# #   'desk'
# # ]
# for d in directories
#   lamp = {'name': d, 'photos': []}
#   for f in fs.readdirSync("public/#{lamp_path}/#{d}")
#     lamp.photos.push("#{lamp_path}/#{d}/#{f}")
#   lamps.push(lamp)

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
