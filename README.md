# t411-downloader
[![Dependency Status](https://david-dm.org/Hougo13/t411-downloader.svg)](https://david-dm.org/Hougo13/t411-downloader)

npm module to find and download torrent on t411
##Install
```
$ npm install t411-downloader
```
##Usage

###Declaration
Minimal:
```node
var t411Downloader = require('t411-downloader');

var t411 = new t411Downloader({
  user: "t411_username",
  password: "t411_password"
});
```
Complete:
```node
var t411Downloader = require('t411-downloader');

var t411 = new t411Downloader({
  user: "t411_username",
  password: "t411_password",
  path: "path\\to\\download\\",
  sorts_params: {
    x265: 6,
    x264: 1,
    1080: 3,
    720: 2,
    null: 0.5
  }
});
```
###Methods
Download:
```node
// s01e02 or s01 is needed only if is show
t411.download("title", "s01e02 (optional)",function(err, res){
  // err return when no torrent found
  // res return the name and the path of download torrent
});
```
Find:
```node
t411.find("title", "s01e02 (optional)",function(err, res){
  // err return when no torrent found
  // res return a sort array of torrents
});
```
Get:
```node
t411.get("torrent id", function(res){
  // res return the name and the path of download torrent
});
```
###Events
```node
t411.on("connected", function(){
  // body
});
```
###Client
Access to t411 module (refer to t411 doc)
```node
t411.client
```
###Example
Command line interface:
```
Download > Interstellar
Download > Ash vs Evil dead #s01e02
```
```node
var t411Downloader = require('t411-downloader');
var readline = require('readline');

var t411 = new t411Downloader({
  user: "Username",
  password: "password",
  path: "path_to_down\\"
});

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

t411.on("connected", function() {
  rl.setPrompt("Download > ");
  rl.prompt();
  rl.on('line', function(command) {
    command = command.split(" #");
    if (command[1]) {
      t411.find(command[0], command[1], function(err, res) {
        if err throw err
        console.log("Found : " + res[0]['name']);
        rl.question('Get it ? (y/n) ', function(ans) {
          if (ans === "y") {
            t411.get(res[0]['id'], function(res) {
              console.log(res);
              rl.close();
              rl.prompt();
            });
          } else {
            console.log('Sorry');
            rl.close();
            rl.prompt();
          }
        });
      });
    } else {
      t411.find(command[0], function(err, res) {
        if (err) {
          console.log("Sorry: " + err);
          rl.prompt();
        } else {
          console.log("Found : " + res[0]['name']);
          rl.question('Get it ? (y/n) ', function(ans) {
            if (ans === "y") {
              t411.get(res[0]['id'], function(res) {
                console.log(res);
                rl.prompt();
              });
            } else {
              console.log('Sorry');
              rl.prompt();
            }
          });
        }
      });
    }
  });
});
```
