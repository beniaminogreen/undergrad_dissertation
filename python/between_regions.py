#!/usr/bin/env python
from pytrends.request import TrendReq
from utils import itr_split_overlap, censor_string
import re
import csv

pytrends = TrendReq(hl='en-US', tz=360)


def between_region(query, **kwargs):
    pytrends.build_payload(query, cat=0, **kwargs)
    df = pytrends.interest_by_region(resolution='DMA',
                                     inc_low_vol=True,
                                     inc_geo_code=True)
    df = df.set_index("geoCode")
    df.index.name = 'code'
    df = df.rename(censor_string, axis="columns")
    return (df)


def between_reigion_many(iterable, **kwargs):
    iterable = iter(iterable)
    chunk1 = next(iterable)
    df1 = between_region(chunk1, **kwargs)

    for chunk in iterable:
        chunk2 = chunk
        shared = censor_string(list(set(chunk1) & set(chunk2))[0])
        df2 = between_region(chunk2)

        mean1 = df1[shared].mean()
        mean2 = df2[shared].mean()
        normaliation_factor = mean1 / mean2

        df2 = df2 * normaliation_factor
        df2 = df2.drop(columns=[shared])

        df1 = df1.join(df2)

        chunk1 = chunk2

    return (df1)


def get_region_trend(query, region):
    geo_code = re.findall("[0-9]+", region)[0]

    pytrends.build_payload(kw_list=[query], geo=region, timeframe="all")
    df = pytrends.interest_over_time()

    if not df.empty:
        df.columns = ["n", "ispartial"]
        df['geocode'] = geo_code
        df['term'] = censor_string(query)
        df.index.name = 'date'
        df.reset_index(inplace=True)
        return df


if __name__ == "__main__":
    with open("keywords.csv") as csvfile:
        reader = csv.reader(csvfile)
        queries = [row[0] for row in reader]

    with open("hey.csv", "w") as f:
        df = between_reigion_many(itr_split_overlap(queries, 5, 1),
                                  timeframe="all",
                                  geo="US",
                                  gprop="")
        df.to_csv(f, header=True)
