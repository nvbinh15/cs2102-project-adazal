\i ../drop.sql
\i ../schema.sql
\i ../proc.sql

/*
    PROCEDURE (1)
    place_order( 
        user_id INTEGER, _coupon_id INTEGER, shipping_address TEXT, 
        shop_ids INTEGER[], product_ids INTEGER[], sell_timestamps TIMESTAMP[], 
        quantities INTEGER[], shipping_costs NUMERIC[]
    )
*/

BEGIN;
insert into shop (id, name) 
    values (1, 'Quigley-Grant');
insert into category (id, name, parent) 
    values (1, 'Marlite Panels (FED)', null);
insert into manufacturer (id, name, country) 
    values (1, 'Bogan Inc', 'Iran');
insert into product (id, name, description, category, manufacturer) 
    values (1, 'Vinegar - Rice', 'Other fracture of upper end of right tibia, sequela', 1, 1);
insert into product (id, name, description, category, manufacturer) 
    values (2, 'Wine - White, Schroder And Schyl', 'Contact w agri transport vehicle in stationary use, init', 1, 1);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) 
    values (1, 1, '2021-04-12 13:40:58', 50, 78);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) 
    values (1, 2, '2021-10-07 20:37:57', 150, 39);
insert into users (id, address, name, account_closed) 
    values (1, '6918 Esch Circle', 'Derrik Melmoth', false);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) 
    values (1, '9/24/2021', '9/29/2021', 40, 90);
insert into issued_coupon (user_id, coupon_id) 
    values (1, 1);
COMMIT;

-- Test 1
-- Expected: Order added successfully, 
-- payment amount computed correctly,
-- quantity in Sells updated accordingly
CALL place_order(
    1, 1, 'NUS PGPR', 
    '{1, 1}', '{1, 2}', '{"2021-04-12 13:40:58", "2021-10-07 20:37:57"}',
    '{3, 1}', '{10, 20}'
);
SELECT * FROM Orders;
SELECT *
FROM Orderline O JOIN Sells S
ON ROW(O.shop_id, O.product_id, O.sell_timestamp) = ROW(S.shop_id, S.product_id, S.sell_timestamp)
WHERE O.order_id = (
    SELECT MAX(id)
    FROM Orders
);
