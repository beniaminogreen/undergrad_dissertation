#!/usr/bin/python
import numpy as np


def compare_horizontal(h_matrix, y, x0, x1):
    present = h_matrix[y, x0]
    next_val = h_matrix[y, x1]
    return present / next_val


def compare_vertical(v_matrix, x, y0, y1):
    present = v_matrix[y0, x]
    next_val = v_matrix[y1, x]
    return present / next_val


def compare(h_matrix, v_matrix, x0, y0, x1, y1):

    first = compare_horizontal(h_matrix, y0, x0, x1) * compare_vertical(
        v_matrix, x1, y0, y1)

    second = compare_vertical(v_matrix, x0, y0, y1) * compare_horizontal(
        h_matrix, y1, x0, x1)

    return ((first + second) / 2)


def score_point(h_matrix, v_matrix, x0, y0):
    assert h_matrix.shape == v_matrix.shape

    nrow, ncol = h_matrix.shape
    sum_score = 0

    for x1 in range(nrow):
        for y1 in range(ncol):
            sum_score += compare(h_matrix, v_matrix, x0, y0, x1, y1)

    return (sum_score)


h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])
v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

compare(h_matrix,v_matrix,0,0,1,2)
