CREATE TABLE coffee_shop_sales(
transaction_id INT PRIMARY KEY,
transaction_date DATE NOT NULL,
transaction_time TIME NOT NULL,
transaction_qty INT NOT NULL CHECK(transaction_qty > 0) ,
store_id INT NOT NULL,
store_location VARCHAR(80) NOT NULL,
product_id INT NOT NULL,
unit_price NUMERIC(10,2) NOT NULL,
product_category VARCHAR(50) NOT NULL,
product_type TEXT NOT NULL,
product_detail TEXT NOT NULL
);

SELECT * FROM coffee_shop_sales LIMIT 5;

SELECT COUNT(*) FROM coffee_shop_sales;


---------------------------------------------- TOTAL SALES ANALYSIS ----------------------------------------------

SELECT * FROM coffee_shop_sales

--CALCULATE TOTAL SALES FOR EACH RESPECTIVE MONTH

--For a specific month
SELECT TO_CHAR(transaction_date,'month') as months,SUM(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where EXTRACT(MONTH FROM transaction_date) = 5 -- May month
group by TO_CHAR(transaction_date,'month')
order by months desc

--For all months
SELECT TO_CHAR(transaction_date,'month') as months,SUM(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
group by TO_CHAR(transaction_date,'month')
order by months desc


--DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN SALES

SELECT 
      EXTRACT(MONTH FROM transaction_date) AS month_num,
      TO_CHAR(transaction_date,'month') AS month,
	  SUM(transaction_qty * unit_price) AS total_sales, -- total sales column
      LAG(SUM(transaction_qty * unit_price)) 
	  OVER( ORDER BY EXTRACT(MONTH FROM transaction_date)) AS prv_month_sales,
	  Round(
	       (
		     (SUM(transaction_qty * unit_price) 
			 - LAG(SUM(transaction_qty * unit_price)) 
			 OVER( ORDER BY EXTRACT(MONTH FROM transaction_date)))
	         / LAG(SUM(transaction_qty * unit_price)) 
			 OVER( ORDER BY EXTRACT(MONTH FROM transaction_date))) * 100 , 
			 2  ) AS mom_increase_percentage,
	  SUM(transaction_qty * unit_price) 
	  - LAG(SUM(transaction_qty * unit_price)) 
	  OVER( ORDER BY EXTRACT(MONTH FROM transaction_date)) as mom_increase_revenue
	  
FROM coffee_shop_sales
GROUP BY TO_CHAR(transaction_date,'month'),EXTRACT(MONTH FROM transaction_date)
ORDER BY month_num 


---------------------------------------------- TOTAL ORDER ANALYSIS ----------------------------------------------

select * from coffee_shop_sales

--CALCULATE THE TOTAL NUMBER OF ORDERS FOR EACH RESPECTIVE MONTH

SELECT 
	EXTRACT(MONTH FROM transaction_date) AS month_num,
	TO_CHAR(transaction_date,'month') AS month,
	COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
GROUP BY TO_CHAR(transaction_date,'month') , EXTRACT(MONTH FROM transaction_date)
ORDER BY month_num

--DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN ORDERS

SELECT 
	EXTRACT(MONTH FROM transaction_date) AS month_num,
	TO_CHAR(transaction_date,'month') AS month,
	COUNT(transaction_id) AS total_orders,
	LAG(COUNT(transaction_id)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)) as prev_month_order,
	ROUND(
	(
	(COUNT(transaction_id) 
	- LAG(COUNT(transaction_id)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)))::numeric
	/ LAG(COUNT(transaction_id)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date))) * 100,2) as mom_increase_percentage,
	COUNT(transaction_id) 
	- LAG(COUNT(transaction_id)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)) as mom_increase_num_orders
FROM coffee_shop_sales
GROUP BY TO_CHAR(transaction_date,'month') , EXTRACT(MONTH FROM transaction_date)
ORDER BY month_num


---------------------------------------------- TOTAL QUANTITY ANALYSIS ----------------------------------------------

SELECT * FROM coffee_shop_sales

--CALCULATE THE TOTAL QUANTITY SOLD FOR EACH RESPECTIVE MONTH

SELECT 
	EXTRACT(MONTH FROM transaction_date) AS month_num,
	TO_CHAR(transaction_date,'month') AS month,
  	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop_sales
GROUP BY TO_CHAR(transaction_date,'month') , EXTRACT(MONTH FROM transaction_date)
ORDER BY month_num

--DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN TOTAL QUANTITY SOLD

SELECT 
	EXTRACT(MONTH FROM transaction_date) AS month_num,
	TO_CHAR(transaction_date,'month') AS month,
  	SUM(transaction_qty) AS total_qty_sold,
	LAG(SUM(transaction_qty)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)) as prev_month_order,
	ROUND(
	(
	(SUM(transaction_qty) 
	- LAG(SUM(transaction_qty)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)))::numeric
	/ LAG(SUM(transaction_qty)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date))) * 100,2) as mom_increase_percentage,
	SUM(transaction_qty) 
	- LAG(SUM(transaction_qty)) 
	OVER(ORDER BY EXTRACT(MONTH FROM transaction_date)) as mom_increase_num_qty 
FROM coffee_shop_sales
GROUP BY TO_CHAR(transaction_date,'month') , EXTRACT(MONTH FROM transaction_date)
ORDER BY month_num



---------------------------------------------- CALENDER HEAT MAP ANALYSIS ----------------------------------------------

--  TOTAL SALES , TOTAL ORDERS,TOTAL ORDERS FOR EACH DAY

SELECT 
	transaction_date,
	CONCAT('$ ',ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') as total_sales,
	COUNT(transaction_id) AS total_orders,
	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop_sales
WHERE 
	transaction_date = '2023-03-27'
GROUP BY transaction_date	 


-- SALES ANALYSIS BY WEEKEND AND WEEKDAYS

-- WEEKEND - 0,6 (SUN,SAT)
-- WEEKDAY - 1-5(MON - FRI)

SELECT 
	CASE 
		WHEN EXTRACT(DOW FROM transaction_date) IN (0,6) THEN 'weekend' 
		ELSE 'weekday'
	END AS day_type,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales	
WHERE EXTRACT(MONTH FROM transaction_date) = 2
GROUP BY 
	CASE WHEN EXTRACT(DOW FROM transaction_date) IN (0,6) THEN 'weekend'
	ELSE 'weekday'
	END;

	
SELECT EXTRACT(DAY FROM transaction_date) AS day, -- day number
 TO_CHAR(transaction_date, 'Day') AS day_name -- day name
FROM coffee_shop_sales
WHERE 
	transaction_date = '2023-03-28'
group by EXTRACT(DAY FROM transaction_date),TO_CHAR(transaction_date, 'Day')
;

--SALES ANALYSIS BY STORE LOCATION

SELECT 
	store_location,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS sales_revenue
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
group by store_location
ORDER BY sales_revenue DESC

--DAILY SALES BY AVERAGE LINE
SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,2),'K') AS avg_sales
FROM (	
		SELECT 
			SUM(unit_price * transaction_qty) AS total_sales
		FROM coffee_shop_sales
		WHERE EXTRACT(MONTH FROM transaction_date) = 5
		GROUP BY transaction_date  --GIVES US DAY BY DAY SUM OF SALES
		)

--DAILY SALES FOR MONTH

SELECT 
	EXTRACT(DAY FROM transaction_date)  AS day_of_month,
	SUM(unit_price * transaction_qty) AS total_sales,
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY transaction_date


--COMPARISON OF DAILY SALES TO AVG SALES OF A PARTICULAR MONTH
SELECT day_of_month,
	avg_sales,
	total_sales,
	CASE
		WHEN total_sales > avg_sales THEN 'Above avg'
		WHEN total_sales < avg_sales THEN 'Below avg'
		ELSE 'Average'
	END AS sales_status
FROM	
(
SELECT 
	EXTRACT(DAY FROM transaction_date)  AS day_of_month,
	SUM(unit_price * transaction_qty) AS total_sales,
	AVG(SUM(unit_price * transaction_qty)) OVER() AS avg_sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY transaction_date ) 

-- SALES ANALYSIS BY PRODUCT CATEGORY

SELECT 
	EXTRACT(MONTH FROM transaction_date) as month,
	product_category AS Category,
	SUM(unit_price * transaction_qty)  AS total_sales
FROM coffee_shop_sales
GROUP BY product_category,EXTRACT(MONTH FROM transaction_date)
ORDER BY month,total_sales desc

--TOP 10 PRODUCTS BY SALES

SELECT 
	product_type,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales	
WHERE EXTRACT(MONTH FROM transaction_date) = 5 --AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10

--SALES ANALYSS BY DAYS AND HOURS

SELECT
	SUM(unit_price * transaction_qty) AS total_sales,
	COUNT(transaction_id) AS total_orders,
	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5 --MAY
	AND EXTRACT(DOW FROM transaction_date) = 1 -- MONDAY
	AND EXTRACT(HOUR FROM transaction_time) = 8 -- 8 AM(HOUR)

---- PEAK HOURS WHEN THE SALES ARE MAXIMUM

SELECT 
	EXTRACT(HOUR FROM transaction_time) AS hour_of_day,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5	
GROUP BY EXTRACT(HOUR FROM transaction_time)
ORDER BY total_sales DESC

-- PEAK DAYS WHEN THE SALES IN MAX

SELECT 
	CASE
		WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
		ELSE 'Sunday'
	END AS day_of_week,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY 
	EXTRACT(DOW FROM transaction_date),
	CASE
		WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
		ELSE 'Sunday'
	END
ORDER BY EXTRACT(DOW FROM transaction_date)

