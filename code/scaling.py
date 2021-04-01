#!/usr/bin/env python
import numpy as np
from utils import mean_nonzero
import random
import pandas as pd


# Find the ratio of two scores that are horizontally comparable
def compare_horizontal(h_matrix, v_matrix, y, x0, x1):
    if h_matrix[y, x0] == 0 or h_matrix[y, x1] == 0:
        return None
    elif v_matrix[y, x0] == 0 or v_matrix[y, x1] == 0:
        return None
    else:
        present = h_matrix[y, x0]
        next_val = h_matrix[y, x1]
        return present / next_val


# Find the ratio of two scores that are vertically comparable
def compare_vertical(hmatrix, v_matrix, x, y0, y1):
    if v_matrix[y0, x] == 0 or v_matrix[y1, x] == 0:
        return None
    elif v_matrix[y0, x] == 0 or v_matrix[y1, x] == 0:
        return None
    else:
        present = v_matrix[y0, x]
        next_val = v_matrix[y1, x]
        return present / next_val


# Find the ratio of two scores, if possible, using a horizontally comparable
# and vertically comparable array
def compare(h_matrix, v_matrix, x0, y0, x1, y1):
    if h_matrix[y0, x0] == 0 or h_matrix[y1, x1] == 0:
        return (0)
    elif v_matrix[y0, x0] == 0 or v_matrix[y1, x1] == 0:
        return (0)
    else:
        h_compare_1 = compare_horizontal(h_matrix, v_matrix, y0, x0, x1)
        v_compare_1 = compare_vertical(h_matrix, v_matrix, x1, y0, y1)

        if h_compare_1 and v_compare_1:
            first = h_compare_1 * v_compare_1
        else:
            first = None

        h_compare_2 = compare_vertical(h_matrix, v_matrix, x0, y0, y1)
        v_compare_2 = compare_horizontal(h_matrix, v_matrix, y1, x0, x1)
        if h_compare_2 and v_compare_2:
            second = h_compare_2 * v_compare_2
        else:
            second = None

        if first and second:
            return (first + second) / 2
        elif first:
            return first
        elif second:
            return second
        else:
            return None


# Find a standardized score for an individual cell given a using the ratio of
# the score to other cells, given a horizontally comparable and vertically
# comparable array
def score_point(h_matrix, v_matrix, x0, y0):
    ncol, nrow = h_matrix.shape

    if h_matrix[y0, x0] == 0 or v_matrix[y0, x0] == 0:
        return (0)
    else:
        scores = tuple(
            compare(h_matrix, v_matrix, x0, y0, x1, y1) for y1 in range(ncol)
            for x1 in range(nrow))
        return mean_nonzero(scores)


# Find the standardized scores across an entire array, using the ratio of each
# score to each other score
def recover_scores(h_matrix, v_matrix):
    assert h_matrix.shape == v_matrix.shape
    result = np.zeros(h_matrix.shape)

    for y in range(h_matrix.shape[0]):
        for x in range(h_matrix.shape[1]):
            result[y, x] = score_point(h_matrix, v_matrix, x, y)

    if np.nanmax(result) == 0:
        return None
    else:
        result *= 1 / np.nanmax(result)
        return result


# From a matrix of correctly imputed values and a matrix of horziontally and
# vertically comparable values, repair values that could not be imputed in the
# first stage because zero values had 'cast a shadow' on on them.
def repair_matrix(h_matrix, v_matrix, current):
    for i in range(50):
        current_sum = np.sum(current)
        current_has_nan = np.isnan(current_sum)

        if current_has_nan:
            NAs = np.argwhere(np.isnan(current))

            not_NA = np.invert(np.isnan(current))
            not_zero = current != 0
            not_na_zero = np.logical_and(not_NA, not_zero)
            not_na_zero_idx = np.argwhere(not_na_zero)

            for NA_y, NA_x in NAs:
                scores = tuple(current[y, x] *
                               compare(h_matrix, v_matrix, NA_x, NA_y, x, y)
                               for y, x in not_na_zero_idx)
                score = mean_nonzero(scores)

                current[NA_y, NA_x] = score
        else:
            break

    return current


if __name__ == "__main__":
    v_df = pd.read_parquet("v_matrix.parquet").sort_index().drop_duplicates()
    v_matrix = v_df.to_numpy()
    h_df = pd.read_parquet("horizontal.parquet").sort_index().drop_duplicates()
    h_df = h_df.drop("2021", axis=1)

    v_matrix = v_df.to_numpy()
    h_matrix = h_df.to_numpy()

    recovered = recover_scores(h_matrix, v_matrix)
    print(repair_matrix(h_matrix, v_matrix, recovered))
