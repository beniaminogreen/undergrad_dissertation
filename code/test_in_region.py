import unittest
import pandas as pd
from in_region import in_region
from utils import connected


@unittest.skipIf(not connected(), "not connected to the internet")
class TestBetweenRegion(unittest.TestCase):
    def test_in_region_uncensored(self):

        result_1 = in_region("hello",
                             "US_AL_630",
                             censor=False,
                             timeframe="2016-12-14 2017-01-25")

        result_2 = in_region("France",
                             "US_GA_522",
                             censor=False,
                             timeframe="2016-12-14 2017-01-25")

        expected_1 = pd.read_parquet("tests/test_data/in_region_1_uc.parquet")
        expected_2 = pd.read_parquet("tests/test_data/in_region_2_uc.parquet")

        self.assertTrue(expected_1.equals(result_1))
        self.assertTrue(expected_2.equals(result_2))

    def test_in_region_censored(self):
        result_1 = in_region(["socks"],
                             censor=True,
                             timeframe="2016-12-14 2017-01-25",
                             geo="US",
                             gprop="")

        result_2 = in_region(["socks", "shoe", "fish"],
                             censor=True,
                             timeframe="2016-12-14 2017-01-25",
                             geo="US",
                             gprop="")

        expected_1 = pd.read_parquet("tests/test_data/in_region_1_c.parquet")
        expected_2 = pd.read_parquet("tests/test_data/in_region_2_c.parquet")

        self.assertTrue(expected_1.equals(result_1))
        self.assertTrue(expected_2.equals(result_2))
