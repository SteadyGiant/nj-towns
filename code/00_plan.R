#!/usr/bin/env Rscript

library(here)

# Load packages.
source(here::here('code/01_packages.R'))

# Build racial diversity dataset.
# Establish "universe" for others.
source(here::here('code/diversity_race.R'))

# Build economic diversity dataset.
source(here::here('code/diversity_econ.R'))

# Build population density dataset.
source(here::here('code/population.R'))

# Build "Best Towns" rankings dataset.
source(here::here('code/best_towns.R'))

# Build reports.
source(here::here('code/render_reports.R'))
