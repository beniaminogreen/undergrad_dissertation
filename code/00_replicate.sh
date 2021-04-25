#!/bin/sh

# echo "Running Unit Tests" &&
#     python -m unittest &&
#     echo "testthat::test_dir("tests/testthat")" | R -q --vanilla ||
#     echo "Unit Tests Failed"

Rscript ./01_clean_sinclair_data.R &&  #python 02_webscrape.py &&
    Rscript ./03_clean_search_data.R &&
    Rscript ./04_clean_iat_data.R &&
    Rscript ./05_models.R
