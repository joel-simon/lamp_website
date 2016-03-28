AWS = require 'aws-sdk'
AWS.config.loadFromPath __dirname+'/config.json'
s3 = new AWS.S3()
fs = require 'fs'
CoffeeScript = require 'coffee-script'
path =  require 'path'

compileFile = (file) ->
  code = fs.readFileSync "#{__dirname}/#{file}",'utf-8'
  if file.match(/.+\.coffee/g)?
    CoffeeScript.compile code
  else
    code

src = 'public/src/'
files = (fs.readdirSync(path.join(__dirname,src)))
  .map((f) -> path.join(src+f))
  .filter((f) -> f.match(/.+\.(coffee|js)/g)?)
  .map(compileFile)

params =
  Bucket: 'simonlamps.com'
  Key: 'main.js'
  ACL: 'public-read'
  Body: files.join ''
  ContentType: 'text/javascript'
s3.putObject params, (err) ->
  console.log err or 'Put JS'

params =
  Bucket: 'simonlamps.com'
  Key: 'index.html'
  ACL: 'public-read'
  Body: fs.readFileSync "#{__dirname}/public/index.html",'utf-8'
  ContentType: 'text/html'
s3.putObject params, (err) ->
  console.log err or 'Put HTML'
