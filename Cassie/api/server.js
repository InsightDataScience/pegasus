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

var server = app.listen(3000, function() {
    console.log('Listening on port %d', server.address().port);
});

function toUTCDayString(dateObj){
    var dayString = dateObj.getUTCFullYear() + '-' +
                    String('00' + (dateObj.getUTCMonth()+1)).slice(-2) + '-' +
                    String('00' + dateObj.getUTCDate()).slice(-2);
    return dayString
}

function fetch_daterange(startDate, endDate, fields, res) {
    var res_arr = []
    var tempDate = startDate

    // get days in UTC
    var startDay = toUTCDayString(startDate)
    var endDay = toUTCDayString(endDate)

    function autoPagedQuery() {
        if (startDay >= endDay){
            client.eachRow( getRecordsSinceDate, [startDay, startDate, endDate], {autoPage: true},
                            function(n, row) {
                                var json_record = JSON.parse(row.record)
                                json_record["ts"] = row.t
                                if (fields[0] == 'all'){
                                    res_arr.push(json_record)
                                } else {
                                    json_trunc_record = {}
                                    for (var i=0; i<fields.length; i++) {
                                        json_trunc_record[fields[i]] = json_record[fields[i]]
                                    }
                                    json_trunc_record["ts"] = row.t
                                    res_arr.push(json_trunc_record)
                                }
                            },
                            function(err, result) {
                                if (err) {
                                    res.status(404).send({ msg : 'Error!' });
                                } else {
                                    console.log("Fetched " + res_arr.length + " records")
                                    res.json(res_arr)
                                }
                            });
        } else {
            client.eachRow( getRecordsSinceDate, [startDay, startDate, endDate], {autoPage:true},
                            function(n, row) {
                                var json_record = JSON.parse(row.record)
                                json_record["ts"] = row.t
                                if (fields[0] == 'all'){
                                    res_arr.push(json_record)
                                } else {
                                    json_trunc_record = {}
                                    for (var i=0; i<fields.length; i++) {
                                        json_trunc_record[fields[i]] = json_record[fields[i]]
                                    }
                                    json_trunc_record["ts"] = row.t
                                    res_arr.push(json_trunc_record)
                                }
                            },
                            function(err, result) {
                                if (err) {
                                    res.status(404).send({ msg : 'Error!' });
                                } else {
                                    tempDate = new Date(tempDate.getTime() + 24*60*60*1000)
                                    startDay = toUTCDayString(tempDate)
                                    autoPagedQuery()
                                }
                            });
        }
    }

    autoPagedQuery()

}

var getRecordsSinceDate = 'SELECT t, record FROM execed.fashion WHERE date=? AND t>? AND t<? ALLOW FILTERING;';

process.on('uncaughtException', function (err) {
  console.error(err);
  console.log("Node NOT Exiting...");
});

app.get('/metadata', function(req, res) {
    res.send(client.hosts.slice(0).map(function (node) {
        return { address: node.address, rack: node.rack, datacenter: node.datacenter }
    }));
});

app.get('/fashion/schema', function(req, res) {
    res.send({
    "time": 1431194100235,
    "action": "hate",
    "registration_time": 1431193829286,
    "category": "underwear",
    "gender": "women",
    "from_recommended": "false",
    "subcategory": "bra",
    "product_id": "561760",
    "store": "Macy's",
    "product_likes": 0,
    "product_loves": 0,
    "product_hates": 4,
    "product_total": 4,
    "user_action_count": 5136,
    "user_age": 21,
    "user_last_action_time": 1434486024313,
    "user_birthdate": 733104000000,
    "user": "Candelaria Saffron",
    "user_gender": "women",
    "ts": "2015-05-09T17:55:00.235Z"
  });
});

app.get('/fashion/since/:start/:country/:city/:fields', function(req, res) {

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

    	// get start/end date in UTC time
    	var startDate = new Date(inputDate.getTime() - tz_offset*60*1000)
   	var endDate = new Date()

        var fields = req.params.fields.split('&')

        fetch_daterange(startDate, endDate, fields, res)
    } 
});

app.get('/fashion/between/:start/:end/:country/:city/:fields', function(req, res) {

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

        var fields = req.params.fields.split('&')
        
        fetch_daterange(startDate, endDate, fields, res)
    }
});

app.get('/fashion/last/:num/:timeinc/:fields', function(req, res) {

    var num = parseInt(req.params.num);

    var toMilliMult = { weeks: 7*24*60*60*1000,
                        days: 24*60*60*1000,
                        hours: 60*60*1000,
                        minutes: 60*1000,
                        seconds: 1000};

    // get dates in UTC time
    var endDate = new Date();
    var startDate = new Date(endDate.getTime() - num*toMilliMult[req.params.timeinc])

    var fields = req.params.fields.split('&')

    fetch_daterange(startDate, endDate, fields, res)
});


