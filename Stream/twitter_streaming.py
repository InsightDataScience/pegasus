#!/usr/bin/env python

# Import the necessary methods from tweepy library
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from finviz_tickers import get_largest_cap
from datetime import datetime
import os
import json
import boto
from boto.s3.key import Key

# Variables that contains the user credentials to access Twitter API
with open('.twitter') as twitter_file:
    twitter_cred = json.load(twitter_file)

access_token = twitter_cred["access_token"]
access_token_secret = twitter_cred["access_token_secret"]
consumer_key = twitter_cred["consumer_key"]
consumer_secret = twitter_cred["consumer_secret"]

# This is a basic listener that just prints received tweets to stdout.
class StdOutListener(StreamListener):

    def __init__(self, file_prefix, bucket, block_size):
        self.file_prefix = file_prefix
        self.filename = '{}-{}'.format(self.file_prefix, datetime.utcnow().strftime("%Y-%m-%d-%I-%M-%S-%f"))
        self.bucket_key = Key(boto.connect_s3().get_bucket(bucket))
        self.block_size = block_size

    def on_data(self, data):
        print data
        if os.path.isfile('temp_file'):
            if os.path.getsize('temp_file') < self.block_size:
                with open('temp_file', 'ab') as myfile:
                    print "writing to {}".format(self.filename)
                    myfile.write(data)
            else:
                print "transferring {} to S3".format(self.filename)
                self.bucket_key.key = self.filename
                self.bucket_key.set_contents_from_filename('temp_file')
                self.filename = '{}-{}'.format(self.file_prefix, 
					       datetime.utcnow().strftime("%Y-%m-%d-%I-%M-%S-%f"))
                os.remove('temp_file')
                with open('temp_file', 'ab') as myfile:
                    myfile.write(data)
        else:
            with open('temp_file', 'ab') as myfile:
                myfile.write(data)

        return True

    def on_error(self, status):
        print status

if __name__ == "__main__":

    " This handles Twitter authentication and the connection to Twitter Streaming API"
    l = StdOutListener(file_prefix='market-cap-twitter',
                       bucket='insight-market-cap-twitter',
                       block_size=1024*1024)
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    stream = Stream(auth, l)

    tickers = get_largest_cap()[:400]

    # This line filter Twitter Streams to capture data by the keywords
    while True:
        try:
            stream.filter(track=tickers)
        except:
            stream.filter(track=tickers)
        else:
            break

