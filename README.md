# SALES-insightsproject
Sales Insights Dashboard | SQL + Tableau

Project Overview

This project analyzes sales transactions across multiple markets, customers, and products to uncover business trends, revenue drivers, customer concentration risks, and growth opportunities.

The objective was to transform raw sales data into actionable business insights through SQL analysis and an interactive Tableau dashboard.

⸻

Business Problem

Stakeholders needed answers to the following questions:

1. Is the business growing or declining over time?
2. Which markets generate the highest revenue?
3. Which products drive sales performance?
4. Who are the most valuable customers?
5. What business risks and opportunities exist?
6. How concentrated is revenue across customers and products?

⸻

Dataset Structure

Fact Table

transactions

* product_code
* customer_code
* market_code
* order_date
* sales_qty
* sales_amount
* currency

Dimension Tables

customers

* customer_code
* customer_name
* customer_type

products

* product_code
* product_type

markets

* markets_code
* markets_name
* zone

date

* date
* year
* month_name

⸻

Data Modeling Challenges

During data validation, I discovered:

* 339 distinct product codes existed in transactions
* Only 279 product codes existed in products
* 60 product codes were missing

Solution

Using SQL analysis, I identified the missing product codes and inserted them into the products table before creating relationships.

This ensured:

* Consistent joins
* Complete reporting
* Improved data quality

⸻

SQL Analysis Performed

Revenue Trend Analysis

Business Question:

Is revenue increasing or decreasing over time?

Analysis:

* Monthly Revenue
* Quarterly Revenue
* Yearly Revenue
* Year-over-Year Growth

Key SQL Concepts:

* Aggregate Functions
* Date Functions
* GROUP BY
* Window Functions (LAG)

⸻

Market Performance Analysis

Business Question:

Which markets generate the most revenue?

Analysis:

* Revenue by Market
* Market Contribution Percentage
* Top Revenue Markets

Key SQL Concepts:

* Joins
* Aggregation
* Percentage Calculations

⸻

Customer Analysis

Business Question:

Who are the most valuable customers?

Analysis:

* Top Customers by Revenue
* Customer Revenue Contribution
* Customer Concentration Analysis

Key SQL Concepts:

* Ranking
* Aggregations
* Revenue Contribution

⸻

Product Analysis

Business Question:

Which products drive sales?

Analysis:

* Top Products
* Product Revenue Contribution
* Product Performance Comparison

Key SQL Concepts:

* Aggregations
* Ranking
* Percentage Contribution

⸻

Business Risk Analysis

Business Questions:

* Is revenue dependent on a few customers?
* Are any markets declining?
* Are there underperforming products?

Analysis:

* Top 5 Customers
* Revenue Concentration
* Market Trends
* Product Contribution

⸻

Dashboard Features

Executive KPIs

* Total Revenue
* Total Sales Quantity

Revenue Analysis

* Revenue by Year
* Revenue Trend by Month

Market Analysis

* Revenue by Market
* Market Ranking

Product Analysis

* Top 5 Products

Customer Analysis

* Top 5 Customers

Interactive Filters

* Year Filter
* Month Filter

⸻

Key Business Insights

Revenue Performance

* Total Revenue reached approximately 986.57M.
* Revenue peaked during 2018.
* Revenue showed fluctuations across different years.

Market Insights

* Delhi NCR generated over 520M revenue.
* Mumbai and Ahmedabad were the next strongest markets.
* Revenue is highly concentrated in a few markets.

Customer Insights

* Electricalsara Stores contributed more than 413M revenue.
* Revenue dependence on a small number of customers creates concentration risk.

Product Insights

* A small group of products drives the majority of sales quantity.
* Product performance is uneven across the portfolio.

Business Risks

* Customer concentration risk.
* Heavy dependence on Delhi NCR.
* Potential revenue volatility if major customers reduce purchases.

Business Opportunities

* Expand successful products into lower-performing markets.
* Strengthen customer retention strategies for top customers.
* Focus sales efforts on high-growth regions.

⸻

Tools Used

* MySQL
* Tableau
* SQL
* Data Modeling
* Data Cleaning
* Business Analysis
* Data Visualization

⸻

Skills Demonstrated

* Data Cleaning
* SQL Joins
* Data Modeling
* KPI Design
* Dashboard Development
* Business Analysis
* Data Storytelling
* Stakeholder Reporting

⸻

Project Outcome

The dashboard converts raw transactional data into actionable business insights, helping stakeholders monitor revenue performance, identify growth opportunities, and understand customer and market dynamics.





<img width="1470" height="744" alt="Screenshot 2026-06-20 at 5 47 22 PM" src="https://github.com/user-attachments/assets/ab1974d9-40cc-4189-a39e-75228c32cefa" />






Solutions in SQL




USE  sales;

SELECT COUNT(*) FROM transactions;

SELECT COUNT(*) FROM products;

SELECT COUNT(*) FROM markets;

SELECT COUNT(*) FROM date;

SELECT COUNT(*) FROM customers;



-- know i have to connect tables for data analysis ;


ALTER TABLE transactions
ADD constraint fk_customer
FOREIGN KEY (customer_code)
REFERENCES customers(customer_code);

 

ALTER TABLE transactions
ADD CONSTRAINT fk_date
FOREIGN KEY (order_date)
REFERENCES date(date);


ALTER TABLE transactions
ADD CONSTRAINT fk_market
FOREIGN KEY (market_code)
REFERENCES markets(markets_code);


SELECT DISTINCT market_code
FROM transactions
WHERE market_code NOT IN (
    SELECT markets_code
    FROM markets
);

-- FINDING ERROR OCCUROIN THING AND CORRECTING IT 


SELECT COUNT(DISTINCT product_code)
FROM transactions
WHERE product_code NOT IN (
    SELECT product_code
    FROM products) ;
-- 60

SELECT DISTINCT product_code
FROM transactions
WHERE product_code NOT IN (
    SELECT product_code
    FROM products) ;
    -- inserting missing data 
    
    INSERT INTO products (product_code)
SELECT DISTINCT product_code
FROM transactions
WHERE product_code NOT IN (
    SELECT product_code
    FROM products
);
    
    
    SELECT COUNT(*) AS affected_rows
FROM transactions
WHERE product_code NOT IN (
    SELECT product_code
    FROM products
);
-- 0 affected that means all entry done perfectoly 

select COUNT(DISTINCT product_Code) FROM products;
-- both ARE = THAT MEENS NO ERROR 
select COUNT(DISTINCT product_Code) FROM products;


ALTER TABLE transactions
ADD CONSTRAINT fk_products
FOREIGN KEY (product_code)
REFERENCES products(product_code);
-- all things are managed 


-- Business Questions

-- 1. What is the overall revenue trend over time?
-- Why stakeholders care: Is the business growing or declining?

-- Insight:
-- * Monthly Revenue
-- * Quarterly Revenue
-- * YoY Growth


 SELECT DISTINCT YEAR(order_date) AS year
FROM transactions
ORDER BY year;

-- MONTHLY REVANUE

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS revenue
FROM transactions
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- QUTARLY REVANUE

SELECT
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    SUM(sales_amount) AS revenue
FROM transactions
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY year, quarter;


-- YoY revanue 
SELECT
    year,
    revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY year))
        / LAG(revenue) OVER (ORDER BY year)) * 100,
        2
    ) AS yoy_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        SUM(sales_amount) AS revenue
    FROM transactions
    GROUP BY YEAR(order_date)
) t;


-- 2. Which markets generate the most revenue?
-- Why stakeholders care: Where is the business strongest?

-- Insight:
-- * Revenue by Market
-- * Market Contribution %


SELECT
    m.markets_name,
    SUM(t.sales_amount) AS total_revenue
FROM transactions t
JOIN markets m
ON t.market_code = m.markets_code
GROUP BY m.markets_name
ORDER BY total_revenue DESC;


-- * Market Contribution %
SELECT
    m.markets_name,
    SUM(t.sales_amount) AS revenue,
    ROUND(
        SUM(t.sales_amount) * 100.0 /
        (SELECT SUM(sales_amount) FROM transactions),
        2
    ) AS contribution_pct
FROM transactions t
JOIN markets m
ON t.market_code = m.markets_code
GROUP BY m.markets_name
ORDER BY revenue DESC;


-- 3. What percentage of revenue comes from the top customers/products? 
-- Why stakeholders care: Understand concentration risk.

-- Insight:

-- * Top 20
-- * Top 20% products → X% revenue

SELECT
    customer_code,
    SUM(sales_amount) AS revenue
FROM transactions
GROUP BY customer_code
ORDER BY revenue DESC
LIMIT 20;

SELECT COUNT(DISTINCT customer_code) AS total_customers
FROM transactions;

-- * Top 20 products → X% revenue

    SELECT
        product_code,
        SUM(sales_amount) AS revenue
    FROM transactions
    GROUP BY product_code
    ORDER BY revenue DESC
    LIMIT 20 ;

-- 4. What are the key business opportunities and risks?
-- Why stakeholders care: Actionable recommendations.
--  Insights:

-- * Revenue heavily dependent on 5 customers
-- * Delhi market declining for 3 consecutive months.
-- * Product A contributes 25% of revenue.
-- * South region growing faster than all others.


SELECT
    customer_code,
    SUM(sales_amount) AS revenue
FROM transactions
GROUP BY customer_code
ORDER BY revenue DESC
LIMIT 5;


SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS revenue
FROM transactions
WHERE market_code = 'Mark004'  -- example Delhi
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;


SELECT
    product_code,
    SUM(sales_amount) AS revenue,
    ROUND(
        SUM(sales_amount) * 100 /
        (SELECT SUM(sales_amount)
         FROM transactions),
        2
    ) AS contribution_pct
FROM transactions
GROUP BY product_code
ORDER BY revenue DESC;


SELECT
    market_code,
    SUM(sales_amount) AS revenue
FROM transactions
GROUP BY market_code
ORDER BY revenue DESC;



-- END OF PROJECT 
