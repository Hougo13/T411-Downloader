path = require 'path'
T411 = require 't411'
EventEmitter =  require 'events'
parse = require 'parse-torrent'
fs =  require 'fs'
util = require 'util'

event = new EventEmitter
clientT411 = new T411

sorts_params = {
  x265: 6,
  x264: 1,
  1080: 3,
  720: 2,
  null: 0.5
}
path = "%USERPROFILE%\\Downloads\\"
connected = 0

class t411
  constructor: (params) ->
    if params['path'] then path = params['path']
    if params['sorts_params'] then sorts_params = params['sorts_params']
    @connected
    self = @
    clientT411.auth params['user'], params['password'], (err) ->
      if err then throw err
      connected = 1
      self['client'] = clientT411
      self['connected'] = 1
      self.emit "connected"

  find: (query, options, callback) ->
      if typeof(options) == "function"
        callback = options
        options = {}
        cat = 631
      else
        if !options[0]
          cat = 631
        else
          cat = 433
      clientT411.search query, {limit: 10000, cid: cat}, (err, res) ->
        if err then throw err
        error = ""
        updateTorrents = []
        query_split = query.toLowerCase().split(" ")
        query = ""
        for obj in query_split
          query += "-"+obj
        query = query.substring(1)

        for torrent in res.torrents
          if typeof(torrent) == 'object'
            score = torrent['seeders']
            if torrent['rewritename'].indexOf('hevc') >= 0 || torrent['rewritename'].indexOf('x265') >= 0 || torrent['rewritename'].indexOf('h265') >= 0
              score = score*sorts_params['x265']
            else if torrent['rewritename'].indexOf('x264') >= 0 || torrent['rewritename'].indexOf('h264') >= 0
              score = score*sorts_params['x264']
            else
              score = score*sorts_params['null']

            if torrent['rewritename'].indexOf('1080') >= 0
              score = score*sorts_params['1080']
            else if torrent['rewritename'].indexOf('720') >= 0
              score = score*sorts_params['720']
            else
              score = score*sorts_params['null']
            torrent['score'] = score
            if torrent['rewritename'].indexOf(query) >= 0 && (torrent['rewritename'].indexOf('vostfr') >= 0 || torrent['rewritename'].indexOf('multi') >= 0)
              if options.length > 0
                if torrent['rewritename'].indexOf(options.toLowerCase()) >= 0
                  updateTorrents.push torrent
              else
                updateTorrents.push torrent

        updateTorrents.sort (a,b) ->
          if a.score < b.score
            return 1
          if a.score > b.score
            return -1
          return 0

        if updateTorrents.length <= 0
          error = "No torrent found"

        callback error, updateTorrents

  download: (query, options, callback) ->
    if typeof(options) == "function"
      callback = options
      options = {}
    self = @
    self.find query, options, (err, res) ->
      if err
        callback err, res
      else
      self.get res[0]["id"], (err, res) ->
        callback err, res

  get: (id, callback) ->
    clientT411.download id, (err, buf) ->
      if err then throw err
      parsed = parse(buf)
      name = parsed['name']+".torrent"
      fs.writeFile path+name, buf, (err) ->
        callback name+" is download to "+path

util.inherits(t411, EventEmitter)

module.exports = t411
