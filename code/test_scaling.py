#!/usr/bin/python
import unittest
import numpy as np
import random
from scaling import compare, compare_horizontal, compare_vertical
from scaling import recover_scores, repair_matrix


class TestCompareHorizontal(unittest.TestCase):
    def test_compare_horizontal(self):
        h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])
        v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

        self.assertEqual(1 / 3, compare_horizontal(h_matrix, v_matrix, 0, 0, 2))
        self.assertEqual(2 / 3, compare_horizontal(h_matrix, v_matrix, 1, 0, 2))
        self.assertEqual(5 / 4, compare_horizontal(h_matrix, v_matrix, 1, 1, 0))


class TestCompareVertical(unittest.TestCase):
    def test_compare_vertical(self):
        h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])
        v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

        self.assertEqual(1 / 4, compare_vertical(h_matrix, v_matrix, 0, 0, 1))
        self.assertEqual(1 / 4, compare_vertical(h_matrix, v_matrix, 1, 0, 2))
        self.assertEqual(4, compare_vertical(h_matrix, v_matrix, 0, 1, 0))


class TestCompare(unittest.TestCase):
    def test_compare(self):
        h_matrix = np.array([[2, 4, 6], [12, 15, 18], [3.5, 4, 4.5]])
        v_matrix = np.array([[3, 1, 1], [12, 2.5, 2], [21, 4, 3]])

        self.assertEqual(1 / 8, compare(h_matrix, v_matrix, 0, 0, 1, 2))
        self.assertEqual(1 / 9, compare(h_matrix, v_matrix, 0, 0, 2, 2))
        self.assertEqual(1 / 4, compare(h_matrix, v_matrix, 1, 0, 1, 2))


class TestRecoverScores(unittest.TestCase):
    def test_recover_scores(self):
        for _ in range(100):
            arr = np.array([[x + 8 * y for x in range(8)] for y in range(8)])

            rowmod = np.array(tuple(random.random() for _ in range(8)))
            colmod = np.array(tuple(random.random() for _ in range(8)))

            h_matrix = arr * rowmod[:, np.newaxis]
            v_matrix = arr * colmod

            self.assertTrue(
                np.allclose(arr,
                            recover_scores(h_matrix, v_matrix) * 63))


class TestRepairScores(unittest.TestCase):
    def test_repair_scores(self):
        for _ in range(100):
            arr = np.array([[x + 10 * y for x in range(10)]
                            for y in range(10)])

            n = 15
            index = np.random.choice(arr.size, n, replace=False)
            arr.ravel()[index] = 0

            rowmod = np.array(tuple(random.random() for _ in range(10)))
            colmod = np.array(tuple(random.random() for _ in range(10)))

            h_matrix = arr * rowmod[:, np.newaxis]
            v_matrix = arr * colmod

            gen1 = recover_scores(h_matrix, v_matrix)
            if not gen1 is None:

                repaired = repair_matrix(h_matrix, v_matrix, gen1)

                repaired_scaled = repaired / np.max(repaired)
                arr_scaled = arr / np.max(arr)

                self.assertTrue(np.allclose(repaired_scaled, arr_scaled))
