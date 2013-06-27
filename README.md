# symfio-contrib-express

> Launch express application after all plugins is loaded.

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt8,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt8&guest=1)
[![Dependency Status](https://gemnasium.com/symfio/symfio-contrib-express.png)](https://gemnasium.com/symfio/symfio-contrib-express)

## Usage

```coffee
symfio = require "symfio"

container = symfio "example", __dirname
container.set "port", 80

container.use require "symfio-contrib-express"

container.use (get) ->
  get "/", ->
    (req, res) ->
      res.send "Hello World!"

container.load()
```

## Provides

* __express__ — Original express module.
* __app__ — Express application.
* __server__ — `http.Server` instance for express application.
* __get__ — wrapped `app.get` method. Last arguments must be controller factory. Other HTTP methods like `post` and `delete` also provided.

## Can be configured

* __autoload__ - Listen port after loading. Default is `true`.
* __port__ - Port for listening. Default value is `3000`.
