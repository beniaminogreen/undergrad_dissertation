#!/usr/bin/python
import re
import csv
import pandas as pd
import time
import tqdm
from pytrends.request import TrendReq

pytrends = TrendReq(hl='en-US', tz=360)
with open("keywords.csv") as csvfile:
    reader = csv.reader(csvfile)
    queries = [row[0] for row in reader]

abbreviations = [
    "US-AL-630", "US-GA-522", "US-AL-606", "US-AL-691", "US-MS-711",
    "US-FL-686", "US-AL-698", "US-AK-743", "US-AK-745", "US-AK-747",
    "US-AZ-753", "US-AZ-789", "US-CA-771", "US-AR-670", "US-AR-734",
    "US-AR-693", "US-TN-640", "US-AR-628", "US-LA-612", "US-MO-619",
    "US-CA-800", "US-CA-868", "US-CA-802", "US-CA-866", "US-CA-803",
    "US-OR-813", "US-CA-828", "US-CA-804", "US-NV-811", "US-CA-862",
    "US-CA-825", "US-CA-807", "US-CA-855", "US-CO-752", "US-CO-751",
    "US-CO-773", "US-CT-533", "US-PA-504", "US-MD-576", "US-FL-571",
    "US-FL-592", "US-FL-561", "US-FL-528", "US-FL-534", "US-FL-656",
    "US-GA-530", "US-FL-539", "US-FL-548", "US-GA-525", "US-GA-524",
    "US-GA-520", "US-TN-575", "US-GA-503", "US-GA-507", "US-HI-744",
    "US-ID-757", "US-ID-758", "US-WA-881", "US-ID-760", "US-IL-648",
    "US-IL-602", "US-IL-682", "US-IN-649", "US-IL-632", "US-IL-675",
    "US-IA-717", "US-IL-610", "US-MO-609", "US-IN-581", "US-OH-515",
    "US-IN-509", "US-IN-527", "US-IN-582", "US-KY-529", "US-IN-588",
    "US-IA-637", "US-IA-679", "US-NE-652", "US-MO-631", "US-MN-611",
    "US-IA-624", "US-KS-603", "US-MO-616", "US-MO-638", "US-KS-605",
    "US-KS-678", "US-KY-736", "US-WV-564", "US-TN-557", "US-KY-541",
    "US-TN-659", "US-VA-531", "US-LA-644", "US-LA-716", "US-LA-642",
    "US-LA-643", "US-LA-622", "US-ME-537", "US-ME-500", "US-ME-552",
    "US-MD-512", "US-MD-511", "US-NH-506", "US-MA-521", "US-MA-543",
    "US-MI-583", "US-MI-505", "US-MI-513", "US-MI-563", "US-MI-551",
    "US-MI-553", "US-OH-547", "US-MI-540", "US-WI-676", "US-ND-724",
    "US-WI-702", "US-MN-737", "US-MN-613", "US-MS-746", "US-MS-673",
    "US-MS-647", "US-MS-710", "US-MS-718", "US-MO-604", "US-MT-756",
    "US-MT-754", "US-MT-798", "US-MT-755", "US-MT-766", "US-ND-687",
    "US-MT-762", "US-NE-759", "US-NE-722", "US-NE-740", "US-SD-725",
    "US-NV-839", "US-UT-770", "US-NY-523", "US-NY-501", "US-NM-790",
    "US-TX-634", "US-TX-765", "US-NY-532", "US-NY-502", "US-NY-514",
    "US-NY-565", "US-NY-538", "US-NY-555", "US-NY-526", "US-NY-549",
    "US-NC-517", "US-SC-570", "US-NC-518", "US-NC-545", "US-SC-567",
    "US-VA-544", "US-NC-560", "US-NC-550", "US-OH-510", "US-OH-535",
    "US-OH-542", "US-OH-558", "US-WV-597", "US-OH-554", "US-OH-536",
    "US-OH-596", "US-OK-650", "US-OK-657", "US-OK-671", "US-OK-627",
    "US-OR-821", "US-OR-801", "US-OR-820", "US-WA-810", "US-PA-516",
    "US-PA-566", "US-PA-574", "US-PA-508", "US-PA-577", "US-SC-519",
    "US-SC-546", "US-SD-764", "US-TN-639", "US-TX-662", "US-TX-635",
    "US-TX-692", "US-TX-600", "US-TX-623", "US-TX-636", "US-TX-618",
    "US-TX-749", "US-TX-651", "US-TX-633", "US-TX-661", "US-TX-641",
    "US-TX-709", "US-TX-626", "US-TX-625", "US-WV-559", "US-VA-584",
    "US-VA-569", "US-VA-556", "US-VA-573", "US-WA-819", "US-WV-598",
    "US-WI-658", "US-WI-669", "US-WI-617", "US-WI-705", "US-WY-767",
    "US-WV-511"
]

df = pd.DataFrame(columns=["date", "n", "ispartial", "query", "state"])


def get_state_trend(query, state):
    try:
        pytrends.build_payload(kw_list=[query],
                               geo=f"{state}",
                               timeframe="all")
        df = pytrends.interest_over_time()
        if not df.empty:
            df.columns = ["n", "ispartial"]
            df.index.name = 'date'
            df.reset_index(inplace=True)
            df["query"] = query
            df["state"] = state
            return df
    except:
        print(f"Rate error: {query} in {state}")
        time.sleep(60)
        get_state_trend(query, state)


def between_region(query):
    pytrends.build_payload([query], cat=0, timeframe='all', geo='US', gprop='')
    df = pytrends.interest_by_region(resolution='DMA',
                                     inc_low_vol=True,
                                     inc_geo_code=True)
    df.index.name = 'geoname'
    df.reset_index(inplace=True)
    df = df.assign(
        state=df['geoname'].map(lambda x: re.findall("[A-Z]*$", x)[0]))
    df = df.assign(code="US-" + df["state"] + "-" + df["geoCode"])
    df = df.sort_values(by=['code'])
    return (df)


if __name__ == "__main__":
    with open("searches.csv", "w") as f:
        f.write("row,date,score,ispartial,term,code\n")
        for query in tqdm.tqdm(queries):
            for state in abbreviations:
                df = get_state_trend(query, state)
                if df is not None:
                    df.to_csv(f, header=False)
