# most popular days
select order_day_of_week as Day_of_the_week, count(distinct transaction_id) as Count_of_orders
from transactions
group by order_day_of_week
order by count(distinct transaction_id) desc;

#most popular hours
select order_hour_of_day as Hour_of_day, count(distinct transaction_id) as Count_of_orders
from transactions
group by order_hour_of_day
order by count(distinct transaction_id) desc;

# top 15 most sold products
select product_name, count(distinct transaction_id) as Count_of_orders
from transactions as t
inner join products as p on t.product_id = p.product_id
group by product_name
order by count(transaction_id) desc
limit 15
;

# top 15 most reordered products
select product_name, sum(reordered) as Most_reordered
from transactions as t
inner join products as p on t.product_id = p.product_id
group by product_name
order by sum(reordered) desc
limit 15
;

# nr products to cart
select transaction_id, count(product_id) as Count_to_cart
from transactions
group by transaction_id
order by count(product_id) desc;

# min, avg and max nr of prod to cart
select min(prod_count) as Min_to_cart, round(avg(prod_count)) as Average_to_cart, max(prod_count) as Max_to_cart  
from
	(select transaction_id, count(product_id) as Prod_count
    from transactions
    group by transaction_id) as Count_to_cart
     ;

# peak hours during which customers tend to add more items to their carts     
select order_hour_of_day, count(product_id) as Count_to_cart
from transactions
group by order_hour_of_day
order by count(product_id) desc
;     

#percent of reordered vs not reordered
select 
	   round(((count(case when reordered = 1 then 1 end))/(select count(reordered) from transactions))*100) as percent_reordered,
       round(((count(case when reordered = 0 then 1 end))/(select count(reordered) from transactions))*100) as percent_not_reordered
from transactions;    

# reordered vs not reordered by depatment   
select department_name, count(case when reordered = 1 then 1 end) as Reordered, count(case when reordered = 0 then 0 end) as Not_reordered
from transactions as t
inner join products as p on t.product_id = p.product_id 
group by department_name
order by reordered desc
;   
  
#customer analysis
# nr of customer by gender, age amd income
select count(*) as Total_customers, count(case when genre = 'Female' then 1 end) as Female, count(case when genre = 'Male' then 1 end) as Male, 
	   sum(if(age<20,1,0)) as 'Under 20', sum(if(age between 20 and 29,1,0)) as '20-29', sum(if(age between 30 and 39,1,0)) as '30-39', sum(if(age between 40 and 49,1,0)) as '40-49', 
       sum(if(age between 50 and 59,1,0)) as '50-59', sum(if(age between 60 and 69,1,0)) as '60-69', sum(if(age between 70 and 79,1,0)) as '70-79', sum(if(age > 80,1,0)) as 'Over 80', 
       sum(if(age is null,1,0)) as 'Age not filled in', 
       sum(if(annual_income < 20,1,0)) as 'Under 20K', sum(if(annual_income between 20 and 49,1,0)) as '20-49K', sum(if(annual_income between 50 and 79,1,0)) as '50-79K', 
       sum(if(annual_income between 80 and 109,1,0)) as '80-109K', sum(if(annual_income > 110,1,0)) as 'Over 110K', sum(if(annual_income is null,1,0)) as 'Annual income not filled in',
       sum(if(spending_score <= 20,1,0)) as 'Very low', sum(if(spending_score between 21 and 40,1,0)) as 'Low', sum(if(spending_score between 41 and 60,1,0)) as 'Medium', 
       sum(if(spending_score between 61 and 80,1,0)) as 'High', sum(if(spending_score > 81,1,0)) as 'Very high', sum(if(spending_score is null,1,0)) as 'Spending score not filled in'
from customers;         

#Number of orders by customers
select t.customer_id, genre, age, count(distinct transaction_id) as Count_of_orders          
from transactions as t
inner join customers as c on t.customer_id = c.customer_id
group by customer_id
order by count(distinct transaction_id) desc
#limit 10    
;

# number of customers that placed one order
select count(customer_number) as ordered_once
from 
			(select customer_id as customer_number  
			from transactions 
			group by customer_id  
			having count(distinct order_number) = 1) as order_count
;     

# profile of customers who placed 3 or more orders         
select t.customer_id, genre, age, annual_income, spending_score, count(distinct order_number)           
from transactions as t
left join customers as c on t.customer_id = c.customer_id
group by t.customer_id
having count(distinct order_number) >= 3
order by count(distinct order_number) desc
;

# products ordered by the most frequent customers
select customer_id, product_name, count(t.product_id)
from transactions as t
left join products as p on t.product_id = p.product_id
group by customer_id, product_name
having customer_id = 1 or customer_id = 1728
order by count(product_id) desc;

# who buys more fruit and veg - men vs women                                         
select product_name, count(case when genre = 'Female' then 1 end) as Female, count(case when genre = 'Male' then 1 end) as Male
from customers as c
right join transactions as t on c.customer_id = t.customer_id
left join products as p on t.product_id = p.product_id
group by product_name
having product_name like '%fruit%' or product_name like '%veg%'
order by Female desc
;

# who buys more meat and alcohol - men vs women 
select department_name, count(case when genre = 'Female' then 1 end) as Female, count(case when genre = 'Male' then 1 end) as Male
from customers as c
right join transactions as t on c.customer_id = t.customer_id
left join products as p on t.product_id = p.product_id
group by department_name
having department_name like '%meat%' or department_name like '%alc%'
order by Female desc
;