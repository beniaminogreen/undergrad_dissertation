#!/usr/bin/python
import unittest
import numpy as np
from scaling import compare, compare_horizontal, compare_vertical


class TestCompare(unittest.TestCase):
    def test_compare(self):
        h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])
        v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

        self.assertEqual(1 / 8, compare(h_matrix, v_matrix, 0, 0, 1, 2))
        self.assertEqual(1 / 9, compare(h_matrix, v_matrix, 0, 0, 2, 2))
        self.assertEqual(1 / 4, compare(h_matrix, v_matrix, 1, 0, 1, 2))


class TestCompareHorizontal(unittest.TestCase):
    def test_compare_horizontal(self):
        h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])

        self.assertEqual(1 / 3, compare_horizontal(h_matrix, 0, 0, 2))
        self.assertEqual(2 / 3, compare_horizontal(h_matrix, 1, 0, 2))
        self.assertEqual(5 / 4, compare_horizontal(h_matrix, 1, 1, 0))


class TestCompareVertical(unittest.TestCase):
    def test_compare_vertical(self):
        v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

        self.assertEqual(1 / 4, compare_vertical(v_matrix, 0, 0, 1))
        self.assertEqual(1 / 4, compare_vertical(v_matrix, 1, 0, 2))
        self.assertEqual(4, compare_vertical(v_matrix, 0, 1, 0))
