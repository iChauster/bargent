var express = require('express');
var path = require('path');
var favicon = require('static-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var http = require('http');
var request = require('superagent');

var routes = require('./routes/index');
var users = require('./routes/users');

var app = express();

 var apiKey = "d914174469cc843bb832513eda8b644b";
 var ob =  {
              "name": "Walmart",
              "category" : [
              "Pharmacy, Food, Grocery"],
             "address": {
                 "street_number": "17",
                   "street_name": "Cat",
                   "city": "Detroit",
                   "state": "MI",
                   "zip": "48201"
           },
               "geocode": {
                   "lat": 42,
                   "lng": 83
               }
           }
//Config Stuff
var Config = (function() {
  function Config() { }
  Config.baseUrl = "http://api.reimaginebanking.com";

  Config.getApiKey = function() {
    return this.apiKey;
  };

  Config.setApiKey = function(key) {
    this.apiKey = key;
  };

  Config.request = request;

  return Config;
})();
Config.setApiKey(apiKey);

 var reqy = Config.request;
//Merchant Stuff
var Merchant = (function() {
  function Merchant() {}

    Merchant.initWithKey = function(apiKey) {
        Config.setApiKey(apiKey);
        return this;
    }

    Merchant.urlWithEntity = function() {
        console.log(Config.baseUrl+'/merchants');
        return Config.baseUrl+'/merchants';
    }

    Merchant.apiKey = function() {
        return '?key=' + Config.apiKey;
    }
    Merchant.getMerchant = function(id, callback) {
    reqy.get(this.urlWithEntity() + '/' + id + this.apiKey())
      .end(function(err, res) {
        if (err) {
          console.log(err.message);
          return;
        }
        callback(JSON.parse(res.text));
      });
    }
    Merchant.createMerchant = function(merchant, callback) {
        console.log('go');
        console.log(merchant)
        console.log(this.urlWithEntity() + this.apiKey());
    request.post(this.urlWithEntity() + this.apiKey())
      .set({'Content-Type': 'application/json'})
      .send(merchant)
      .end(function(err, res) {
        if (err) {
          console.log(err.message);
          return;
        }
        /*
           {
               "name": "string",
               "address": {
                   "street_number": "string",
                   "street_name": "string",
                   "city": "string",
                   "state": "string",
                   "zip": "string",
           },
               "geocode": {
                   "lat": 0,
                   "lng": 0,
               }
           }
           */
        callback(res);

      });
    
}


    return Merchant;

})();

module.exports = Merchant;
module.exports = Config;
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(favicon());
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/users', users);

/// catch 404 and forwarding to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

/// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});

app.listen(process.env.PORT || 3000, function(){
  console.log("bargent: port : %d in %s", this.address().port, app.settings.env);
});
/*Merchant.createMerchant(ob,function(){
    console.log('gucci mane in da house');
})*/



module.exports = app;
