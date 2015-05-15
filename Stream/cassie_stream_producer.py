from cassandra.cluster import Cluster
import json
import uuid
import re
import random
import time
from datetime import datetime

cluster = Cluster(['52.24.158.196'])

session = cluster.connect()

session.execute(
    """
    CREATE KEYSPACE IF NOT EXISTS execed
    WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 2 }
    """
)

session.set_keyspace('execed')

session.execute(
    """
    CREATE TABLE IF NOT EXISTS fashion (date text, 
                                        t timestamp, 
                                        record text, 
                                        PRIMARY KEY(date, t))
    """
)

f = open('data/sorted_fashion.json','r')
data = f.readlines()

# compute deltas in record timestamp
tdeltas = None
max_tdelta = 20
for curr_data in data:
    record = json.loads(curr_data)
    if tdeltas is None:
        prev_ts = record["time"]
        tdeltas = []
    else:
        tdelta = (record["time"] - prev_ts)/1000.0 
        if tdelta < max_tdelta:
            tdeltas.append(tdelta)
        prev_ts = record["time"]

# playback records in order along and repeat when finished
count = 0
while True:
    curr_data = data[count % len(data)]
    record = json.loads(curr_data)

    td_user_last_action_time = record["user_last_action_time"]-record["time"]
    td_registration_time = record["registration_time"]-record["time"]

    ts_now = datetime.now()
    ts = long((ts_now-datetime.fromtimestamp(0)).total_seconds()*1000)
    print("%s %s" % (ts_now, "UTC"))
    new_time = ts
    new_user_last_action_time = ts + td_user_last_action_time
    new_registration_time = ts + td_registration_time

    curr_data = re.sub(r'\"time\":.*?,\"action"', '\"time\":{},\"action\"'.format(new_time), curr_data)
    curr_data = re.sub(r'\"registration_time\":.*?,\"category"', '\"registration_time\":{},\"category\"'.format(new_registration_time), curr_data)
    curr_data = re.sub(r'\"user_last_action_time\":.*?,\"user_birthdate"', '\"user_last_action_time\":{},\"user_birthdate\"'.format(new_user_last_action_time), curr_data)

    
    session.execute(
        """
        INSERT INTO fashion (date, t, record) 
        VALUES (%s, %s, %s) USING TTL 604800
        """,
        ("{:04d}-{:02d}-{:02d}".format(ts_now.year, ts_now.month, ts_now.day), new_time, curr_data[:-1])
    )

    time.sleep(tdeltas[count % len(tdeltas)])
    count += 1
