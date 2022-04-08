\i mai.sql;
-- 1(11)
BEGIN TRANSACTION;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (11, 9, 10, 14, '2021-04-12 13:40:58');
-- insert into shop_complaint(id, shop_id) values (11, 10);

COMMIT;