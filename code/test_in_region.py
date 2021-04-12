#!/usr/bin/python
import unittest
import pandas as pd
import warnings
from in_region import in_region
from utils import connected


@unittest.skipIf(not connected(), "not connected to the internet")
class TestBetweenRegion(unittest.TestCase):
    def setUp(self):
        warnings.simplefilter('ignore')

    def test_in_region_uncensored(self):

        result_1 = in_region("hello",
                             "US-AL-630",
                             False,
                             timeframe="2016-12-14 2017-01-25")

        result_2 = in_region("France",
                             "US-GA-522",
                             False,
                             timeframe="2016-12-14 2017-01-25")

        expected_1 = pd.read_parquet("tests/test_data/in_region_1_uc.parquet")
        expected_2 = pd.read_parquet("tests/test_data/in_region_2_uc.parquet")

        self.assertTrue(expected_1.equals(result_1))
        self.assertTrue(expected_2.equals(result_2))

    def test_in_region_censored(self):
        result_1 = in_region("socks",
                             "US",
                             True,
                             timeframe="2016-12-14 2017-01-25",
                             gprop="")

        expected_1 = pd.read_parquet("tests/test_data/in_region_1_c.parquet")

        self.assertTrue(expected_1.equals(result_1))

