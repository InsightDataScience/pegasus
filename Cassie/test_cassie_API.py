from cassie_utils import CassieUtilities
from datetime import datetime, timedelta
from pytz import timezone
import pytz
from time import time
import json

date_format = '%Y-%m-%d %H:%M:%S'
loc_tz = 'US/Pacific'

# initialize connection to Cassandra cluster
CUtil = CassieUtilities()



print "Example 1"
start_time = time()
# format start date to be 1 minute ago in utc time
minutes_back = 60*12
start_date_obj = datetime.now(tz=pytz.utc) - timedelta(minutes=minutes_back)
start_date_str = start_date_obj.strftime(date_format)

# fetch records from the last 1 minute in the fashion Cassandra table
rows = CUtil.fetch_daterange(start_date=start_date_str)

start_date_loctz = start_date_obj.astimezone(timezone(loc_tz))\
                                 .strftime(date_format)
print "There are {} records since {}".format(len(rows), start_date_loctz)
elapsed_time = time() - start_time
print "Query took {} seconds\n".format(elapsed_time)

print "First record:"
print json.dumps(json.loads(rows[0].record), indent=2)
print "------------------------------------------------------------------------"



print "Example 2"
start_time = time()
# format start date to be 2 hours ago
hours_back = 12
start_date_obj = datetime.now(tz=pytz.utc) - timedelta(hours=hours_back)
start_date_str = start_date_obj.strftime(date_format)

# format end date to be 5 minutes after start_date
minutes_window = 60
end_date_obj = start_date_obj + timedelta(minutes=minutes_window)
end_date_str = end_date_obj.strftime(date_format)

# fetch records in the 5 minute window starting 2 hours ago
rows = CUtil.fetch_daterange(start_date=start_date_str, end_date=end_date_str)

start_date_loctz = start_date_obj.astimezone(timezone(loc_tz))\
                                 .strftime(date_format)
end_date_loctz = end_date_obj.astimezone(timezone(loc_tz))\
                             .strftime(date_format)
print "There are {} records between {} and {}".format(len(rows), 
                                                      start_date_loctz, 
                                                      end_date_loctz)
elapsed_time = time() - start_time
print "Query took {} seconds\n".format(elapsed_time)

print "First record:"
print json.dumps(json.loads(rows[0].record), indent=2)
