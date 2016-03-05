t411Downloader = require './../lib/index'
readline = require 'readline'

t411 = new t411Downloader {
  user: "",
  password: "",
  path: ""
}

rl = readline.createInterface {
  input: process.stdin,
  output: process.stdout
}

t411.on "connected", ->
  rl.setPrompt("Download > ")
  rl.prompt()

rl.on 'line', (command) ->
  command = command.split(" #")
  if command[1]
    t411.find command[0], command[1], (err, res) ->
      if err
        console.log "Sorry: "+err
        rl.prompt()
      else
        console.log "Found : "+res[0]['name']
        rl.question 'Get it ? (y/n) ', (ans) ->
          if ans == "y"
            t411.get res[0]['id'], (res) ->
              console.log res
              rl.prompt()
          else
            console.log 'Sorry'
            rl.prompt()
  else
    t411.find command[0], (err, res) ->
      if err
        console.log "Sorry: "+err
        rl.prompt()
      else
        console.log "Found : "+res[0]['name']
        rl.question 'Get it ? (y/n) ', (ans) ->
          if ans == "y"
            t411.get res[0]['id'], (res) ->
              console.log res
              rl.prompt()
          else
            console.log 'Sorry'
            rl.prompt()
