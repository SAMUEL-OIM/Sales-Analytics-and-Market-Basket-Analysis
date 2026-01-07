										-- SALES_ANALYTICS DATASE
## Data Importation
CREATE table Sales_analytics(Order_ID INT, Product TEXT, Quantity_Ordered INT ,Price_Each FLOAT, 
							  Order_Date TEXT, Purchase_Address TEXT);
                     DESC sales_analytics;
LOAD DATA INFILE "\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Sales_analytics.csv"
INTO TABLE mine.Sales_analytics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 

## Clone of the original data to remove duplicate
CREATE TABLE clone_Sales_Analytics AS 
SELECT DISTINCT *
FROM sales_analytics;

-- Addition of "Sales" column = Quantiy_Ordered X Price Each
ALTER TABLE clone_sales_analytics
ADD COLUMN Sales DOUBLE AFTER Price_Each;
UPDATE  clone_sales_analytics
SET Sales = ROUND(Quantity_Ordered * Price_Each,2);

-- Formatting and Modifying the "Order_Date" Column
UPDATE clone_sales_analytics
SET Order_Date = CASE
        WHEN Order_Date LIKE '%/%/% %:%' THEN STR_TO_DATE(Order_Date, '%m/%d/%Y %H:%i')
        ELSE STR_TO_DATE(Order_Date, '%m/%d/%y %H:%i')
    END /* OR    CASE 
					WHEN Order_Date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(Order_Date,"%m/%d/%y %H:%i")
					WHEN Order_Date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$' THEN STR_TO_DATE(Order_Date,"%m/%d/%Y %H:%i")
				 END */;
ALTER TABLE clone_sales_analytics
MODIFY Order_Date DATETIME;

							## What was the best year for sales? How much was earned that year?
SELECT YEAR(Order_Date) AS Year, ROUND(SUM(Sales),2) AS Total_Sales
FROM clone_sales_analytics
GROUP BY Year
ORDER BY Total_Sales DESC;

								## What city had the highest number of sales?
SELECT LEFT(SUBSTRING(Purchase_Address,LOCATE(", ",Purchase_Address)+2),
			LOCATE(", ",SUBSTRING(Purchase_Address,LOCATE(", ",Purchase_Address)+3))) AS City, ROUND(SUM(Sales),2) AS Total_Sales
FROM clone_sales_analytics
GROUP BY City
ORDER BY Sales DESC
LIMIT 1;

				## What time should we display advertisement to maximize likehood of customer's buying product?
-- We can infer that the advertisement should be at the "mid hour to the late hour of the day" i.e "PM" 
SELECT CASE 
		WHEN TIME(Order_Date) < "06:00:00" THEN "00:00-06:00" 
		WHEN TIME(Order_Date) < "12:00:00" THEN "06:00-12:00" 
		WHEN TIME(Order_Date) < "18:00:00" THEN "12:00-18:00" 
        ELSE "18:00-24:00" 
        END AS Time_Range,
        CASE 
		WHEN TIME(Order_Date) < "06:00:00" THEN "Early Hours" 
		WHEN TIME(Order_Date) < "12:00:00" THEN "Forenoon Hours" 
		WHEN TIME(Order_Date) < "18:00:00" THEN "Mid Hours" 
        ELSE "Late Hours" 
        END AS Hours_of_the_day,
        ROUND(SUM(Sales),2) AS Total_Sales
FROM clone_sales_analytics
GROUP BY Time_Range
ORDER BY Sales DESC;

													-- [BASKET ANALYSIS]
                                        ## What products are most often sold together?
SELECT  A.Product AS ProductA, B.Product AS ProductB, COUNT(*)  AS Times_Together 
FROM clone_sales_analytics AS A
JOIN clone_sales_analytics AS B
/*For the "ON" aspect, The kind of Order_ID merge together are those that have differences in their other colums*/
/*For the "AND" aspect, While merging them together to avoid duplicate pairs
						It will CHECK that merge only those that the alphabet is less than eachother
                        E.g "Bread + Egg" and "Egg + Bread"
                        It will pick only "Bread + Egg" 
*/
ON A.Order_ID = B.Order_ID AND A.Product < B.Product
/*The "GROUP BY" will group by the products on the same row as in "Bread" "Egg"
 But since we have numerous Order_ID who bought same "Bread" "Egg"
 It will take one "Bread" Egg" row and count the number of times it appears*/
GROUP BY A.Product, B.Product
ORDER BY Times_Together DESC;

										## What product sold the most? Why do you think it sold the most?
SELECT Product, SUM(Quantity_Ordered) AS Frequency
FROM clone_sales_analytics
GROUP BY Product
ORDER BY Frequency DESC;
										## Why do you think it sold the most?
-- Price - It is lesser compare it other products
-- Durability - It is the less durable material compare to other sort of battery
-- Demand -- it has more demanad due to it durability and everyday use.

                                        
SELECT *
FROM clone_sales_analytics;
DESC sales_analytics;

									/* BASKET ANALYSIS */ 
  /* (The association Rule) : Support – How often an item or item pair appears 
									Support(X,Y) = Transactions containing both X and Y / Total number of transactions
							  Confidence – How likely Y is bought when X is bought
									Confidence(X→Y) = Transactions containing both X and Y / Transactions with X
                              Lift – Strength of the association (greater than 1 = strong) 
									Lift = Support (X,Y) / Transactions with X * Transactions with Y */
WITH market AS (SELECT T1.Product AS Product1, 
					   T2.Product AS Product2, 
					   COUNT(DISTINCT T1.Order_ID) AS Frequency,
					   (SELECT COUNT(DISTINCT Order_ID) FROM clone_sales_analytics) AS Total_Transaction
FROM clone_sales_analytics AS T1
JOIN clone_sales_analytics AS T2
ON T1.Order_ID = T2.Order_ID
AND T1.Product < T2.Product
GROUP BY Product1, Product2
ORDER BY Frequency ASC)

SELECT Product1,
	   Product2,
       Frequency,
       Frequency * 100 / Total_Transaction AS `Support(%)`,
	   Frequency * 100 / (SELECT COUNT(Order_ID) FROM clone_sales_analytics AS CSC WHERE CSC.Product = Product1 ) AS `Confidence (%)`,
       Frequency * 100 / Total_Transaction / (SELECT COUNT(Order_ID) FROM clone_sales_analytics AS CSC WHERE CSC.Product = Product1 ) * (SELECT COUNT(Order_ID) FROM clone_sales_analytics AS CSC WHERE CSC.Product = Product2 ) AS Lift
FROM market
ORDER BY Frequency DESC
LIMIT 5;
