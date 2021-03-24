import glob
import os
import pickle as pkl
from between_regions import between_reigion_many
from in_region import get_region_trend


def extract_keywords(filename):
    with open(filename, "r") as f:
        keywords = f.read().splitlines()
    return keywords


def get_basename(filename):
    name_w_ext = os.path.basename(filename)
    basename = os.path.splitext(name_w_ext)[0]
    return (basename)


def run_keywords(name, keywords):
    regions = pkl.load(open("dma_abbreviations.pkl", "rb"))
    with open(f"../data/google_trends_data/{name}_time_serires.csv", "w") as f:
        f.write("row,date,score,ispartial,term,code\n")
        for keyword in keywords:
            for region in regions:
                df = get_region_trend(keyword, region, True)

                if df is not None:
                    df.to_csv(f, header=False)



if __name__ == "__main__":
    keyword_files = sorted(glob.glob("keywords/*.csv"))
    base_names = [get_basename(filename) for filename in keyword_files]
    keywords = [extract_keywords(filename) for filename in keyword_files]
    first = (list(zip(base_names, keywords)))[0]
    print(first)
    run_keywords(first[0], first[1])
