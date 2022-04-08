-- Test trigger 8, comment is not either a reply or review
INSERT INTO comment(id, user_id) VALUES (13, 4)

-- Test trigger 9, reply without reply version
INSERT INTO reply (id, other_comment_id) values (11, 4);

-- Test trigger 10, review without review version
INSERT INTO review (id, order_id, shop_id , product_id, sell_timestamp) values (12, 9, 10, 14, '2021-04-12 13:40:58');

-- Test trigger 9, reply with proper reply version
BEGIN;
SET CONSTRAINTS insert_reply_version DEFERRED;
INSERT INTO reply (id, other_comment_id) values (11, 4);
INSERT INTO reply_version (reply_id, reply_timestamp, content) values (11, '2021-01-02 20:43:27', 'Loose body in knee, left knee');
COMMIT;

-- Test trigger 10, review with proper review version
BEGIN;
SET CONSTRAINTS insert_review_version DEFERRED;
INSERT INTO review (id, order_id, shop_id , product_id, sell_timestamp) values (12, 17, 10, 14, '2021-04-12 13:40:58');
INSERT INTO review_version (review_id, review_timestamp, content, rating) values (12, '2021-04-12 13:40:58', 'Biliary acute pancreatitis with uninfected necrosis', 1);
COMMIT;

-- Test trigger 8, comment is both a reply and review
BEGIN;
SET CONSTRAINTS comment_is_either_reply_or_review DEFERRED;
SET CONSTRAINTS insert_reply_version DEFERRED;
SET CONSTRAINTS insert_review_version DEFERRED;
INSERT INTO comment (id, user_id) VALUES (13, 4)
INSERT INTO reply (id, other_comment_id) values (13, 4);
INSERT INTO review (id, order_id, shop_id , product_id, sell_timestamp) values (13, 9, 10, 14, '2021-04-12 13:40:58');
INSERT INTO review_version (review_id, review_timestamp, content, rating) values (13, '2021-04-12 13:40:58', 'Biliary acute pancreatitis with uninfected necrosis', 1);
INSERT INTO reply_version (reply_id, reply_timestamp, content) values (13, '2021-01-02 20:43:27', 'Loose body in knee, left knee');
COMMIT;

-- Test trigger 8, comment is a reply
BEGIN;
SET CONSTRAINTS comment_is_either_reply_or_review DEFERRED;
SET CONSTRAINTS insert_reply_version DEFERRED;
SET CONSTRAINTS insert_review_version DEFERRED;
INSERT INTO comment (id, user_id) VALUES (13, 4)
INSERT INTO reply (id, other_comment_id) values (13, 4);
INSERT INTO reply_version (reply_id, reply_timestamp, content) values (13, '2021-01-02 20:43:27', 'Loose body in knee, left knee');
COMMIT;

-- Test trigger 8, comment is a review
BEGIN;
SET CONSTRAINTS comment_is_either_reply_or_review DEFERRED;
SET CONSTRAINTS insert_reply_version DEFERRED;
SET CONSTRAINTS insert_review_version DEFERRED;
INSERT INTO comment (id, user_id) VALUES (14, 4)
INSERT INTO review (id, order_id, shop_id , product_id, sell_timestamp) values (14, 1, 7, 11, '2021-04-12 13:40:58');
INSERT INTO review_version (review_id, review_timestamp, content, rating) values (14, '2021-04-12 13:40:58', 'Biliary acute pancreatitis with uninfected necrosis', 1);
COMMIT;

-- Test trigger 7, make review and not purchase
BEGIN;
SET CONSTRAINTS comment_is_either_reply_or_review DEFERRED;
SET CONSTRAINTS insert_reply_version DEFERRED;
SET CONSTRAINTS insert_review_version DEFERRED;
INSERT INTO comment (id, user_id) VALUES (15, 8)
INSERT INTO review (id, order_id, shop_id , product_id, sell_timestamp) values (15, 1, 7, 11, '2021-04-12 13:40:58');
COMMIT;