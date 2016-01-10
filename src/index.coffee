path = require 'path'
T411 = require 't411'
EventEmitter =  require 'events'
parse = require 'parse-torrent'
fs =  require 'fs'

event = new EventEmitter
clientT411 = new T411

sorts_params = {
  x265: 4,
  x264: 1,
  1080: 3,
  720: 2,
  null: 0.5
}
connected = 0
path = ""

class t411
  constructor: (params) ->
    @user = params['user']
    @password = params['password']
    path = params['path']
    connect @user, @password

  download: (query, options, callback) ->
    if typeof(options) == "function"
      callback = options
      options = {}

    if connected == 1
      main query, options, callback
    else
      event.on "connected", ->
        main query, options, callback

connect = (user, password) ->
  clientT411.auth user, password, ->
    connected = 1
    event.emit "connected"

main = (query, options, callback) ->
  search query, options, (res) ->
    if res.total > 0
      filter res.torrents, query, options, (res) ->
        if res[0]
          sort res, (res) ->
            download res[0]['id'], (res) ->
              callback res
        else
          callback 'no result'
    else
      callback 'No result'

search = (query, cat, callback) ->
  if cat.length > 0
    cat = 433
  else
    cat = 631
  clientT411.search query, {limit: 10000, cid: cat}, (err, res) ->
    callback res

filter = (torrents, query, options, callback) ->

  updateTorrents = []
  query_split = query.toLowerCase().split(" ")
  query = ""
  for obj in query_split
    query += "-"+obj
  query = query.substring(1)

  for torrent in torrents

    if torrent['rewritename'].indexOf('hevc') >= 0 || torrent['rewritename'].indexOf('x265') >= 0 || torrent['rewritename'].indexOf('h265') >= 0
      torrent['encode'] = 'x265'
    else if torrent['rewritename'].indexOf('x264') >= 0 || torrent['rewritename'].indexOf('h264') >= 0
      torrent['encode'] = 'x264'
    else
      torrent['encode'] = null

    if torrent['rewritename'].indexOf('1080') >= 0
      torrent['quality'] = '1080'
    else if torrent['rewritename'].indexOf('720') >= 0
      torrent['quality'] = '720'
    else
      torrent['quality'] = null

    if torrent['rewritename'].indexOf(query) >= 0 && (torrent['rewritename'].indexOf('vostfr') >= 0 || torrent['rewritename'].indexOf('multi') >= 0)
      if options.length > 0
        if torrent['rewritename'].indexOf(options.toLowerCase()) >= 0
          updateTorrents.push torrent
      else
        updateTorrents.push torrent

  callback updateTorrents

sort = (torrents, callback) ->
  for torrent in torrents
    score = sorts_params[torrent['quality']] * sorts_params[torrent['encode']] * torrent['seeders']
    torrent['score'] = score
  torrents.sort (a,b) ->
    if a.score < b.score
      return 1
    if a.score > b.score
      return -1
    return 0
  callback torrents

download = (id, callback) ->
  clientT411.download id, (err, buf) ->
    parsed = parse(buf)
    name = parsed['name']+".torrent"
    fs.writeFile path+name, buf, (err) ->
      callback name+" is download to "+path
    callback name+" is download to "+path
module.exports = t411
