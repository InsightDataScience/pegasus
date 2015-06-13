from flask import Flask, render_template, redirect, url_for, request, jsonify, json
from cassie_utils import CassieUtilities
import csv
import time
from datetime import datetime, timedelta
import time

app = Flask(__name__)

CUtils = CassieUtilities('52.26.108.225')

@app.route('/schema')
def show_schema():

    schema = {
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
    	     }
    
    return jsonify(schema)


@app.route('/last/<num>/<timeinc>/<fields>/')
def get_last_n_records(num, timeinc, fields):
    num = int(num)
    
    end_date = datetime.utcnow()

    offset = {	'seconds': timedelta(seconds=num),
		'minutes': timedelta(minutes=num),
		'hours': timedelta(hours=num),
		'days': timedelta(days=num),
		'weeks': timedelta(weeks=num)
	      }
    start_date = end_date - offset[timeinc]

    end_date = end_date.strftime('%Y-%m-%d %H:%M:%S')
    start_date = start_date.strftime('%Y-%m-%d %H:%M:%S')

    fields = fields.split('&')

    result = CUtils.fetch_daterange(start_date=start_date,
				    end_date=end_date,
				    table='fashion')

    if fields[0] == 'all':
        json_results = map(lambda a: json.loads(a.record), result)
    else:
 	json_results = map(lambda a: {k: json.loads(a.record).get(k, None) for k in fields}, result)

    return jsonify(result=json_results)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
