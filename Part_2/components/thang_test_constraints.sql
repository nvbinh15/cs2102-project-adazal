\i ../drop.sql
\i ../schema.sql
\i ../proc.sql

/*
    TRIGGER (1)
    Each shop should sell at least one product.
*/

-- Test 1
-- Expected: Insert successfully
BEGIN;
insert into shop (id, name) 
    values (1, 'Quigley-Grant');
insert into category (id, name, parent) 
    values (1, 'Marlite Panels (FED)', null);
insert into manufacturer (id, name, country) 
    values (1, 'Bogan Inc', 'Iran');
insert into product (id, name, description, category, manufacturer) 
    values (1, 'Vinegar - Rice', 'Other fracture of upper end of right tibia, sequela', 1, 1);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) 
    values (1, 1, '2021-04-12 13:40:58', 50, 78);
COMMIT;

-- Test 2
-- Expected: Rollback
BEGIN;
insert into shop (id, name) 
    values (2, 'Quigley-Grant 2');
insert into category (id, name, parent) 
    values (2, 'Marlite Panels 2 (FED)', null);
insert into manufacturer (id, name, country) 
    values (2, 'Bogan Inc 2', 'Vietnam');
COMMIT;

/*
    TRIGGER (2)
    An order must involve one or more products from one or more shops.
*/

-- Test 1
-- Expected: Insert successfully
BEGIN;
insert into users (id, address, name, account_closed) 
    values (1, '6918 Esch Circle', 'Derrik Melmoth', false);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) 
    values (1, '9/24/2021', '9/29/2021', 40, 90);
insert into issued_coupon (user_id, coupon_id) 
    values (1, 1);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) 
    values (1, 1, 1, '6918 Esch Circle', 70);
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) 
    values (1, 1, 1, '2021-04-12 13:40:58', 2, 10, 'being_processed', NULL);
COMMIT;

-- Test 2
-- Expected: Rollback
BEGIN;
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) 
    values (2, '9/24/2021', '9/29/2021', 30, 70);
insert into issued_coupon (user_id, coupon_id) 
    values (1, 2);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) 
    values (2, 1, 2, '123 Esch Square', 100);
COMMIT;

/*
    TRIGGER (3)
    A coupon can only be used on an order whose total amount (before the coupon is applied) exceeds 
    the minimum order amount.
*/

-- Test 1
-- Expected: Insert successfully 
-- (already tested at trigger 3 - test 1)

-- Test 2
-- Expected: Rollback
BEGIN;
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) 
    values (3, '9/24/2021', '9/29/2021', 40, 120);
insert into issued_coupon (user_id, coupon_id) 
    values (1, 3);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) 
    values (3, 1, 3, '6918 Esch Circle', 110);
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) 
    values (3, 1, 1, '2021-04-12 13:40:58', 2, 50, 'being_processed', NULL);
COMMIT;
