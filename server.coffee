express = require 'express'
http = require 'http'
mysql = require 'mysql'
mongodb = require 'mongodb'
pg = require 'pg'

app = express()
server = http.createServer app

SERVERS =
  mysql:
    local: 'mysql://dbtest:dbtest@127.0.0.1/dbtest'
    remote: 'mysql://dbtest:dbtest@remote/dbtest'
  postgres:
    local: 'postgres://dbtest:dbtest@127.0.0.1/dbtest'
    remote: 'postgres://dbtest:dbtest@remote/dbtest'
  mongodb:
    local: 'mongodb://127.0.0.1:27017/dbtest'
    remote: 'mongodb://remote:27017/dbtest'

app.configure ->
  app.set 'port', process.env.PORT || 9000
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.send '<!doctype html><html><head><title>DBTest</title></head><body><h1>DBTest</h1>' +
    '<p>Available tests:</p>' +
    '<ul>' +
    '<li><a href="/mysql/seq/local/100">/mysql/seq/local/N</a></li>' +
    '<li><a href="/mysql/seq/remote/100">/mysql/seq/remote/N</a></li>' +
    '<li><a href="/postgres/seq/local/100">/postgres/seq/local/N</a></li>' +
    '<li><a href="/postgres/seq/remote/100">/postgres/seq/remote/N</a></li>' +
    '<li><a href="/mongodb/seq/local/100">/mongodb/seq/local/N</a></li>' +
    '<li><a href="/mongodb/seq/remote/100">/mongodb/seq/remote/N</a></li>' +
    '</ul>' +
    '</body></html>'

app.get '/mysql/seq/:type/:n', (req, res) ->
  n = parseInt(req.params.n, 10)
  data =
    status: 'ok',
    sequential: n,
    type: req.params.type
    errors: 0
    results: 0
    lasterr: null
  # Perform N sequential SQL queries through local or remote MySQL
  conn = mysql.createConnection SERVERS.mysql[req.params.type]
  conn.connect()
  execNext = (i) ->
    if i > n
      # Done
      conn.end()
      res.json data
    else
      # Exec one more
      conn.query "SELECT id, str FROM testtable WHERE id=?", [i % 1000], (err, results) ->
        if err
          data.errors += 1
          data.lasterr = err
        else
          data.results += 1
        execNext i+1
  execNext 1

app.get '/postgres/seq/:type/:n', (req, res) ->
  n = parseInt(req.params.n, 10)
  data =
    status: 'ok',
    sequential: n,
    type: req.params.type
    errors: 0
    results: 0
    lasterr: null
  # Perform N sequential SQL queries through local or remote Postgres
  client = new pg.Client(SERVERS.postgres[req.params.type])
  client.connect (err) ->
    if err
      # Connect failed
      data.lasterr = err
      res.json data
    else
      # Okay start querying
      execNext = (i) ->
        if i > n
          # Done
          client.end()
          res.json data
        else
          # Exec one more
          client.query "SELECT id, str FROM testtable WHERE id=" + (i % 1000), (err, results) ->
            if err
              data.errors += 1
              data.lasterr = err
            else
              data.results += 1
            execNext i+1
      execNext 1

app.get '/mongodb/seq/:type/:n', (req, res) ->
  n = parseInt(req.params.n, 10)
  data =
    status: 'ok',
    sequential: n,
    type: req.params.type
    errors: 0
    results: 0
    lasterr: null
  # Perform N sequential SQL queries through local or remote MongoDB
  mongodb.MongoClient.connect SERVERS.mongodb[req.params.type], (err, db) ->
    if err
      data.lasterr = err
      res.json data
    else
      coll = db.collection('testtable')
      execNext = (i) ->
        if i > n
          # Done
          db.close()
          res.json data
        else
          # Exec one more
          coll.findOne {_id:i}, (err, result) ->
            if err
              data.errors += 1
              data.lasterr = err
            else
              data.results += 1
            execNext i+1
      execNext 1

server.listen app.get('port'), ->
  console.log 'Express server listening at port', app.get('port')