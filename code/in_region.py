#!/usr/bin/python
from pytrends.request import TrendReq
from utils import censor_string
import csv
import pandas as pd
import pickle as pkl
import time
import tqdm

with open("keywords.csv") as csvfile:
    reader = csv.reader(csvfile)
    queries = [row[0] for row in reader]

abbreviations = pkl.load(open("dma_abbreviations.pkl", "rb"))

df = pd.DataFrame(columns=["date", "n", "ispartial", "query", "state"])


def get_state_trend(query, state):
    pytrends = TrendReq(hl='en-US', tz=360)
    try:
        pytrends.build_payload(kw_list=[query],
                               geo=f"{state}",
                               timeframe="all")
        df = pytrends.interest_over_time()
        if not df.empty:
            df.columns = ["n", "ispartial"]
            df.index.name = 'date'
            df.reset_index(inplace=True)
            df["query"] = censor_string(query)
            df["state"] = state
            return df
    except:
        print(f"Rate error: {query} in {state}")
        time.sleep(60)
        get_state_trend(query, state)


if __name__ == "__main__":
    with open("../../data/searches.csv", "w") as f:
        f.write("row,date,score,ispartial,term,code\n")
        for query in tqdm.tqdm(queries):
            for state in abbreviations:
                df = get_state_trend(query, state)
                if df is not None:
                    df.to_csv(f, header=False)
