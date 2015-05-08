from cassandra.cluster import Cluster
from datetime import datetime, timedelta

class CassieUtilities(object):

    def __init__(self, ip_addr='52.24.158.196', keyspace='execed'):
        cluster = Cluster([ip_addr])
        self.session = cluster.connect()
        self.session.set_keyspace(keyspace)

    def fetch_daterange(self, start_date, end_date=None, table='fashion'):
        """Fetches json records Cassandra table by date range

        Retrieves json records that within a specified date range in UTC time 
        zone. Dates must be specified in a specific format.

        Args:
            start_date: Date in string format (%Y-%m-%d %H:%M:%S) 
                e.g. 2015-05-05 20:43:25
            end_date: Date in string format (%Y-%m-%d %H:%M:%S) 
                e.g. 2015-05-05 20:43:25.
                If no end date is specified, the current date time is used.
            table: Cassandra table name in the keyspace specified when 
                initializing.
                Default to 'fashion' table under the execed keyspace

        Returns:
            A list of the records in the specified Cassandra table. This 
            includes the Primary Key for each record. The last field represents
            the actual json record.

        Example:
            # finds all records since May 5, 2015 8:43:25PM UTC
            CassieUtilities.fetch_daterange('fashion', '2015-05-05 20:43:25')

            # finds all record between April 30, 2015 12:00:00AM to May 5, 2015 
            12:00:00AM UTC 
            CassieUtilities.fetch_daterange('fashion', '2015-04-30 00:00:00', 
                                            '2015-05 00:00:00')
        """

        if end_date is None:
            end_date = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

        end_date_obj = datetime.strptime(end_date, '%Y-%m-%d %H:%M:%S')
        end_day = '{:04d}-{:02d}-{:02d}'.format(end_date_obj.year, 
                                                end_date_obj.month, 
                                                end_date_obj.day)

        start_date_obj = datetime.strptime(start_date, '%Y-%m-%d %H:%M:%S')
        curr_day = '{:04d}-{:02d}-{:02d}'.format(start_date_obj.year, 
                                                 start_date_obj.month, 
                                                 start_date_obj.day)
      
        record_lookup_stmt = "SELECT * FROM {} WHERE date=%s AND t>%s and t<%s".format(table)
        
        record_list = []
        while curr_day <= end_day:  
            record_list += self.session.execute(record_lookup_stmt, [curr_day, 
                                                                     start_date,
                                                                     end_date])
            start_date_obj += timedelta(days=1)
            curr_day = '{:04d}-{:02d}-{:02d}'.format(start_date_obj.year, 
                                                     start_date_obj.month, 
                                                     start_date_obj.day) 

        return record_list
         
