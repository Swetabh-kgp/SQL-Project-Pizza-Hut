---- Created Database Pizza_Sales ----

---- DATABASE Pizza_Sales ----

-- Create Table Pizzas ----

DROP TABLE IF EXISTS Pizzas;

CREATE TABLE Pizzas(
	   pizza_id VARCHAR(30) NOT NULL,
	   pizza_type_id VARCHAR(30) NOT NULL,
	   size CHAR(10),
	   price DECIMAL(5,2)
);

SELECT * FROM Pizzas;

---- Create table Pizza Type ----

DROP TABLE IF EXISTS Pizza_types;

CREATE TABLE Pizza_types(
	   pizza_type_id VARCHAR(30) NOT NULL,
	   name VARCHAR(100),
	   category VARCHAR(20),
	   ingredients VARCHAR(250)
);

SELECT * FROM Pizza_types;

---- Create table Orders ----

DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders(
	   order_id INT PRIMARY KEY,
	   order_date DATE NOT NULL,
	   order_time TIME NOT NULL
);

SELECT * FROM Orders;

---- Create Table ----

DROP TABLE IF EXISTS order_details;

CREATE TABLE order_details(
	   order_details_id INT PRIMARY KEY,
	   order_id INT NOT NULL,
	   pizza_id VARCHAR(30) NOT NULL,
	   quantity INT NOT NULL
);

SELECT * FROM order_details;

SELECT * FROM Pizzas;

SELECT * FROM Pizza_types;

SELECT * FROM Orders;


----Basic:

-- Q 1. Retrieve the total number of orders placed.
-- ANS 

SELECT COUNT(order_id) AS Total_orders 
FROM orders;


-- Q 2. Calculate the total revenue generated from pizza sales.
-- ANS 

SELECT ROUND(SUM(order_details.quantity*pizzas.price),2) AS Total_Sales 
FROM order_details JOIN pizzas
ON order_details.pizza_id=pizzas.pizza_id;


-- Q 3. Identify the highest-priced pizza.
-- ANS 

SELECT pizza_types.name, pizzas.price 
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Q 4. Identify the most common pizza size ordered.
-- ANS 

SELECT pizzas.size, Count(Order_details.order_details_id) AS Most_ordered_pizza
FROM pizzas JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Count(order_details.order_details_id) DESC
LIMIT 5;


-- Q 5. List the top 5 most ordered pizza types along with their quantities.
-- ANS

SELECT pizza_types.name, SUM(order_details.quantity) AS Most_ordered_pizza
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;


----Intermediate :


-- Q 1. Join the necessary tables to find the total quantity of each pizza category ordered.
-- ANS 

SELECT pizza_types.category, SUM(order_details.quantity) AS Most_ordered_pizza
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC;


-- Q 2. Determine the distribution of orders by hour of the day
-- ANS 

SELECT EXTRACT(Hour FROM order_time) AS Hour, Count(order_id) AS Order_Count FROM Orders
GROUP BY EXTRACT(Hour FROM order_time);


-- Q 3. Join relevant tables to find the category-wise distribution of pizzas.
-- ANS 

SELECT category, Count(name) FROM pizza_types
GROUP BY category;


-- Q 4. Group the orders by date and calculate the average number of pizzas ordered per day.
-- ANS 

SELECT Round(AVG(quantity),0) AS Avg_pizza_ordered_per_day FROM
(SELECT orders.order_date, SUM(order_details.quantity) AS quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity;


-- Q 5. Determine the top 3 most ordered pizza types based on revenue.
-- ANS 

SELECT pizza_types.name, ROUND(SUM(order_details.quantity*pizzas.price),2) AS Revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY ROUND(SUM(order_details.quantity*pizzas.price),2) DESC
LIMIT 3;


----Advanced:


-- Q 1. Calculate the percentage contribution of each pizza type to total revenue.
-- ANS 

SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) * 100 /
        (
            SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2)
            FROM order_details
            JOIN pizzas
                ON pizzas.pizza_id = order_details.pizza_id
        ),
    2) AS revenue
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Q 2. Analyze the cumulative revenue generated over time.
-- ANS 

SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT orders.order_date, SUM(order_details.quantity*pizzas.price) AS revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id=pizzas.pizza_id
JOIN orders
ON orders.order_id=order_details.order_id
GROUP BY orders.order_date) AS sales;


-- Q 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- ANS 

SELECT category, name, revenue FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rank
FROM 
(SELECT pizza_types.category, pizza_types.name, 
SUM(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rank <=3;

