var express = require('express');
var request = require('superagent');
var app = express.Router();

/* GET home page. */
app.get('/', function(req, res) {
  res.render('index');
});

app.post('/getExpenseData', function (req,res){
	var array = req.body;
	var totalAmount = 0;
	for (a in array){
		var obj = array[a]
		console.log(obj + "===========");
		console.log("\n amount : "+ obj.amount + "\n description : " + obj.description + "\n merchant : " + obj.merchant + "\n type : " + obj.type);
		// you need to request to find the merchant's name and category through the id
		if(!c[obj.merchant]){
			c[obj.merchant] = obj.amount;
		}else{
			c[obj.merchant] += obj.amount;
		} 
		totalAmount += obj.amount;
		for (k in c) {
			if (k)
 				Merchant.getMerchant(k,function(res){
 					console.log(res);
 				});
		}
	}
	array.sort(priceCompare)
	console.log(array.reverse());
	res.end('ok');
});
function priceCompare(a,b){
	if(a.amount > b.amount){
		return 1;
	}else if(a.amount < b.amount){
		return -1;
	}else{
		return 0;
	}
}

	console.log(c);
	console.log(array);
	console.log(totalAmount)
	
	
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
	


module.exports = app;
