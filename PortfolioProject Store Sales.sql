CREATE DATABASE IF NOT exists  Store_sales;

SELECT * FROM Sales;

USE Store_sales;

#1. KPIs Total Revenue | Total Orders | Average Order Value (AOV) | Average Rating | Average Discount Percentage | Discounted Share of Orders | Repeat Customer Share

SELECT
ROUND(SUM(Amount),2) 
AS total_revenue,
COUNT(*) 
AS total_orders,
ROUND((SUM(Amount)/COUNT(*)),2) 
AS avg_order_value,
ROUND(AVG(ItemRating),2) 
AS avg_rating,
ROUND(AVG(`DiscountApplied(%)`),1)
AS avg_discount_pct,
Round(100.0 * SUM( Case WHEN `DiscountApplied(%)` > 0 THEN 1 ELSE 0 END)/Count(*),1)
AS Discounted_share_pct,
ROUND(100.0 * SUM( CASE WHEN PreviousPurchases > 0 THEN 1 ELSE 0 END)/COUNT(*),1)
AS repeat_customer_share_pct
FROM Sales;

#2. What sells: revenue, orders, order value and rating by category

SELECT 
Category,
COUNT(*) 
AS orders,
ROUND(100.0 * COUNT(*)/ (SELECT COUNT(*) FROM Sales),1)
AS order_share_pct,
ROUND(SUM(Amount),2)
as revenue,
ROUND( 100.0 * SUM(Amount) / (SELECT SUM(Amount) FROM Sales),2)
AS revenue_share_pct,
ROUND(AVG(Amount),2)
AS avg_order_value,
ROUND(AVG(ItemRating),2)
AS avg_rating
FROM Sales
GROUP BY Category
ORDER BY revenue DESC; 

#3. Top 10 items by Revenue

Select 
ItemPurchased,
Category,
COUNT(*)
AS orders,
ROUND(SUM(Amount),2)
AS revenue,
ROUND( 100 * SUM(Amount) / (SELECT SUM(Amount) FROM Sales), 1)
AS revenue_share_pct,
ROUND( AVG(ItemRating),2)
AS avg_rating
FROM Sales
GROUP BY ItemPurchased, Category
ORDER BY revenue DESC
LIMIT 10;
	
#4. When they buy- By season

SELECT 
Season,
COUNT(*)
AS orders,
ROUND(SUM(Amount),2)
AS revenue,
ROUND( 100.0 * SUM(Amount) / (SELECT SUM(Amount) FROM Sales), 1)
AS revenue_share_pct,
ROUND( AVG(AMOUNT), 2)
AS avg_order_value,
ROUND( AVG(ItemRating), 2)
AS avg_rating
FROM Sales
GROUP BY Season
ORDER BY CASE Season WHEN 'Spring' THEN 1 WHEN 'Summer' THEN 2 WHEN 'Autumn' THEN 3 ELSE 4 END;

#5. Who buys- By Age 

SELECT 
CASE WHEN Age < 30 THEN '1. 20-29'
WHEN Age < 40 THEN '2. 30-39'
WHEN Age < 50 THEN '3. 40-49'
WHEN Age < 60 THEN '4. 50-59'
ELSE '5. 60-70'END
AS age_band,
COUNT(*)
AS orders,
ROUND (SUM(Amount),2)
AS revenue,
ROUND(AVG(Amount),2)
AS avg_order_value
FROM Sales
GROUP BY age_band
ORDER BY age_band;	

#6. Gender-  always read this together with category.
#Electronics and Men's Clothing are bought only by men; Accessories, Beauty and
#Women's Clothing only by women. So gender totals mostly reflect product mix.

SELECT Gender, 
COUNT(*) 
AS orders, 
ROUND(SUM(Amount), 2) 
AS revenue, 
ROUND(AVG(Amount), 2) 
AS avg_order_value
FROM Sales
GROUP BY Gender;
 
SELECT
Category,
SUM(CASE WHEN Gender = 'Male'   THEN 1 ELSE 0 END)                  
AS male_orders,
SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END)                  
AS female_orders,
ROUND(AVG(CASE WHEN Gender = 'Male'   THEN Amount END), 2)          
AS male_avg_order_value,
ROUND(AVG(CASE WHEN Gender = 'Female' THEN Amount END), 2)          
AS female_avg_order_value
FROM Sales
GROUP BY Category
ORDER BY Category;

#7. Payment Method- BY category

SELECT
Category,
COUNT(*)                                                            
AS orders,
ROUND(100.0 * SUM(CASE WHEN PaymentMethod = 'Cash on Delivery' THEN 1 ELSE 0 END)/ COUNT(*), 1)                                                
AS cod_share_pct,
ROUND(AVG(CASE WHEN PaymentMethod = 'Card'             THEN Amount END), 2) 
AS card_avg_order_value,
ROUND(AVG(CASE WHEN PaymentMethod = 'Cash on Delivery' THEN Amount END), 2) 
AS cod_avg_order_value
FROM Sales
GROUP BY Category
ORDER BY cod_share_pct DESC;

#8. Loyalty: previous purchases vs order value, discount and rating

SELECT
CASE WHEN PreviousPurchases <= 3 THEN '1. Light (0-3)'
WHEN PreviousPurchases <= 5 THEN '2. Medium (4-5)'
ELSE '3. Heavy (6+)' END           
AS loyalty_band,
COUNT(*)                                                            
AS orders,
ROUND(AVG(Amount), 2)                                               
AS avg_order_value,
ROUND(AVG(`DiscountApplied(%)`), 1)                                 
AS avg_discount_pct,
ROUND(AVG(ItemRating), 2)                                           
AS avg_rating
FROM Sales
GROUP BY loyalty_band
ORDER BY loyalty_band;

#9. Average discount at each number of previous purchases (rises about 2 points per purchase

SELECT
PreviousPurchases,
COUNT(*)                                                            
AS orders,
ROUND(AVG(`DiscountApplied(%)`), 1)                                 
AS avg_discount_pct
FROM Sales
GROUP BY PreviousPurchases
ORDER BY PreviousPurchases;

#10. Discounts: does a bigger discount change order value or rating?
# (Almost every order is discounted, so compare discount depth, not discounted vs not.)

SELECT
CASE WHEN `DiscountApplied(%)` < 10 THEN '1. Under 10%'
WHEN `DiscountApplied(%)` < 20 THEN '2. 10-19%'
ELSE  '3. 20% or more' END       
AS discount_band,
COUNT(*)                                                            
AS orders,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Sales), 1)           
AS order_share_pct,
ROUND(AVG(Amount), 2)                                               
AS avg_order_value,
ROUND(AVG(ItemRating), 2)                                           
AS avg_rating
FROM Sales
GROUP BY discount_band
ORDER BY discount_band;
 
-- Rough cost of the discounts. Two cases, because the file does not say whether Amount
-- is before or after the discount. Check with whoever supplied the data.

SELECT
ROUND(SUM(Amount * `DiscountApplied(%)` / 100), 0)                  
AS discount_value_if_amount_is_before_discount,
ROUND(SUM(Amount * `DiscountApplied(%)` / (100 - `DiscountApplied(%)`)), 0) 
AS discount_value_if_amount_is_after_discount
FROM Sales;
