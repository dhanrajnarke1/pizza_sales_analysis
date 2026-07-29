-- Retrive total numbers of orders placed
SELECT COUNT(order_id) as Total_orders FROM orders1;

--Calculate total revenue generated from pizza sales
SELECT SUM(quantity*price) as revenue FROM order_details o JOIN pizzas p ON o.pizza_id=p.pizza_id ; 

--identify highest priced pizza
SELECT name,price FROM pizzas p JOIN pizza_types t On p.pizza_type_id=t.pizza_type_id order by price  DESC limit 1;

--identify most common pizza size ordered
select pizzas.size,count(order_details.order_details_id) as order_count from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id group by pizzas.size order by order_count desc; 

--list top 5 most ordered pizzatypes along with their quantities
select pizza_types.name as name,SUM(order_details.quantity) as quantity
 from pizza_types   join pizzas  ON pizza_types.pizza_type_id=pizzas.pizza_type_id 
 join order_details on order_details.pizza_id=pizzas.pizza_id  group by name order by quantity DESC limit 5;

--Category wise quantity
SELECT pizza_types.category,sum(order_details.quantity) as total_quantity
FROM pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id 
JOIN order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category ORDER BY total_quantity desc;

--orders by hour
SELECT extract(hour from time) as hour ,count(order_id) as total_orders  FROM orders1  GROUP BY hour order by hour aSC; 

--category wise pizza distribution
SELECT category,count(name) as count FROM pizza_types group by category order by count DESC ;

--group orders by date and calculate avg no of pizzas per day   + 
SELECT round(avg(total_quantity),0) from (SELECT orders1.date as day,sum(order_details.quantity) as total_quantity  from orders1
 join order_details on order_details.order_id=orders1.order_id
 group by day order by total_quantity DESC) as order_quantity;

 --3 most ordered pizza types based on revenue
 SELECT pizza_types.name as name,sum(order_details.quantity*pizzas.price) as revenue from pizza_types
  join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id 
  join order_details on order_details.pizza_id=pizzas.pizza_id 
  group by name order by revenue DESC limit 3;

--percentage contribution of each pizza type to total revenue
SELECT pt.category AS category,
ROUND((SUM(od.quantity * p.price) /
            (
                SELECT SUM(od2.quantity * p2.price)
                FROM order_details od2
                JOIN pizzas p2 
                    ON p2.pizza_id = od2.pizza_id
            )
        )::numeric * 100,2
) AS revenue_percentage
FROM pizza_types pt JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category ORDER BY revenue_percentage DESC;

--cumulative revenue generated over time

SELECT 
date,sum(revenue) over(order by date) as cum_revenue from (SELECT orders1.date as date,sum(order_details.quantity*pizzas.price) as revenue 
from order_details
join pizzas 
on order_details.pizza_id=pizzas.pizza_id
join orders1 on orders1.order_id=order_details.order_id GROUP BY date ORDER BY revenue DESC)  ;

--top 3 most ordered pizza types based on revenue for each pizza category 

SELECT category,name,revenue, RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as rn from 
(SELECT pizza_types.category as category,pizza_types.name as name,sum(order_details.quantity*pizzas.price) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id 
join order_details on order_details.pizza_id=pizzas.pizza_id group by category,name) as a;

--Monthwise revenue 
SELECT extract(month from orders1.date) as month,sum(order_details.quantity*pizzas.price) as revenue from orders1
JOIN order_details ON orders1.order_id=order_details.order_id
JOIN pizzas on order_details.pizza_id=pizzas.pizza_id group by month ORDER BY revenue desc ;

------------------------------------------------
--              INSIGHTS 
------------------------------------------------
--1)TOTAL ORDERS : 21350
--2)TOTAL REVENUE : 817860
--3)MOST ORDERED SIZE : L
--4)MOST ORDERED PIZZA name : CLASSIC DELUXE PIZZA
--5)MOST ORDERED CATEGORY : CLASSIC
--6)ORDERS INCREASES IN AFTERNOON & EVENING
--7)PEAK MONTH : AUGUST
--8)CATEGORY WITH HIGH CONTRIBUTION IN REVENUE : CLASSIC 
