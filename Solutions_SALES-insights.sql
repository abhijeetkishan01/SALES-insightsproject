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