select * from olist_customers_dataset;
select * from olist_order_items_dataset;
select * from olist_order_payments_dataset;
select * from olist_order_reviews_dataset;
select * from olist_orders_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * from product_category_name_translation;


update olist_order_items_dataset set shipping_limit_date = substring_index(shipping_limit_date,' ',1);
update olist_order_reviews_dataset set review_creation_date= substring_index(review_creation_date,' ',1);
update olist_order_reviews_dataset set review_answer_timestamp= substring_index(review_answer_timestamp,' ',1);
alter table product_category_name_translation rename column ï»¿product_category_name to product_category_name;
update olist_order_items_dataset set shipping_limit_date=str_to_date(shipping_limit_date,"%d-%m-%Y");
update olist_order_reviews_dataset set review_creation_date=str_to_date(review_creation_date,"%d-%m-%Y");
update olist_order_reviews_dataset set review_answer_timestamp=str_to_date(review_answer_timestamp,"%d-%m-%Y");
update olist_orders_dataset set order_purchase_timestamp =str_to_date(order_purchase_timestamp ,"%d-%m-%Y");
update olist_orders_dataset set order_approved_at =str_to_date(order_approved_at,"%d-%m-%Y");
update olist_orders_dataset set order_delivered_carrier_date =str_to_date(order_delivered_carrier_date,"%d-%m-%Y");
update olist_orders_dataset set order_delivered_customer_date  =str_to_date(order_delivered_customer_date,"%d-%m-%Y");
update olist_orders_dataset set order_estimated_delivery_date =str_to_date(order_estimated_delivery_date,"%d-%m-%Y");

-- 1st KPI
select * from olist_orders_dataset;
select weekday(order_purchase_timestamp) from olist_orders_dataset;

with main as (
select *, weekday(order_purchase_timestamp) ,
case when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "weekday" end as weekend_or_weekday 
from olist_orders_dataset)

select weekend_or_weekday,(count(weekend_or_weekday)/(select count(*) from olist_orders_dataset))*100 as percentage from main
group by 1;

-- KPI 2 Number of Orders with review score 5 and payment type as credit card.

select r.review_score,op.payment_type,count(o.order_id)
from
olist_order_payments_dataset as op
join olist_order_reviews_dataset as r
on op.order_id=r.order_id
join olist_orders_dataset as o
on op.order_id=o.order_id
where r.review_score=5 and op.payment_type="Credit_card";
-- group by 1,2;

-- KPI 3 Average no_of_days taken for order_delivered_customers_date for pet store

select * from olist_products_dataset;
select * from olist_orders_dataset;

select p.product_category_name,
round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp)),0) as avg_days_to_get_delivered
from olist_orders_dataset as o
join olist_order_items_dataset as oi
on oi.order_id=o.order_id
join olist_products_dataset as p
on oi.product_id=p.product_id
where p.product_category_name="Pet_shop";

-- KPI 4 Average price and payment values from customers of sao paulo city

select c.customer_city,round(avg(oi.price),0) as avg_price,round(avg(p.payment_value),0) as avg_payment
from olist_customers_dataset as c
join olist_orders_dataset as o
on o.customer_id=c.customer_id
join olist_order_items_dataset as oi
on o.order_id=oi.order_id
join olist_order_payments_dataset as p
on oi.order_id=p.order_id
where c.customer_city='sao paulo';


-- KPI 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select r.review_score ,round(avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)),0) as avg_days
from olist_order_reviews_dataset as r
join olist_orders_dataset as o
on o.order_id=r.order_id
group by 1
order by 1 ; 
