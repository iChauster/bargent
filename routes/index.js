var express = require('express');
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
		totalAmount += obj.amount;
	}
	res.end('ok');
});

module.exports = app;
