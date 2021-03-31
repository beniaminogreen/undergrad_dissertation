#!/usr/bin/python
from pytrends.request import TrendReq
from utils import censor_string
import time
import pandas as pd


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
        pytrends.build_payload(kw_list=[query], geo=f"{region}", **kwargs)
        df = pytrends.interest_over_time()
        if not df.empty:
            df.columns = ["n", "ispartial"]
            df.index.name = 'date'
            df.reset_index(inplace=True)
            df["region"] = region

            df["query"] = query

            if censor:
                df["query"] = df["query"].apply(censor_string)

            return df
    except:
        if censor:
            print(f"Rate error: {censor_string(query)} in {region}")
        else:
            print(f"Rate error: {query} in {region}")

        time.sleep(60)
        in_region(query, region, censor)


def to_wide(df):
    """TODO: Turns time-series search popularity data into a 'wide' dataframe to be used in scaling

    :df: 'long' dataframe of search data, as from in_region()
    :returns: 'wide' DataFrame of search data, averaged by year

    """
    df['year'] = pd.DatetimeIndex(df['date']).year
    df = df.groupby(['year', 'region']).mean().unstack(level=0)
    return (df)


if __name__ == "__main__":
    dfs = tuple(pd.read_parquet("in_region.parquet") for _ in range(10))
    wide_dfs = map(to_wide, dfs)
    h_matrix = pd.concat(wide_dfs).to_numpy()
    print(h_matrix)
