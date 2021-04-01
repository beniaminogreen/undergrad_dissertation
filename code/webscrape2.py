#!/usr/bin/env python
from scaling import recover_scores, repair_matrix
from in_region import in_region, to_wide
from between_regions import create_v_df
import pickle as pkl
import pandas as pd

with open("data/dma_abbreviations.pkl", "rb") as f:
    dmas = pkl.load(f)

# in_region_dfs = tuple(
#     in_region("nigger", dma, True, timeframe="all") for dma in dmas)
# wide_dfs = map(to_wide, in_region_dfs)
# h_df = pd.concat(wide_dfs).sort_index()
# h_df.to_parquet("h_df.parquet")

# dfs = tuple(create_v_df("nigger", year) for year in range(2004, 2021))
# v_df = pd.concat(dfs, axis=1).sort_index()
# v_df.to_parquet("v_df.parquet")

v_df = pd.read_parquet("v_df.parquet")
h_df = pd.read_parquet("h_df.parquet").drop("2021", axis=1)
v_matrix = v_df.to_numpy(copy=True)
h_matrix = h_df.to_numpy(copy=True)

gen1 = recover_scores(h_matrix, v_matrix)
final = repair_matrix(h_matrix, v_matrix, gen1)
final = pd.DataFrame(final)
final.columns = h_df.columns
final.index = h_df.index
final.to_csv("final.csv")

