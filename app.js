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

//Config stuff
var Config = (function() {
  function Config() { }
  Config.baseUrl = "http://api.reimaginebanking.com:80";

  Config.getApiKey = function() {
    return this.apiKey;
  };

  Config.setApiKey = function(key) {
    this.apiKey = key;
  };

  Config.request = request;

  return Config;
})();

var reqy = Config.request;


//Account stuff
var Account = (function() {
  function Account() {}

  Account.initWithKey = function(apiKey) {
    Config.setApiKey(apiKey);
    return this;
  };

  Account.urlWithEntity = function() {
    return Config.baseUrl + '/accounts';
  };

  Account.urlWithCustomerEntity = function() {
    return Config.baseUrl + '/customers';
  };

  Account.apiKey = function() {
    return '?key=' + Config.apiKey;
  };

  Account.getAllAccounts = function(callback) {
      reqy.get(this.urlWithEntity()+this.apiKey())
        .end(function(err, res) {
          if (err) {
            console.log(err.message);
            return;
          }
          callback(JSON.parse(res.text));
        });
  };

  Account.getAllByType = function(type, callback) {
      reqy
        .get(this.urlWithEntity()+'?type='+type+this.apiKey())
        .end(function(err, res) {
          if (err) {
            console.log(err.message);
            return;
          }
          callback(JSON.parse(res.text));
        });
  };

  Account.getAccountById = function(id, callback) {
    reqy.get(this.urlWithEntity()+'/'+id+this.apiKey())
      .end(function(err, res) {
        if (err) {
          console.log(err.message);
          return;
        }
        callback(JSON.parse(res.text));
      });
  };

  Account.getAllByCustomerId = function(customerId, callback) {
      reqy
        .get(this.urlWithCustomerEntity() + '/' + customerId + '/accounts' +
            this.apiKey())
        .end(function(err, res) {
          if (err) {
            console.log(err.message);
            return;
          }
          callback(JSON.parse(res.text));
        });
  };
})();

//Purchases stuff
var Purchase = (function() {
  function Purchase() {}

    Purchase.initWithKey = function(apiKey) {
        Config.setApiKey(apiKey);
        return this;
    };

    Purchase.urlWithEntity = function() {
        return Config.baseUrl+'/purchases/';
    };

    Purchase.urlWithAccountEntity = function() {
        return Config.baseUrl+'/accounts/';
    };

    Purchase.apiKey = function() {
        return '?key=' + Config.apiKey;
    };

    Purchase.getAll = function(id, callback) {
        reqy.get(this.urlWithAccountEntity()+id+'/purchases' + this.apiKey())
      .end(function(err, res) {
        if (err) {
          console.log(err.message);
          return;
        }
        callback(JSON.parse(res.text));
      });
    };

    Purchase.getPurchase = function(id, callback) {
        reqy.get(this.urlWithEntity()+id + this.apiKey())
      .end(function(err, res) {
        if (err) {
          console.log(err.message);
          return;
        }
        callback(JSON.parse(res.text));
      });
    };
})();

module.exports = Account;
module.exports = Purchase;
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


module.exports = app;
