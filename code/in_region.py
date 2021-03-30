#!/usr/bin/python
from pytrends.request import TrendReq
from utils import censor_string
import time


def in_region(query, region, censor, **kwargs):
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
