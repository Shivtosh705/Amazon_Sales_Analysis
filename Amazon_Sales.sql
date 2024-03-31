create database Amazon_Database;

use Amazon_Database;

create table Amazon(
 Invoice_id varchar(30) not null,
 Branch varchar(5) not null,
 City varchar(30) not null,
 Customer_type varchar(30) not null,
 Gender varchar(10) not null,
 Product_line varchar(100) not null,
 Unit_price decimal(10,2) not null,
 Quantity int not null,
 VAT float not null,
 Total decimal(10,2) not null,
 Date date not null,
 Time time not null,
 Payment varchar(50) not null,
 cogs decimal(10,2) not null,
 gross_margin_percentage float not null,
 gross_income decimal(10,2) not null,
 Rating float not null
);

SELECT * FROM amazon_database.amazon;

alter table amazon
add column month varchar(15);

update amazon
set month = MONTHNAME(date);



alter table amazon
add column dayname varchar(15);

update amazon
set dayname = dayname(date);

ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(20);

UPDATE amazon
SET timeofday = 
    CASE 
        WHEN EXTRACT(HOUR FROM time) >= 5 AND EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) >= 12 AND EXTRACT(HOUR FROM time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;
    
    


-- 1.What is the count of distinct cities in the dataset?

select count( distinct city) as cities from amazon;

-- ---------------------------------------------------
-- 2.For each branch, what is the corresponding city?

select distinct branch,city
from amazon;

-- ------------------------------------------------------------

-- 3.What is the count of distinct product lines in the dataset?

select count(distinct product_line) as distinct_productLine from amazon;

-- Result:There are 6 product_line
-- --------------------------------------------------------------------

-- 4.Which payment method occurs most frequently?

-- selecting the column 'payment' and counting the occcurences of each payment method
select 
 payment,  -- selecting the Payment method
 count(*) as payment_count  -- counting the occurences of each payment method
                              -- and aliasing it as payment_method 
from amazon
group by 
   payment  -- grouping the results by payment method
order by 
   payment_count desc  -- ordering the results by payment_count
limit 1; -- listing the result to only the top(highest) payment_count

 -- Result:Ewallet is the most frequently used payment method
-- -----------------------------------------------------
-- 5.Which product line has the highest sales?

select 
   product_line,   -- selecting the Product_line
   count(Invoice_id) as sales_count -- counting the number of 'Invoice_id' and 
                                    -- aliasing it as sales_count
  from amazon
  group by 
     Product_line  -- grouping the results by Product_line
order by 
      sales_count desc -- ordering the results by sales_count
limit 1;

-- Result:- Fashion accessories has the highest sales
-- -----------------------------------------------------------
-- 6.How much revenue is generated each month? 

select distinct(month) from amazon;  -- finding the distinct months in dataset

select month, count(Invoice_id) as monthly_sales
from amazon 
group by month;

-- ---------------------------------------------------------------
-- 7.In which month did the cost of goods sold reach its peak?

select 
  month, -- selecting the month 
  sum(cogs) as total_cogs -- calculating the total cogs and aliasing as 'total_cogs'
from
  amazon
group by
   month -- grouping the results by month
order by
   total_cogs desc   -- Ordering the results by total_cogs(total COGS) 
limit 1; -- Limiting the result to only the top(highest) total_cogs

-- Outcome :- In january,cogs reached its peak
-- -----------------------------------------------------------------
-- 8.Which product line generated the highest revenue?

select product_line, -- selecting the product_line 
   sum(total) as Total_Revenue -- calculating the total revenue for each product line aliasing as total_revenue
from amazon
group by 
     Product_line  -- grouping the results by product_line
order by 
    total_revenue desc  -- ordering the results by total_revenue in descending order
limit 1; -- limitiing the result to only the top(highest) total_revenue

-- ---------------------------------------------------------------------
-- 9.In which city was the highest revenue recorded?

select 
    city, -- selecting the city
	sum(total) as Total_Revenue -- calculating the total_revenue for each city and aliasing it as Toatal_Revenue
from
   amazon
group by 
    City -- grouping the results by city
order by 
    total_revenue desc -- ordering the results by total_revenue in descending order
limit 1; -- limitiing the result to only the top(highest) total_revenue

-- ----------------------------------------------------------------------
-- 10.Which product line incurred the highest Value Added Tax?

select 
   product_line, -- selecting the product_line
   sum(vat) as total_vat_amount -- calculating the total_vat amount fro each product_line and aliasing it as total_vat_amount
from 
  amazon
group by 
    Product_line -- grouping the results by Product_line
order by total_vat_amount desc -- ordering the results by total_vat_amount in descending order
limit 1; -- limitiing the result to only the top(highest) totat_vat_amount

-- ------------------------------------------------------------------------
-- 11.For each product line, add a column indicating "Good" 
-- if its sales are above average, otherwise "Bad."

select 
  product_line, -- selecting the product_line
  sum(total) as total_revenue, -- calculating the total revenue fro each product_line and aliasing it as total_revnue
case
    when sum(total) < (select avg(total) from amazon) then 'Bad' -- categorizing rhe sales 'Bad ' according to condition
    else 'good' -- categorizing as 'good' otherwise
    end as kindofsale -- alias for the column representing the type of sale
from amazon
group by 
   Product_line -- grouping the results by product_line 
order by 
    total_revenue desc; -- ordering the result by total-revenue in descending order

-- -------------------------------------------------------------------
-- 12.Identify the branch that exceeded the average number of products sold.

select 
 branch,
 sum(quantity) as total_quantity
from 
 amazon
group by 
 Branch
having 
 sum(Quantity) > (select avg(Quantity) from amazon);

-- ---------------------------------------------------------------------
-- 13.Which product line is most frequently associated with each gender?

-- using Common Table Expression(CTE) named 'freq' to calculate the frequncy of purchasers for each product line and gender 
-- and assigning an 'obsession level' using the Row_Number() window function
with freq as(
select 
    product_line, -- selecting the product line
    gender, -- selecting the gender
    count(Invoice_id) as frequ, -- counting the number of Invoive IDs and aliasing it as freaqu
    row_number() over (partition by gender order by count(Invoice_id)desc)as obsession_level -- assigning obsession
    from 
      amazon
    group by
      Product_line,gender  -- grouping the result by Product_line and gender
)
-- selecting the product line,gender,and frequency where the "obsession level" is equal to 1,
-- which indicates the most purchased product line for each gender
select 
  product_line, -- selecting the product line
  gender, -- selecting the gender
  frequ -- selecting the frequency of purchases
  from 
    freq
  where 
    obsession_level=1; -- filtering out rows where the 'obsession level' is equal to 1

-- ------------------------------------------------------------------------
-- 14.Calculate the average rating for each product line. 

-- selecting the column 'product line' and calculating the average rating for each product line 
select 
  product_line, -- selecting the product line 
  avg(rating) as pl_avg_rating -- calculating the average rating and aliasing it as pl_avg_rating
 from 
  amazon
 group by 
  Product_line -- grouping the result by product line
 order by 
  pl_avg_rating desc; -- ordering the result by pl_avg_rating(average rating) in descending order 
 
 -- --------------------------------------------------------------------------
 -- 15.Count the sales occurrences for each time of day on every weekday.
 
 -- selecting the columns dayname,timeofday
 -- and counting the number of Invoice IDs for each day and time of day
 select 
   dayname, -- selecting the day of the week 
   timeofday, -- selecting the time of day 
   count(Invoice_id) as count_of_sale -- counting the number of Invoice IDs and aliasing it as 'count_of_sale'
 from 
   amazon
 where
   dayname not in ('Saturday','Sunday') -- filtering out Saturday and Sunday sales
 group by 
   dayname,timeofday -- grouping the results by day of the week and time of day 
 order by 
   dayname desc,count_of_sale desc; -- ordering the results by day of the week in descending order and count of sale in descending order
 
 -- --------------------------------------------------------------------------
 -- 16.Identify the customer type contributing the highest revenue.
 
 -- selecting the column 'customer type' and calculating the total revenue for each customer type
 select 
   customer_type, -- selecting the customer type
   sum(total) as rev -- calculating the total revenue and aliasing it as rev
 from 
   amazon
 group by 
   Customer_type -- grouping the results by customer type
 order by 
   rev desc -- ordering the results by rev (total revenue) in descending order
 limit 1; -- limiting the results to only the top(highest) revenue
 -- ----------------------------------------------------------------------------
 -- -- -17.Determine the city with the highest VAT percentage.
   
   -- selecting the column city and calculating the vat percentage for each city
   select 
     city, -- selecting the city
     coalesce(sum(vat)/nullif(sum(total),0)*100,null) as vat_percentage
     -- calculating the VAT percentage using sum(VAT) divided by SUM(TOTAL) and multiplying
     -- by 100.Using COALSEC to handle division by zero errors and return NULL in such cases. 
    from 
	 amazon
    group by 
     city -- grouoing the results by city
    order by 
     vat_percentage desc -- ordering the results by VAT percentage in descending order
    limit 1; -- limiting the result to only top(highest) VAT percentage
    -- -------------------------------------------------------------------------
   -- 18.Identify the customer type with the highest VAT payments.
    
    -- selecting the column 'customer type' and calculating the the sum of VAT for each customer type
    select 
      customer_type, -- selecting the customer type
      sum(vat) as vat_p -- calculating the sum of the VAT and aliasing it as vat_p
     from 
	  amazon 
     group by 
	  Customer_type -- grouping the results by customer type 
     order by 
      vat_p desc -- ordering the results by vat_p in descending order
     limit 1; -- limiting the result to only the top(highest) vat_p
     
     -- -----------------------------------------------------------------------
    -- 19.What is the count of distinct customer types in the dataset?
    
    select count(distinct customer_type) as dct
    from amazon;
    
    -- -------------------------------------------------------------------------
    -- 20.What is the count of distinct payment methods in the dataset?
    
    -- selecting the count of distinct payment methods
    select count(distinct payment) as dpa -- counting the number of distinct payment methods and aliasing it as dpa
    from amazon;
    
    -- ----------------------------------------------------------------------------
    -- 21.Which customer type occurs most frequently?
    
    -- selecting the column 'customer type' and counting the number of 'Invoice IDs' for each customer type 
    select 
     customer_type, -- selecting the customer type
     count(Invoice_id) as freq  -- counting the number of 'Invoice IDs' and aliasing it as freq
    from 
	  amazon 
    group by 
      Customer_type -- grouping the results by Customer_type 
    order by 
      freq desc  -- ordering the results by freq(number of Invoice IDs) in descending order   
    limit 1; -- limiting the result to only the top(highest) frequency
    
    -- ----------------------------------------------------------------------------
    -- 22.Identify the customer type with the highest purchase frequency.
    
    -- selecting the column 'customer type'  and counting the number of purchases for each customer type
    select 
      customer_type, -- selecting the customer type
      count(*) as Purchase_frequency -- counting the number of purchases and aliasing it as purchase_freq
     from 
      amazon 
     group by 
      Customer_type -- grouping the results by customer type 
     order by 
      purchase_frequency desc -- ordering the results by purchase_frequnecy(number of purchases) in descending order
     limit 1; -- limiting the result in only the top(highest) purchase frequency
     
     -- ----------------------------------------------------------------------------
     -- 23.Determine the predominant gender among customers.
     
     -- selecting the column gender and counting the number of purchases for each gender 
     select 
       gender, -- selecting the gender
       count(*) as purchase_frequency -- counting the number of purchases and aliasing it as purchase_frequency
      from 
	   amazon 
      group by 
       gender -- grouping the results by gender 
      order by 
	   purchase_frequency desc -- ordering the results by purchase-frequency(number of purchases) in descending order
      limit 1; -- limiting the result to onlt the top(highest) purchase frequency
      
      -- -----------------------------------------------------------------------------
      -- 24.Examine the distribution of genders within each branch.
      
      -- selecting the columns branch,gender,and counting the number of Invoice IDs for each combination
      select 
        branch,-- selecting the branch
        gender, -- selecting the gender 
        count(Invoice_id) as freq_co -- counting the number of Invoice IDs and aliasing it as freq_co
       from 
        amazon 
       group by 
        branch,gender -- grouping the results by branch and gender
       order by 
        branch,freq_co desc; -- ordering the results by branch in ascending order and freq_co in descending order
       
       -- -----------------------------------------------------------------------------
	   -- 25.Identify the time of day when customers provide the most ratings.
       
       -- selecting the column time of day and counting the number of ratings for each time of day
       select 
         timeofday, -- selecting the time of day
         count(rating) as freq -- counting the number of ratings and aliasing it as freq
       from 
         amazon
       group by 
         timeofday -- grouping the results by timeofday
       order by 
         freq desc; -- ordering the results by freq in descending order
       
       -- ------------------------------------------------------------------------------
       -- 26.Determine the time of day with the highest customer ratings for each branch.
       
       -- selecting the columns timeofday,branch, and counting the number of rating for each combination
       select 
         timeofday, -- selecting the timeofday
		 branch,-- selecting the branch
         count(rating) as freq -- counting the number of ratings and aliasing it as freq
       from 
         amazon
       group by 
         timeofday,branch -- grouping the results by timeofday and branch
       order by 
         freq desc; -- ordering the results by freq(number of ratings) in descending order
       
       -- ------------------------------------------------------------------------------ 
       
       -- 27.Identify the day of the week with the highest average ratings.
       
       -- selecting the  column dayname and calculating the average rating for each day
       select 
         dayname, -- selecting the day of the week 
         avg(rating) as Average_Rating -- calculating the average rating and aliasing it as Average_rating 
       from 
         amazon 
       group by 
         dayname -- grouping the results by day of the week 
       order by 
         Average_Rating desc -- Ordering the results by Average_Rating in descending order
       limit 1; -- limiting the result to only the top(highest) average rating
       
       -- ---------------------------------------------------------------------------------
       -- 28.Determine the day of the week with the highest average ratings for each branch.
       
       -- selecting the column brnach,dayname,and calculating the average rating
       select 
         branch, -- selecting the branch
         dayname, -- selecting the dayname 
         avg(rating) as Average_Rating -- calculating the average rating and aliasing it as Average_Rating
       from 
         amazon
       group by 
         Branch,dayname -- Grouping the results by Branch and dayname 
       order by 
         Branch,Average_Rating desc; -- Ordering the results by branch in ascending order and Average_Rating in descending order
       
       
     
     
     
   
 





