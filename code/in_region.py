#!/usr/bin/python
from pytrends.request import TrendReq
from utils import censor_string
import time
import pandas as pd
import re
import pickle as pkl


def in_region(query, region, censor, **kwargs):
    """ Returns a set of data showing the popularity of a search term over time

    :query: The search term that time-series data is collected for
    :region: The geographic region to retrieve time-series data for.
    :censor: boolean should the search terms be censored?
    :**kwargs: kwargs to be passed to pytrends.build_payload()
    :returns: DataFrame giving time-series data for the popularity of a
        search term in a given region

    """
    pytrends = TrendReq(hl='en-US', tz=360)
    try:
        pytrends.build_payload(kw_list=[query], geo=region, **kwargs)
        df = pytrends.interest_over_time()
    except:
        if censor:
            print(f"Rate error: {censor_string(query)} in {region}")
        else:
            print(f"Rate error: {query} in {region}")

        time.sleep(60)
        return in_region(query, region, censor, **kwargs)

    if df.empty:

        df = pd.DataFrame()
        df['date'] = pd.period_range(start='2004-01-01',
                                     end='2021-01-01',
                                     freq='M').to_timestamp()
        df['n'] = 0
        df['ispartial'] = pd.Series([True]).bool()

    else:

        df.columns = ["n", "ispartial"]
        df.index.name = 'date'
        df.reset_index(inplace=True)

    df["query"] = query

    code = re.findall("\d+", region)
    if code:
        df['code'] = code[0]
    else:
        code = region

    if censor:
        df["query"] = df["query"].apply(censor_string)

    return df


def to_wide(df):
    """Turns time-series search popularity data into a 'wide' dataframe to be used in scaling

    :df: 'long' dataframe of search data, as from in_region()
    :returns: 'wide' DataFrame of search data, averaged by year

    """
    print(df['date'])
    df['year'] = pd.DatetimeIndex(df['date']).year
    df['year'] = df['year'].apply(str)
    df = df.groupby(['year', 'code'])["n"].mean()
    df = df.unstack(level=0)
    return (df)
