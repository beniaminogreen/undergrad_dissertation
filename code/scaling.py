#!/usr/bin/python
import numpy as np
from utils import mean_nonzero
import random


def compare_horizontal(h_matrix, y, x0, x1):
    if h_matrix[y, x0] == 0 or h_matrix[y, x1] == 0:
        return (0)
    else:
        present = h_matrix[y, x0]
        next_val = h_matrix[y, x1]
        return present / next_val


def compare_vertical(v_matrix, x, y0, y1):
    if v_matrix[y0, x] == 0 or v_matrix[y1, x] == 0:
        return (0)
    else:
        present = v_matrix[y0, x]
        next_val = v_matrix[y1, x]
        return present / next_val


def compare(h_matrix, v_matrix, x0, y0, x1, y1):
    if h_matrix[y0, x0] == 0 or h_matrix[y1, x1] == 0:
        return (0)
    else:
        first = compare_horizontal(h_matrix, y0, x0, x1) * compare_vertical(
            v_matrix, x1, y0, y1)

        second = compare_vertical(v_matrix, x0, y0, y1) * compare_horizontal(
            h_matrix, y1, x0, x1)

        return mean_nonzero((first, second))


def score_point(h_matrix, v_matrix, x0, y0):
    ncol, nrow = h_matrix.shape
    scores = tuple(
        compare(h_matrix, v_matrix, x0, y0, x1, y1) for y1 in range(ncol)
        for x1 in range(nrow))
    return mean_nonzero(scores)


def recover_scores(h_matrix, v_matrix):
    assert h_matrix.shape == v_matrix.shape
    result = np.zeros(h_matrix.shape)

    for y in range(h_matrix.shape[0]):
        for x in range(h_matrix.shape[1]):
            result[y, x] = score_point(h_matrix, v_matrix, x, y)

    result *= 1 / result.max()

    return result


if __name__ == "__main__":
    h_matrix = np.array([[0, 4, 6], [12, 15, 18], [3.5, 4, 0]])
    v_matrix = np.array([[0, 1, 1], [12, 2.5, 2], [21, 4, 0]])

    print(recover_scores(h_matrix, v_matrix) * 8)
