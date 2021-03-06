var express = require('express');
var request = require('superagent');
var watson = require('watson-developer-cloud');
var alchemy_language = watson.alchemy_language({
  api_key: '42fd3e26c5147b2477e5cc4636ffb1687366ac70'
})
var app = express.Router();

/* GET home page. */
app.get('/', function(req, res) {
  res.render('index');
});

app.post('/getExpenseData', function (req,res){
	var array = req.body;
	var totalAmount = 0;
	var a = 0;
	var c = {};
	var loop = function(arr){
		var obj = arr[a];
		Merchant.getMerchant(obj.merchant, function (res){
 			var string = "";
 			var categories = res.category;
 			obj.merchantName = res.name;
 			for (i in categories){
 				string = string.concat(categories[i], ", ");
 			}
 			console.log(arr[a].description + "====================" + a);
 			getConcept(arr[a].description + ' ' + string, function(res){
 				if(res != ""){
	 				arr[a].category = JSON.parse(res).concepts[0].text;
	 				console.log(arr[a].category);
	 				a ++;
	 				if(a < arr.length){
	 					loop(arr)
	 				}else{
	 					end();
	 				}
 				}else{
 					arr[a].category = "Miscellaneous"
 					a ++;
 					if(a < arr.length){
 						loop(arr);
 					}else{
 						end();
 					}
 				}

			});
 		});
		if(!c[obj.merchant]){
			c[obj.merchant] = obj.amount;
		}else{
			c[obj.merchant] += obj.amount;
		} 
		totalAmount += obj.amount;
		
	}
		for (k in c) {
			if (k){
 				//console.log(k);
 			}
		}
		loop(array)
		var end = function(){
			console.log(end);
			array.sort(priceCompare)
			console.log(array.reverse());
			array = array.reverse();
			array.unshift({"total" : totalAmount})
			res.send(JSON.stringify(array.reverse()));
		}
});
function getConcept(textInContext, callback) {
	var parameters = {
  		text: textInContext
  	};

	alchemy_language.concepts(parameters, function (err, response) {
  		if (err){
    		console.log('error:', err);
    		callback("");
    	} else {
    		var a = JSON.stringify(response, null, 2);
    		console.log(a)
    		callback(a);
    	}
	});
}
function priceCompare(a,b){
	if(a.amount > b.amount){
		return 1;
	}else if(a.amount < b.amount){
		return -1;
	}else{
		return 0;
	}
}
	
	var apiKey = "d914174469cc843bb832513eda8b644b";
 var ob =  {
      "name": "Ithaca Bakery",
      "category": [
        "cafe",
        "bakery",
        "meal_takeaway",
        "restaurant",
        "food",
        "store",
        "point_of_interest",
        "establishment"
      ],
      "geocode": {
        "lat": 42.44261090000001,
        "lng": -76.5086618
      },
      "address": {
        "zip": "14850",
        "city": "Ithaca",
        "street number": "400",
        "state": "NY",
        "street name": "North Meadow Street"
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
