# t411-downloader
[![Dependency Status](https://david-dm.org/Hougo13/t411-downloader.svg)](https://david-dm.org/Hougo13/t411-downloader)

npm module to find and download torrent on t411
##Install
```
$ npm install t411-downloader
```
##Usage
```node
var t411Downloader = require('t411-downloader');

var t411 = new t411Downloader({
  user: "",
  password: "",
  path: ""
});

t411.download("Ash vs evil dead", "s01e02", function(res) {
  console.log(res);
});

t411.download("Birdman", function(res) {
  console.log(res);
});
```
