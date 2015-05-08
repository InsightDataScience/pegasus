import requests 
from bs4 import BeautifulSoup 
 
TICKERS_PER_PAGE = 20 
 
def get_largest_cap(): 
    tickers = [] 
 
    prev_tickers = None 
 
    ticker_num = 1 
    page_num = 1 
    while 1: 
        r = requests.get('http://finviz.com/screener.ashx?v=112&f=cap_large&o=-marketcap&r=' + str(ticker_num)) 
        soup = BeautifulSoup(r.text) 
 
        curr_tickers = [] 
        dummy_ticker = True 
        for line in soup.find_all('td'): 
            ticker = line.find('a') 
            if ticker is not None: 
                if 'quote' in ticker.get('href'): 
                    if not dummy_ticker: 
                        curr_tickers.append('$'+str(ticker.text)) 
                    else: 
                        dummy_ticker = False 

	print curr_tickers, prev_tickers
        if len(curr_tickers)==0 or (prev_tickers is not None and curr_tickers[-1] == prev_tickers[-1]): 
            break 
 
        print "Scraped Page Number: {}".format(page_num) 
        tickers += curr_tickers 
        ticker_num += TICKERS_PER_PAGE 
        page_num += 1 
        prev_tickers = curr_tickers 
 
    return tickers 
 
if __name__ == "__main__": 
     
    tickers = get_largest_cap() 
    print tickers
