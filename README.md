# FX Correlations

An R script to compute log‐return correlations and plot heatmaps for M1 Forex data.
By default, calculations include four major currency pairs (by trading volume), but you can integrate other instruments.

## Features

- Ingests CSV files with columns `date`, `time`, `close`  
- Resamples tick data to 1-minute, 5-minute, 15-minute, hourly, etc.  
- Calculates log-returns and Pearson correlation matrix  
- Produces three distinct heatmaps:  
  1. Upper-triangle color plot  
  2. Lower-triangle clustered ellipse  
  3. `ggcorrplot` view with labels  

## Requirements

- R >= 4.0  
- CRAN packages:
  ```r
  install.packages(c("data.table", "xts", "corrplot", "remotes"))
  remotes::install_github("kassambara/ggcorrplot")


## Installation

1. Clone the repository:  
   ```bash
   git clone https://github.com/Amirparsa-0/fx-correlations.git
   cd fx-correlations

   
## Directory Structure

fx-correlations/
├── .gitignore      # ignores data/, results/, R artifacts
├── correlation.R   # main script
├── README.md       
├── data/
│   └── M1/         # drop your raw M1 CSVs here
├── results/        # outputs correlation CSVs
└── run.R           # optional wrapper

## Usage

1. Place your raw CSV files (e.g. EURUSD.csv, GBPUSD.csv) into data/M1/. 
2. Edit `data_dir`, `resample_k`, and `resample_on` at the top of `correlation.R`.  
3. Run `source("correlation.R")` in RStudio or `Rscript correlation.R` in terminal.  
4. Inspect the CSV output in `results/` and view the plots.

Feedbacks, ideas, and pull-requests are very welcome! Feel free to open an issue or submit a PR with your suggestions.
