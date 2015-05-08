var express = require('express');
var bodyParser = require('body-parser');
var cassandra = require('cassandra-driver');
var moment = require('moment-timezone');

var client = new cassandra.Client({contactPoints: ['52.24.158.196']});
client.connect(function(err, result) {console.log('Connected.');});

var app = express();
app.use(function(req, res, next) {
    bodyParser.json();
    res.setHeader('Access-Control-Allow-Origin', '*');
    next();
});
app.set('json spaces', 2);

app.get('/metadata', function(req, res) {
    res.send(client.hosts.slice(0).map(function (node) {
        return { address: node.address, rack: node.rack, datacenter: node.datacenter }
    }));
});

var server = app.listen(3000, function() {
    console.log('Listening on port %d', server.address().port);
});



var getRecordsSinceDate = 'SELECT t, record FROM execed.fashion WHERE token(date)>=token(?) AND t>? AND t<? ALLOW FILTERING;';

app.get('/since/:start/:country/:city', function(req, res) {

    // parse string input to Date object
    var inputDate = new Date(Date.parse(req.params.start))

    // get timezone offset from input parameters
    var tzone = req.params.country + '/' + req.params.city

    // execute query if timezone is valid
    if (moment.tz.zone(tzone) === null) {
	console.log("Invalid Time Zone!");
        res.send({
		  error: "Invalid Time Zone!", 
		  example: "Try http://52.24.158.196:3000/since/2015-05-08 11:12:00/America/Los_Angeles/"
		 });

    } else {
    	var tz_offset = moment().tz(tzone)._offset

    	// get start date in UTC time
    	var startDate = new Date(inputDate.getTime() - tz_offset*60*1000)

    	// get start day in UTC
    	var startDay = startDate.getUTCFullYear() + '-' +
        	                 String('00' + (startDate.getUTCMonth()+1)).slice(-2) + '-' +
                	         String('00' + startDate.getUTCDate()).slice(-2);

    	// get end date in UTC time
   	var endDate = new Date()

    	// get end day in UTC
    	var endDay = endDate.getUTCFullYear() + '-' +
        	             String('00' + (endDate.getUTCMonth()+1)).slice(-2) + '-' +
             		     String('00' + endDate.getUTCDate()).slice(-2);  

    	// query cassandra for all records since start date
	client.execute(getRecordsSinceDate, 
	   	       [startDay, startDate, endDate], 
		       {prepare: true}, 
		       function(err, result) {
  		           if (err) {
            		       res.status(404).send({ msg: 'Records not found.' });
        	           } else {
            		       res.json(result);
        	           }
    		       });
    } 
});

app.get('/between/:start/:end/:country/:city', function(req, res) {

    // parse string input to Date object
    var inputStartDate = new Date(Date.parse(req.params.start))
    var inputEndDate = new Date(Date.parse(req.params.end))

    // get timezone offset from input parameters
    var tzone = req.params.country + '/' + req.params.city

    // execute query if timezone is valid
    if (moment.tz.zone(tzone) === null) {
        console.log("Invalid Time Zone!");
        res.send({
                  error: "Invalid Time Zone!",
                  example: "Try http://52.24.158.196:3000/between/2015-05-08 13:00:00/2015-05-08 13:05:00/America/Los_Angeles/"
                 });

    } else {
        var tz_offset = moment().tz(tzone)._offset

        // get dates in UTC time
        var startDate = new Date(inputStartDate.getTime() - tz_offset*60*1000)
        var endDate = new Date(inputEndDate.getTime() - tz_offset*60*1000)

        // get days in UTC
        var startDay = startDate.getUTCFullYear() + '-' +
                                 String('00' + (startDate.getUTCMonth()+1)).slice(-2) + '-' +
                                 String('00' + startDate.getUTCDate()).slice(-2);

        var endDay = endDate.getUTCFullYear() + '-' +
                             String('00' + (endDate.getUTCMonth()+1)).slice(-2) + '-' +
                             String('00' + endDate.getUTCDate()).slice(-2);

        // query cassandra for all records between start and end date
        client.execute(getRecordsSinceDate,
                       [startDay, startDate, endDate],
                       {prepare: true},
                       function(err, result) {
                           if (err) {
                               res.status(404).send({ msg: 'Records not found.' });
                           } else {
                               res.json(result);
                           }
                       });
    }
});

app.get('/last/:num/:timeinc', function(req, res) {

    var num = parseInt(req.params.num);

    var toMilliMult = { weeks: 7*24*60*60*1000, 
                        days: 24*60*60*1000, 
                        hours: 60*60*1000, 
                        minutes: 60*1000, 
                        seconds: 1000}; 

    // get end date in UTC time
    var endDate = new Date();

    // get start date in UTC time
    var startDate = new Date(endDate.getTime() - num*toMilliMult[req.params.timeinc])

    // get days in UTC
    var startDay = startDate.getUTCFullYear() + '-' +
                             String('00' + (startDate.getUTCMonth()+1)).slice(-2) + '-' +
                             String('00' + startDate.getUTCDate()).slice(-2);

    var endDay = endDate.getUTCFullYear() + '-' +
                         String('00' + (endDate.getUTCMonth()+1)).slice(-2) + '-' +
                         String('00' + endDate.getUTCDate()).slice(-2);

    // query cassandra for all records since start date
    client.execute(getRecordsSinceDate,
                   [startDay, startDate, endDate],
                   {prepare: true},
                   function(err, result) {
                       if (err) {
                           res.status(404).send({ msg: 'Records not found.' });
                       } else {
                           res.json(result);
                       }
                   });
});

