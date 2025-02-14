# Underwater acoustic indices and ocean biodiversity

![fish-hydrophone-image](assets/widefish.png)

This project was done in collaboration with 
[Ocean Science Analytics](https://www.oceanscienceanalytics.com/). For more 
information, please check 
[this post](https://waveformanalytics.com/soundscapes/) on Waveform Analytics' 
website. 

## Summary of code

This repository contains the code used to prepare the data and to build the 
dashboard. The data preparation was done using Python, and the dashboard 
was build using R Shiny. 

## Additional links

[Interactive data dashboard](https://ocean-science-analytics.shinyapps.io/biosound-mbon/)

[Documentation site](https://ocean-science-analytics.github.io/biosound-exploratory-project/overview.html)


## Data overview
This project utilizes a comprehensive dataset that includes fish annotations, acoustic indices, and environmental data. The data is stored in a DuckDB database and CSV files, and is linked through an R Shiny dashboard for analysis and visualization.

### Data Sources:
1. **DuckDB Database**: 
   - The main data source is a DuckDB database (`mbon11.duckdb`) containing several tables related to fish annotations, acoustic indices, and seascaper data.
   
2. **CSV Files**:
   - Additional data is sourced from CSV files, including:
     - **Index Categories**: Updated index categories for analysis (`Updated_Index_Categories_v2.csv`).
     - **Site Information**: Information about different sites where data was collected (`BioSound_Datasets.csv`).

### Data Types:
1. **Fish Annotations**:
   - Data related to fish presence and annotations from different locations (e.g., Key West, May River).
   - Tables: `t_fish_keywest`, `t_fish_mayriver`.

2. **Acoustic Indices**:
   - Acoustic indices data that includes various metrics related to sound recordings.
   - Tables: `t_aco2`, `t_aco_norm2`.

3. **Seascaper Data**:
   - Data from the Seascaper tool that relates to environmental data and water classes.
   - Table: `t_seascaper`.

### Data Formats:
- **R Data Frames**: 
  - Data is manipulated and analyzed using R data frames created from the DuckDB tables and CSV files.
  
- **Pandas DataFrames**:
  - In Python, data is handled using Pandas DataFrames, especially in the `data_wrangler.py` and `tidy_biosound_data.ipynb` files.

- **Jupyter Notebook**:
  - The `tidy_biosound_data.ipynb` file is a Jupyter notebook that contains code for data preparation and analysis, including merging and cleaning data.

### Data Analysis and Visualization:
- **R Shiny Dashboard**:
  - The R Shiny dashboard includes multiple tabs for visualizing data, including:
    - Time series plots with annotations.
    - Boxplots comparing index values by species.
    - Heatmaps showing relationships between acoustic indices and water classes.
    - Download options for generated plots and data.

- **Plotting Libraries**:
  - Libraries such as `ggplot2`, `dygraphs`, and `plotly` are used for creating visualizations in the R Shiny application.

### Data Preparation Functions:
- **Data Wrangling**:
  - Functions in `data_wrangler.py` are used to prepare and normalize data, handle annotations, and combine datasets.

- **Normalization**:
  - The `normalize_df` function normalizes acoustic indices to a range between -1 and 1.

- **Annotation Preparation**:
  - Functions like `annotation_prep_kw_style` and `annotation_prep_mr_style` are used to prepare annotations for Key West and May River datasets, respectively.