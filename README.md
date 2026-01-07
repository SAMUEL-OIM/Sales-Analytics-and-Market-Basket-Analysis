# Sales Analytics and Market Basket Analysis (SQL)

## Project Overview

This project analyzes a sales transaction dataset using MySQL to uncover patterns in revenue, customer purchasing behavior, time-based sales trends, and product associations.

The analysis addresses key analytical questions such as:

* Which year generated the highest total sales?
* Which city recorded the highest revenue?
* What time of day maximizes customer purchases?
* Which products are most frequently bought together?
* Which product sold the most and why?

---

## Dataset Description

The dataset contains transactional sales records with the following fields:

* Order ID
* Product
* Quantity Ordered
* Price Each
* Order Date
* Purchase Address

---

## Tools and Technologies

* Database: MySQL 8.0
* Query Language: SQL
* Data Source: CSV
* Environment: Local MySQL Server

---

## Database Structure

### sales_analytics

Raw table created directly from the imported CSV file.

### clone_sales_analytics

A cleaned and deduplicated version of the dataset used for analysis.

---

## Data Import

* Data was imported using `LOAD DATA INFILE`
* Fields were properly enclosed and delimited
* Header rows were excluded during import
* Raw data was preserved before transformation

---

## Data Cleaning and Preparation

### Duplicate Handling

* Duplicate records were removed using `SELECT DISTINCT`
* A working table (`clone_sales_analytics`) was created

---

### Feature Engineering

* A new column, `Sales`, was created using:

  ```
  Sales = Quantity_Ordered × Price_Each
  ```
* Sales values were rounded to two decimal places

---

### Date Formatting

* The `Order_Date` column contained mixed formats:

  * MM/DD/YY HH:MM
  * MM/DD/YYYY HH:MM
* All formats were standardized and converted to the `DATETIME` data type

---

## Exploratory and Analytical Questions

### Best Year for Sales

* Total sales were aggregated by year
* The year with the highest revenue was identified

---

### City with the Highest Sales

* City information was extracted from purchase addresses
* Total sales were computed per city
* The city with the highest revenue was identified

---

### Optimal Advertisement Timing

* Sales were grouped into time ranges:

  * 00:00–06:00
  * 06:00–12:00
  * 12:00–18:00
  * 18:00–24:00
* Sales performance across time ranges was analyzed to determine peak purchasing periods

---

### Market Basket Analysis

* Products frequently purchased together were identified
* Duplicate product pairs were avoided
* Product pairs were ranked by co-purchase frequency

---

### Best-Selling Products

* Total quantities sold were aggregated per product
* The product with the highest sales volume was identified

---

## Association Rule Analysis

To strengthen the basket analysis, association rule metrics were computed:

* Support
  Frequency of a product pair relative to all transactions

* Confidence
  Likelihood of purchasing Product B given Product A

* Lift
  Strength of the relationship between two products
  A lift value greater than 1 indicates a strong association

Top product associations were ranked based on these metrics.

---

## Key Insights

* Sales performance varies significantly across years
* A small number of cities contribute disproportionately to total revenue
* Purchases peak during mid to late hours of the day
* Certain products exhibit strong co-purchase relationships
* Best-selling products tend to be lower priced and frequently used

---

## Scope of Analysis

* This project combines exploratory analysis with business-oriented analytics
* No predictive modeling was performed
* Results are suitable for sales strategy evaluation, marketing optimization, and inventory planning

---

## How to Run the Project

1. Install MySQL Server 8.0
2. Place the CSV file in:

   ```
   C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
   ```
3. Execute SQL scripts in the following order:

   * Table creation
   * Data import
   * Data cleaning
   * Analytical queries

---

## Author

Olusesan Samuel
Data Analyst
SQL, Sales Analytics, Market Basket Analysis
