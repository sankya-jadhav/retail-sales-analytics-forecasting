# Retail Sales Analytics and Demand Forecasting

An end-to-end data analytics project that transforms retail sales
transactions into business insights and compares forecasting approaches
for monthly units sold using Python, SQL, MySQL, Power BI, and machine
learning.

> **Important context:** The source dataset covers order dates from
> January 2010 through September 2017. The monthly forecasting series
> ends in July 2017. Forecasts for August 2017--July 2018 are a
> historical forecasting exercise, not a current prediction.

## Project Objectives

-   Analyze revenue, cost, profit, units sold, products, regions,
    countries, and sales channels.
-   Design a relational MySQL database using a star schema.
-   Prepare and load data through a Python ETL workflow.
-   Build an interactive Power BI report.
-   Compare baseline, statistical, and machine-learning forecasting
    approaches using time-aware evaluation.
-   Document assumptions and limitations.

## Technology Stack

  Area                   Tools
  ---------------------- ----------------------------------------
  Programming and ETL    Python, Pandas, NumPy
  Database and queries   MySQL, SQL
  Visualization          Power BI, Matplotlib, Seaborn
  Forecasting            Seasonal Naive, SARIMA, XGBoost
  Evaluation             MAE, RMSE, MAPE
  Development            Jupyter Notebook, VS Code, Git, GitHub

## Dataset

The project uses 50,000 order-level sales records with fields such as
Region, Country, Item Type, Sales Channel, Order Priority, Order Date,
Ship Date, Units Sold, Unit Price, Unit Cost, Total Revenue, Total Cost,
and Total Profit.

The dataset has no customer, inventory, or stockout information. Monthly
units sold is therefore used as a **proxy for demand**, not as a measure
of unmet demand. The source is a sample dataset and may not represent
the behavior of a real retailer; consider its licensing before
redistribution.

## Project Workflow

1.  Inspect and prepare data; validate columns and dates, clean
    inconsistent text, and prepare the analytical dataset.
2.  Create a MySQL star-schema database.
3.  Load dimensions and fact records through the Python ETL workflow.
4.  Run SQL analyses for KPIs, regional and product results, sales
    channels, and top countries.
5.  Explore results in the Power BI report.
6.  Compare forecasting models using chronological and walk-forward
    validation.

## Database Design

The database is named `retail_sales_analytics`.

-   `fact_sales` --- order-level measures and foreign keys.
-   `dim_date` --- calendar attributes for order and ship dates.
-   `dim_product` --- product categories.
-   `dim_geography` --- countries and regions.
-   `dim_sales_channel` --- sales channels.
-   `dim_priority` --- priority codes.
-   `monthly_forecast` --- stored monthly forecast values.

The date dimension is reused for order date and ship date (a
role-playing dimension).

## How to Run the Project

### 1. Clone the repository

``` bash
git clone https://github.com/sankya-jadhav/retail-sales-analytics-forecasting.git
cd retail-sales-analytics-forecasting
```

### 2. Create a Python environment and install dependencies

``` powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 3. Configure database credentials

Copy `.env.example` to `.env` and update it for your local MySQL setup:

``` env
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=retail_sales_analytics
```

Do not commit `.env` or real credentials to GitHub.

### 4. Create the database schema

Open `sql/01_create_schema.sql` in MySQL Workbench and run it in a new
or intentionally reset database environment. Review the script first: it
creates the database and tables, but does not by itself populate the
dimension and fact records. Do not rerun schema-creation statements
against important existing data without reviewing them and making a
backup.

### 5. Load data

Review `src/data/load_to_mysql.py` and ensure the dimension tables are
populated as required by the ETL workflow before loading fact records.
Configure `.env`, then run from the repository root:

``` powershell
python src/data/load_to_mysql.py
```

### 6. Run SQL analysis

After the database is populated, open and execute
`sql/02_business_analysis.sql` in MySQL Workbench.

### 7. Explore the notebook and dashboard

-   Open `notebook/sales.ipynb` in Jupyter Notebook or VS Code.
-   Open `dashboard/dashboard.pbix` in Power BI Desktop. Refreshing may
    require a MySQL connection configured on your machine.
-   Forecast outputs are in `data/monthly_forecast.csv` and
    `data/historical_forecast_combined.csv`.

## Key Business Findings

  Metric                               Result
  --------------- ---------------------------
  Orders                               50,000
  Total revenue                 66.19 billion
  Total cost                    46.66 billion
  Total profit                  19.53 billion
  Profit margin                        29.50%
  Units sold        Approximately 250 million

Other findings:

-   Sub-Saharan Africa and Europe together contributed approximately
    51.7% of total revenue.
-   Household had the highest revenue among product categories.
-   Cosmetics generated the highest absolute profit among product
    categories.
-   Clothes had the highest product profit margin, while Meat had the
    lowest.
-   Online and Offline sales had very similar revenue, profit, and order
    volumes.

These figures describe the supplied historical dataset, not current
retail-market results.

## Power BI Dashboard

The report has three pages: Executive Overview, Sales Analysis, and
Demand Forecasting.

### Executive Overview

Displays revenue, profit, margin, units sold, orders, yearly
performance, regional contribution, and sales-channel comparison.

![Executive Overview](screenshots/executive_overview.png)

### Sales Analysis

Explores revenue and profit by product, product profit margins, and top
countries by revenue.

![Sales Analysis](screenshots/sales_analysis.png)

### Demand Forecasting

Compares historical monthly units sold with the forecast and presents
validation metrics.

![Demand Forecasting](screenshots/demand_forecasting.png)

The editable Power BI report is included at `dashboard/dashboard.pbix`.

## Forecasting Approach and Evaluation

The forecasting target is monthly units sold. The series used for the
experiment covers January 2010 through July 2017.

-   **Initial split:** training from January 2010 to December 2016 (84
    months); test from January to July 2017 (7 months).
-   **Models compared:** Naive, Seasonal Naive, SARIMA, and XGBoost.
-   **Additional evaluation:** walk-forward validation across six-month
    periods in 2015, 2016, and 2017.

### Walk-forward validation results

  Model              Average MAE   Average RMSE   Average MAPE
  ---------------- ------------- -------------- --------------
  Seasonal Naive         169,320        210,440          6.22%
  XGBoost                174,745        207,283          6.43%

Seasonal Naive was selected because it achieved lower average MAE and
MAPE across the reported walk-forward periods. XGBoost achieved a
slightly lower average RMSE. Seasonal Naive therefore provided a strong,
simple baseline for this dataset.

The 12-month output covers **August 2017 through July 2018**. These are
historical projections following the last observed month, not a forecast
for current retail demand.

### Forecasting limitations

-   The dataset is a sample and may not represent a real retailer.
-   Available history ends in 2017; the forecast should not be used for
    present-day operational planning.
-   The initial holdout test contains only seven months.
-   Units sold is a demand proxy because inventory and stockout data are
    unavailable.
-   Forecasts are point estimates and do not provide prediction
    intervals or guarantee future results.

## Repository Structure

``` text
retail-sales-analytics-forecasting/
├── dashboard/
│   └── dashboard.pbix
├── data/
│   ├── 50000 Sales Records.csv
│   ├── historical_forecast_combined.csv
│   └── monthly_forecast.csv
├── figure/
│   └── image.png
├── notebook/
│   └── sales.ipynb
├── screenshots/
│   ├── demand_forecasting.png
│   ├── executive_overview.png
│   └── sales_analysis.png
├── sql/
│   ├── 01_create_schema.sql
│   └── 02_business_analysis.sql
├── src/
│   └── data/
│       └── load_to_mysql.py
├── .env.example
├── .gitignore
├── readme.md
└── requirements.txt
```

## Future Improvements

-   Add automated data-quality checks and structured ETL logging.
-   Make the database load fully repeatable, including dimension
    population and safe reruns.
-   Evaluate forecasting with longer, more representative, and more
    recent data.
-   Explore prediction intervals and additional seasonal baselines.
-   Document tested package versions and Power BI connection
    configuration.

## Author

**Sanket Jadhav**\
GitHub: [sankya-jadhav](https://github.com/sankya-jadhav)
