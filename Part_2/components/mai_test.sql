\i drop.sql;
\i schema.sql;
\i components/mai.sql;

-- truncate table users;
-- truncate table shop;
-- truncate table category;
-- truncate table manufacturer;
-- truncate table product;
-- truncate table sells;

--USERS
insert into users (id, address, name, account_closed) values (1, '6918 Esch Circle', 'Derrik Melmoth', false);
insert into users (id, address, name, account_closed) values (2, '8 Mcbride Place', 'Deina Coultard', true);
insert into users (id, address, name, account_closed) values (3, '90 Pine View Drive', 'Innis Alliberton', true);
insert into users (id, address, name, account_closed) values (4, '337 Paget Lane', 'Magdaia Yeatman', true);
insert into users (id, address, name, account_closed) values (5, '1323 Summerview Terrace', 'Jerry Penhaligon', false);
insert into users (id, address, name, account_closed) values (6, '5 Westerfield Lane', 'Ermina McAnalley', false);
insert into users (id, address, name, account_closed) values (7, '774 Hovde Crossing', 'Karl Ellissen', false);
insert into users (id, address, name, account_closed) values (8, '9 Dayton Court', 'Willy Brecher', false);
insert into users (id, address, name, account_closed) values (9, '9 Dawn Pass', 'Darnall Scutter', false);
insert into users (id, address, name, account_closed) values (10, '42 Northview Lane', 'Burk Kilmaster', false);


-- -- SHOP
insert into shop (id, name) values (1, 'Quigley-Grant');
insert into shop (id, name) values (2, 'Roob-Sawayn');
insert into shop (id, name) values (3, 'Thiel LLC');
insert into shop (id, name) values (4, 'O''Keefe-Windler');
insert into shop (id, name) values (5, 'Yundt, Tremblay and Jerde');
insert into shop (id, name) values (6, 'Koepp-Turner');
insert into shop (id, name) values (7, 'Konopelski Group');
insert into shop (id, name) values (8, 'Rutherford and Sons');
insert into shop (id, name) values (9, 'Bechtelar, Streich and Moore');
insert into shop (id, name) values (10, 'Stracke, Balistreri and MacGyver');

-- -- category
insert into category (id, name, parent) values (1, 'Marlite Panels (FED)', null);
insert into category (id, name, parent) values (2, 'Curb & Gutter', 1);
insert into category (id, name, parent) values (3, 'HVAC', null);
insert into category (id, name, parent) values (4, 'Elevator', 3);
insert into category (id, name, parent) values (5, 'Construction Clean and Final Clean', 4);

-- -- manufacturer
insert into manufacturer (id, name, country) values (1, 'Bogan Inc', 'Iran');
insert into manufacturer (id, name, country) values (2, 'Hermiston-Pfeffer', 'Mauritius');
insert into manufacturer (id, name, country) values (3, 'Adams-Crist', 'Indonesia');
insert into manufacturer (id, name, country) values (4, 'Fay, Orn and Schamberger', 'Pakistan');
insert into manufacturer (id, name, country) values (5, 'Gerhold-Thiel', 'China');

-- -- product
insert into product (id, name, description, category, manufacturer) values (1, 'Vinegar - Rice', 'Other fracture of upper end of right tibia, sequela', 3, 1);
insert into product (id, name, description, category, manufacturer) values (2, 'Wine - White, Schroder And Schyl', 'Contact w agri transport vehicle in stationary use, init', 3, 4);
insert into product (id, name, description, category, manufacturer) values (3, 'Cheese - Marble', 'Other secondary chronic gout, left hip', 2, 1);
insert into product (id, name, description, category, manufacturer) values (4, 'Pork Ham Prager', 'Unsp mtrcy rider inj in nonclsn trnsp acc nontraf, sequela', 5, 3);
insert into product (id, name, description, category, manufacturer) values (5, 'Basil - Primerba, Paste', 'Corrosion of second degree of right ear, subs encntr', 5, 1);
insert into product (id, name, description, category, manufacturer) values (6, 'Table Cloth 81x81 Colour', 'Localized vascularization of cornea, right eye', 3, 4);
insert into product (id, name, description, category, manufacturer) values (7, 'Lettuce - Spring Mix', 'Preterm labor third tri w preterm del third tri, fetus 2', 4, 5);
insert into product (id, name, description, category, manufacturer) values (8, 'Filo Dough', 'Contact with nonvenomous frogs, initial encounter', 4, 5);
insert into product (id, name, description, category, manufacturer) values (9, 'Island Oasis - Mango Daiquiri', 'External constriction, right lesser toe(s)', 4, 4);
insert into product (id, name, description, category, manufacturer) values (10, 'Wine - Gewurztraminer Pierre', 'Toxic effect of ingested berries, undetermined, sequela', 3, 2);
insert into product (id, name, description, category, manufacturer) values (11, 'Beef - Baby, Liver', 'Strain of flexor musc/fasc/tend l thm at forarm lv, init', 1, 4);
insert into product (id, name, description, category, manufacturer) values (12, 'Pear - Halves', 'Influenza due to oth ident influenza virus w myocarditis', 3, 5);
insert into product (id, name, description, category, manufacturer) values (13, 'Quail - Whole, Boneless', 'Displ bimalleol fx unsp low leg, 7thH', 3, 5);
insert into product (id, name, description, category, manufacturer) values (14, 'Cherries - Fresh', 'Other fracture of unspecified ilium', 5, 5);
insert into product (id, name, description, category, manufacturer) values (15, 'Pur Value', 'Disp fx of base of 4th MC bone, r hand, 7thD', 4, 3);
insert into product (id, name, description, category, manufacturer) values (16, 'Wonton Wrappers', 'Unsp retained (old) intraocular fb, magnetic, left eye', 1, 4);
insert into product (id, name, description, category, manufacturer) values (17, 'Mix - Cappucino Cocktail', 'War op w chemical weapons and oth unconvtl warfare, civilian', 1, 5);
insert into product (id, name, description, category, manufacturer) values (18, 'Aromat Spice / Seasoning', 'Tibial collateral bursitis [Pellegrini-Stieda]', 1, 4);
insert into product (id, name, description, category, manufacturer) values (19, 'Wine - Red, Gamay Noir', 'Occup of special agricultural vehicle injured nontraf, subs', 2, 5);
insert into product (id, name, description, category, manufacturer) values (20, 'Salsify, Organic', 'Anterior dislocation of unsp ulnohumeral joint, init encntr', 1, 2);

-- -- sells
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (10, 14, '2021-04-12 13:40:58', 43, 78);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (8, 11, '2021-10-07 20:37:57', 180, 39);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (3, 3, '2022-01-17 03:29:03', 769, 34);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (10, 3, '2021-11-17 10:04:13', 116, 27);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (10, 19, '2022-02-25 14:48:35', 521, 30);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (6, 6, '2021-04-06 20:43:27', 971, 21);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (2, 17, '2022-03-16 22:13:20', 646, 83);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (1, 9, '2021-05-23 23:09:20', 818, 83);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (5, 6, '2021-12-01 04:25:38', 114, 20);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (7, 11, '2021-11-15 18:28:53', 115, 7);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (7, 6, '2021-04-05 11:14:02', 234, 86);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (6, 1, '2021-12-03 14:45:57', 842, 82);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (1, 9, '2022-01-29 19:31:07', 540, 89);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (9, 4, '2021-11-07 16:09:20', 558, 86);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (3, 7, '2022-02-11 10:47:47', 557, 80);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (4, 20, '2021-08-07 09:23:34', 839, 39);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (2, 18, '2021-10-01 03:57:07', 722, 40);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (10, 4, '2021-04-20 17:30:40', 721, 34);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (10, 14, '2021-12-16 14:25:24', 367, 32);
insert into sells (shop_id, product_id, sell_timestamp, price, quantity) values (6, 18, '2021-10-26 14:50:06', 420, 39);

-- coupon_batch
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) values (1, '9/24/2021', '9/29/2021', 44, 90);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) values (2, '5/11/2021', '2/6/2022', 26, 80);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) values (3, '6/1/2021', '2/27/2022', 7, 55);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) values (4, '6/3/2021', '1/3/2022', 23, 95);
insert into coupon_batch (id, valid_period_start, valid_period_end, reward_amount, min_order_amount) values (5, '6/3/2021', '1/21/2022', 2, 64);

-- issued_coupon
insert into issued_coupon (user_id, coupon_id) values (4, 2);
insert into issued_coupon (user_id, coupon_id) values (3, 3);
insert into issued_coupon (user_id, coupon_id) values (9, 1);
insert into issued_coupon (user_id, coupon_id) values (7, 3);
insert into issued_coupon (user_id, coupon_id) values (3, 5);
insert into issued_coupon (user_id, coupon_id) values (4, 4);


-- orders
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (1, 4, 2, '67 Lien Terrace', 10);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (2, 1, null, '30 Moland Avenue', 22);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (3, 2, null, '0 School Park', 31);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (4, 3, 3, '4 Bunting Park', 75);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (5, 7, null, '99008 Darwin Circle', 18);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (6, 6, null, '005 Roth Center', 4);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (7, 10, null, '39070 Hanover Road', 14);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (8, 8, null, '41 Kedzie Place', 25);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (9, 7, 3, '15 Mitchell Parkway', 28);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (10, 9, 1, '32 Cody Drive', 42);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (11, 3, 5, '446 Bashford Junction', 72);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (12, 2, null, '580 Ramsey Street', 50);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (13, 8, null, '97146 Florence Way', 27);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (14, 2, null, '6099 Northview Lane', 84);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (15, 8, null, '26 Brickson Park Circle', 14);
insert into orders (id, user_id , coupon_id, shipping_address, payment_amount) values (16, 10, null, '8 Schlimgen Drive', 16);

-- orderline
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (9, 10, 14, '2021-04-12 13:40:58', 96, 56, 'shipped', '12/17/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (15, 8, 11, '2021-10-07 20:37:57', 83, 48, 'delivered', '5/28/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (3, 3, 3, '2022-01-17 03:29:03', 93, 27, 'shipped', '5/11/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (9, 10, 3, '2021-11-17 10:04:13', 18, 31, 'shipped', '3/8/2022');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (9, 10, 19, '2022-02-25 14:48:35', 15, 23, 'shipped', '8/30/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (4, 6, 6, '2021-04-06 20:43:27', 94, 62, 'delivered', '11/18/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (6, 2, 17, '2022-03-16 22:13:20', 25, 21, 'being_processed', null);
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (14, 1, 9, '2021-05-23 23:09:20', 36, 77, 'being_processed', null);
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (2, 5, 6, '2021-12-01 04:25:38', 39, 61, 'shipped', '6/11/2021');
insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (6, 7, 11, '2021-11-15 18:28:53', 42, 27, 'delivered', '1/21/2022');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (8, 5, 1, '9/1/2021', 97, 4, 'Lotlux', '12/21/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (2, 7, 13, '12/17/2021', 3, 33, 'Veribet', '9/30/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (5, 8, 8, '2/20/2022', 4, 29, 'Lotstring', '2/2/2022');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (10, 7, 6, '2/25/2022', 39, 51, 'Zoolab', '8/21/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (15, 4, 20, '6/17/2021', 88, 38, 'Trippledex', '11/6/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (4, 4, 17, '11/3/2021', 85, 14, 'Zoolab', '1/23/2022');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (15, 5, 8, '11/5/2021', 41, 88, 'Matsoft', '4/4/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (10, 8, 8, '7/8/2021', 2, 52, 'Tin', '6/28/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (13, 9, 6, '7/19/2021', 7, 68, 'Tres-Zap', '10/4/2021');
-- insert into orderline (order_id, shop_id, product_id, sell_timestamp, quantity, shipping_cost, status, delivery_date) values (8, 5, 8, '11/24/2021', 33, 58, 'Treeflex', '12/1/2021');

-- comment
insert into comment (id, user_id ) values (7, 7);
insert into comment (id, user_id ) values (9, 9);
insert into comment (id, user_id ) values (10, 2);
insert into comment (id, user_id ) values (4, 2);
insert into comment (id, user_id ) values (3, 7);
insert into comment (id, user_id ) values (5, 4);
insert into comment (id, user_id ) values (8, 2);
insert into comment (id, user_id ) values (2, 4);
insert into comment (id, user_id ) values (6, 10);
insert into comment (id, user_id ) values (1, 2);

--review
insert into review (id, order_id, shop_id , product_id, sell_timestamp) values (5, 9, 10, 14, '2021-04-12 13:40:58');
insert into review (id, order_id, shop_id , product_id, sell_timestamp) values (3, 3, 3, 3, '2022-01-17 03:29:03');
insert into review (id, order_id, shop_id , product_id, sell_timestamp) values (1, 9, 10, 3, '2021-11-17 10:04:13');
insert into review (id, order_id, shop_id , product_id, sell_timestamp) values (2, 4, 6, 6, '2021-04-06 20:43:27');
insert into review (id, order_id, shop_id , product_id, sell_timestamp) values (6, 14, 1, 9, '2021-05-23 23:09:20');

-- review_version
insert into review_version (review_id, review_timestamp, content, rating) values (5, '2021-04-12 13:40:58', 'Biliary acute pancreatitis with uninfected necrosis', 1);
insert into review_version (review_id, review_timestamp, content, rating) values (2, '2021-04-06 20:43:27', 'Toxic effect of tobacco and nicotine, accidental, subs', 3);
insert into review_version (review_id, review_timestamp, content, rating) values (2, '2021-01-01 20:43:27', 'Major laceration of unsp internal jugular vein, subs encntr', 2);
insert into review_version (review_id, review_timestamp, content, rating) values (1, '2021-11-17 10:04:13', 'Unsp fracture of lower end of unsp humerus, init for clos fx', 3);
insert into review_version (review_id, review_timestamp, content, rating) values (6, '2021-05-23 23:09:20', 'Quad preg, unsp num plcnta & amnio sacs, third trimester', 1);
insert into review_version (review_id, review_timestamp, content, rating) values (3, '2022-01-17 03:29:03', 'Legal intervention involving unspecified gas', 1);
insert into review_version (review_id, review_timestamp, content, rating) values (2, '2021-01-02 20:43:27', 'Loose body in knee, left knee', 2);


-- reply
insert into reply (id, other_comment_id) values (4, 1);
insert into reply (id, other_comment_id) values (7, 4);
insert into reply (id, other_comment_id) values (8, 2);
insert into reply (id, other_comment_id) values (9, 4);
insert into reply (id, other_comment_id) values (10, 5);

-- reply_version
insert into reply_version (reply_id, reply_timestamp, content) values (4, '2021-04-12 13:40:58', 'Biliary acute pancreatitis with uninfected necrosis');
insert into reply_version (reply_id, reply_timestamp, content) values (7, '2021-04-06 20:43:27', 'Toxic effect of tobacco and nicotine, accidental, subs');
insert into reply_version (reply_id, reply_timestamp, content) values (4, '2021-01-01 20:43:27', 'Major laceration of unsp internal jugular vein, subs encntr');
insert into reply_version (reply_id, reply_timestamp, content) values (8, '2021-11-17 10:04:13', 'Unsp fracture of lower end of unsp humerus, init for clos fx');
insert into reply_version (reply_id, reply_timestamp, content) values (9, '2021-05-23 23:09:20', 'Quad preg, unsp num plcnta & amnio sacs, third trimester');
insert into reply_version (reply_id, reply_timestamp, content) values (10, '2022-01-17 03:29:03', 'Legal intervention involving unspecified gas');
insert into reply_version (reply_id, reply_timestamp, content) values (4, '2021-01-02 20:43:27', 'Loose body in knee, left knee');

-- employee
insert into employee (id, name, salary) values (1, 'Emmalynne Haslewood', 851);
insert into employee (id, name, salary) values (2, 'Marlo Eddowes', 233);
insert into employee (id, name, salary) values (3, 'Deeanne Jeannot', 315);
insert into employee (id, name, salary) values (4, 'Stacee Zylberdik', 139);
insert into employee (id, name, salary) values (5, 'Ward Guirau', 224);
insert into employee (id, name, salary) values (6, 'Broddie Thominga', 488);
insert into employee (id, name, salary) values (7, 'Lucias Warricker', 372);
insert into employee (id, name, salary) values (8, 'Fanya Ferrers', 124);
insert into employee (id, name, salary) values (9, 'Georgie Demageard', 798);
insert into employee (id, name, salary) values (10, 'Joy Allchin', 89);

-- refund_request
insert into refund_request (id, handled_by, order_id , shop_id , product_id, sell_timestamp, quantity, request_date, status, handled_date, rejection_reason) values (1, null, 15, 8, 11, '2021-10-07 20:37:57', 10, '3/3/2022', 'pending', null, null);
insert into refund_request (id, handled_by, order_id , shop_id , product_id, sell_timestamp, quantity, request_date, status, handled_date, rejection_reason) values (2, 10, 6, 7, 11, '2021-11-15 18:28:53', 2, '1/12/2022', 'being_handled', null, null);
insert into refund_request (id, handled_by, order_id , shop_id , product_id, sell_timestamp, quantity, request_date, status, handled_date, rejection_reason) values (3, 9, 6, 7, 11, '2021-11-15 18:28:53', 8, '6/9/2021', 'accepted', '6/10/2021', null);
insert into refund_request (id, handled_by, order_id , shop_id , product_id, sell_timestamp, quantity, request_date, status, handled_date, rejection_reason) values (4, 5, 4, 6, 6, '2021-04-06 20:43:27', 1, '1/1/2022','rejected', '1/24/2022', 'Sprain of medial collateral ligament of left knee');

-- complaint
insert into complaint (id, content, status, user_id, handled_by) values (1, 'Nondisp commnt fx shaft of l femr, 7thK', 'pending', 9, null);
insert into complaint (id, content, status, user_id, handled_by) values (2, 'Displ oblique fx shaft of l ulna, 7thM', 'pending', 6, null);
insert into complaint (id, content, status, user_id, handled_by) values (3, 'Terrorism involving chemical weapons, civilian injured', 'addressed', 8, 3);
insert into complaint (id, content, status, user_id, handled_by) values (4, 'Other acute nonsuppurative otitis media', 'being_handled', 3, 7);
insert into complaint (id, content, status, user_id, handled_by) values (5, 'Occup of hv veh injured in clsn w oth and unsp mv in traf', 'pending', 7, null);
insert into complaint (id, content, status, user_id, handled_by) values (6, 'Strain extensor musc/fasc/tend r idx fngr at forarm lv, subs', 'pending', 4, null);
insert into complaint (id, content, status, user_id, handled_by) values (7, 'Burn of second degree of trunk, unsp site, subs encntr', 'addressed', 5, 7);
insert into complaint (id, content, status, user_id, handled_by) values (8, 'Lens-induced iridocyclitis, left eye', 'being_handled', 3, 8);
insert into complaint (id, content, status, user_id, handled_by) values (9, 'Inhalant abuse w inhalant-induced psychotic disorder, unsp', 'being_handled', 7, 1);
insert into complaint (id, content, status, user_id, handled_by) values (10, 'Animal-rider injured in unsp transport accident, init encntr', 'addressed', 5, 1);

-- shop_complaint
insert into shop_complaint (id, shop_id) values (9, 6);
insert into shop_complaint (id, shop_id) values (6, 10);
insert into shop_complaint (id, shop_id) values (1, 6);

-- comment_complaint
insert into comment_complaint (id, comment_id) values (2, 6);
insert into comment_complaint (id, comment_id) values (3, 10);
insert into comment_complaint (id, comment_id) values (8, 6);
insert into comment_complaint (id, comment_id) values (7, 9);

-- delivery_complaint
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (4, 15, 8, 11, '2021-10-07 20:37:57');
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (5, 4, 6, 6, '2021-04-06 20:43:27');
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (10, 6, 7, 11, '2021-11-15 18:28:53');


-- trigger 11 
delete from delivery_complaint where id = 10;
-- TC1: insert to delivery_complaint when product has not delivered
-- expect: cannot inser0
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) 
values (10, 9, 10, 14, '2021-04-12 13:40:58'); 

-- TC2: insert to delivery_complaint when product has been delivered 
-- expected: can insert
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) 
values (10, 6, 7, 11, '2021-11-15 18:28:53'); 

-- trigger 12
-- TC1: none of complaint type
insert into complaint (id, content, status, user_id, handled_by) 
values (11, 'Animal-rider injured in unsp transport accident, init encntr', 'addressed', 5, 1);

-- TC2: just delivery complaint
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (11, 9, 10, 14, '2021-04-12 13:40:58');
COMMIT;

-- TC3: just shop complaint
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into shop_complaint(id, shop_id) values (11, 10);
COMMIT;

-- TC4: just comment complaint
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into comment_complaint (id, comment_id) values (11, 6);
COMMIT;

-- TC5: triggered when insert deli
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into comment_complaint (id, comment_id) values (11, 6);
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (11, 9, 10, 14, '2021-04-12 13:40:58');
COMMIT;

-- TC6: triggered when insert comment
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (11, 9, 10, 14, '2021-04-12 13:40:58');
insert into comment_complaint (id, comment_id) values (11, 6);
COMMIT;

-- TC7: triggered when insert shop
BEGIN;
SET CONSTRAINTS check_type_complaint DEFERRED;
insert into delivery_complaint (id, order_id, shop_id, product_id, sell_timestamp) values (11, 9, 10, 14, '2021-04-12 13:40:58');
insert into complaint (id, content, status, user_id, handled_by) values (11, 'test 11', 'addressed', 5, 1);
insert into shop_complaint(id, shop_id) values (11, 10);
COMMIT;

-- procedures 2
-- TC1: review on the same product purchase
-- expected: move current review to review_version, add new review to review + review_version 
call review(3, 4, 6, 6, '2021-04-06 20:43:27', 'hi', 1, '2022-04-07 20:43:27');

-- TC2: 1st review for product purchase 
-- expected: added to comment + review + review_version
call review(7, 9, 10, 19, '2022-02-25 14:48:35', 'hi not duplicate', 2, '2022-02-27 20:43:27');

-- TC3: add to empty comment table
-- \i components/mai_test_procedures.sql;


-- function








\i test.sql;
\i components/mai.sql;