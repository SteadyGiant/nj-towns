#!/usr/bin/env Rscript

# Get median household income.
source('code/mhi.R')

# Build racial diversity dataset.
# Establish "universe" for others.
source('code/diversity_race.R')

# Build economic diversity dataset.
source('code/diversity_econ.R')

# Build population density dataset.
source('code/density.R')

# Build "Best Towns" rankings dataset.
source('code/best_towns.R')

# Build reports.
source('code/render_reports.R')
