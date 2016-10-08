var express = require('express');
var app = express.Router();

/* GET home page. */
app.get('/', function(req, res) {
  res.render('index');
});

app.post('/getExpenseData', function (req,res){
	console.log(req.body);
	res.end('ok');
});

module.exports = app;
