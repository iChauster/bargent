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

<<<<<<< HEAD

=======
>>>>>>> d669d0cf8a18c93aa8038dcc1198b5e636781ae7
module.exports = app;
