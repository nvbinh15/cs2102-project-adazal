/* CONSTRAINTS */

-- (1) Each shop should sell at least one product.

CREATE OR REPLACE FUNCTION check_shop_products()
RETURNS TRIGGER AS $$
DECLARE
    num_of_products INTEGER;
BEGIN
    num_of_products := (
        SELECT COUNT(*)
        FROM Sells S
        WHERE S.product_id = NEW.id
    );
    IF num_of_products < 1 THEN
        RAISE EXCEPTION 'Each shop should sell at least one product.';
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS shop_products_trigger ON Shop;

CREATE CONSTRAINT TRIGGER shop_products_trigger
AFTER INSERT ON Shop
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_shop_products();

-- (2) An order must involve one or more products from one or more shops.

CREATE OR REPLACE FUNCTION check_order_products()
RETURNS TRIGGER AS $$
DECLARE
    num_of_products INTEGER;
BEGIN
    num_of_products := (
        SELECT COUNT(*)
        FROM Orderline O
        WHERE O.order_id = NEW.id
    );
    IF num_of_products < 1 THEN
        RAISE EXCEPTION 'An order must involve one or more products from one or more shops.';
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_products_trigger ON Orders;

CREATE CONSTRAINT TRIGGER order_products_trigger
AFTER INSERT ON Orders
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_order_products();

-- (3)  A coupon can only be used on an order whose total amount (before the coupon is applied) 
-- exceeds the minimum order amount.

CREATE OR REPLACE FUNCTION check_order_coupon()
RETURNS TRIGGER AS $$
DECLARE
    minimum_amount INTEGER;
    total_amount INTEGER;
BEGIN
    IF NEW.coupon_id IS NULL THEN 
        RETURN NEW;
    END IF;
    minimum_amount := (
        SELECT C.min_order_amount
        FROM Coupon_batch C
        WHERE C.id = NEW.coupon_id
    );
    total_amount := (
        SELECT SUM(O.quantity * S.price)
        FROM Orderline O JOIN Sells S
        ON ROW(O.shop_id, O.product_id, O.sell_timestamp) = ROW(S.shop_id, S.product_id, S.sell_timestamp)
        WHERE O.order_id = NEW.id
    );
    IF total_amount < minimum_amount THEN
        RAISE EXCEPTION 'A coupon can only be used on an order whose total amount % (before the coupon is applied) exceeds the minimum order amount %.', total_amount, minimum_amount;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_coupon_trigger ON Orders;

CREATE CONSTRAINT TRIGGER order_coupon_trigger
AFTER INSERT ON Orders
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_order_coupon();

-- (4) The refund quantity must not exceed the ordered quantity
CREATE OR REPLACE FUNCTION check_refund_quantity()
RETURNS TRIGGER AS $$
DECLARE
    order_quantity INTEGER;
    current_refund_quantity INTEGER;
BEGIN
    SELECT O.quantity INTO order_quantity
    FROM orderline O
    WHERE O.order_id = NEW.order_id 
        and O.shop_id = NEW.shop_id 
        and O.product_id = NEW.product_id 
        and O.sell_timestamp = NEW.sell_timestamp;
    
    SELECT sum(R.quantity) INTO current_refund_quantity
    FROM refund_request R 
    WHERE R.order_id = NEW.order_id 
        and R.shop_id = NEW.shop_id 
        and R.product_id = NEW.product_id 
        and R.sell_timestamp = NEW.sell_timestamp
        and R.status <> 'rejected';

    IF NEW.quantity + current_refund_quantity > order_quantity THEN 
        RAISE NOTICE 'The refund quantity must not exceed the ordered quantity';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_quantity_not_exceed_ordered_quantity ON refund_request;

CREATE TRIGGER refund_quantity_not_exceed_ordered_quantity
BEFORE INSERT ON refund_request
FOR EACH ROW EXECUTE FUNCTION check_refund_quantity();


-- (5) The refund request date must be within 30 days of the delivery date
CREATE OR REPLACE FUNCTION check_refund_request_date()
RETURNS TRIGGER AS $$
DECLARE 
    last_valid_date DATE;
BEGIN
    SELECT (O.delivery_date + INTERVAL '30 days') INTO last_valid_date 
    FROM orderline O
    WHERE O.order_id = NEW.order_id 
        and O.shop_id = NEW.shop_id 
        and O.product_id = NEW.product_id 
        and O.sell_timestamp = NEW.sell_timestamp;
        
    IF NEW.request_date > last_valid_date THEN 
        RAISE NOTICE 'The refund request date must be within 30 days of the delivery date';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_request_date ON refund_request;

CREATE TRIGGER refund_request_date
BEFORE INSERT ON refund_request 
FOR EACH ROW EXECUTE FUNCTION check_refund_request_date();

-- (6) Refund request can only be made for a delivered product
CREATE OR REPLACE FUNCTION check_refund_delivered_product()
RETURNS TRIGGER AS $$
DECLARE
    product_status orderline_status;
BEGIN
    SELECT O.status INTO product_status
    FROM orderline O
    WHERE O.order_id = NEW.order_id 
        and O.shop_id = NEW.shop_id 
        and O.product_id = NEW.product_id 
        and O.sell_timestamp = NEW.sell_timestamp;

    IF product_status <> 'delivered' THEN 
        RAISE NOTICE 'Refund request can only be made for a delivered product';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_only_delivered_product ON refund_request;

CREATE TRIGGER refund_only_delivered_product
BEFORE INSERT ON refund_request
FOR EACH ROW EXECUTE FUNCTION check_refund_delivered_product();

-- (7) A user can only make a product review for a product that they themselves purchased
CREATE OR REPLACE FUNCTION check_review_purchased()
RETURNS TRIGGER as $$
DECLARE 
    user_id INTEGER;
    user_order_id INTEGER;
BEGIN 
    SELECT C.user_id INTO user_id
    FROM comment C
    WHERE C.id = NEW.id;

    SELECT O.user_id INTO user_order_id
    FROM orders O 
    WHERE O.id = NEW.order_id AND EXISTS (
        SELECT 1
        FROM orderline Od 
        WHERE Od.order_id = NEW.order_id AND Od.shop_id = NEW.shop_id AND Od.product_id = NEW.product_id
        AND Od.sell_timestamp = NEW.sell_timestamp
    );

    IF user_id = user_order_id THEN
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS review_on_purchase_prodcut ON review;

CREATE TRIGGER review_on_purchase_prodcut
BEFORE INSERT ON review
FOR EACH ROW EXECUTE FUNCTION check_review_purchased();

-- (8) A comment is either a review or a reply, not both (non-overlapping and covering)
CREATE OR REPLACE FUNCTION check_comment()
RETURNS TRIGGER as $$
DECLARE 
    review_id INTEGER;
    reply_id INTEGER;
BEGIN 
    SELECT Rv.id INTO review_id
    FROM review Rv
    WHERE Rv.id = NEW.id;

    SELECT Rp.id INTO reply_id
    FROM reply Rp
    WHERE Rp.id = NEW.id;

    IF review_id IS NULL AND reply_id IS NULL THEN 
        RAISE EXCEPTION 'Comment is neither a review or reply';
    ELSIF review_id IS NOT NULL AND reply_id IS NOT NULL THEN 
        RAISE EXCEPTION 'Comment is both a review and reply';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_insert_reply()
RETURNS TRIGGER as $$
DECLARE 
    review_id INTEGER;
BEGIN 
    SELECT Rv.id INTO review_id
    FROM review Rv
    WHERE Rv.id = NEW.id;

    IF review_id IS NOT NULL THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_insert_review()
RETURNS TRIGGER as $$
DECLARE 
    reply_id INTEGER;
BEGIN 
    SELECT Rp.id INTO reply_id
    FROM reply Rp
    WHERE Rp.id = NEW.id;

    IF reply_id IS NOT NULL THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS comment_is_either_reply_or_review ON comment;
DROP TRIGGER IF EXISTS comment_is_either_reply_or_review_insert_reply ON reply;
DROP TRIGGER IF EXISTS comment_is_either_reply_or_review_insert_review ON review;

CREATE CONSTRAINT TRIGGER comment_is_either_reply_or_review 
AFTER INSERT ON comment
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_comment();

CREATE TRIGGER comment_is_either_reply_or_review_insert_reply
BEFORE INSERT ON reply
FOR EACH ROW EXECUTE FUNCTION check_insert_reply();

CREATE TRIGGER comment_is_either_reply_or_review_insert_review 
BEFORE INSERT ON review
FOR EACH ROW EXECUTE FUNCTION check_insert_review();

-- (9) A reply has at least one reply version
CREATE OR REPLACE FUNCTION check_reply_version()
RETURNS TRIGGER as $$
DECLARE 
    num_of_version INTEGER;
BEGIN 
    num_of_version := 0;
    SELECT count(*) INTO num_of_version
    FROM reply_version R 
    WHERE R.reply_id = NEW.id;

    IF num_of_version = 0 THEN 
        RAISE EXCEPTION 'No reply version';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS insert_reply_version ON reply;

CREATE CONSTRAINT TRIGGER insert_reply_version
AFTER INSERT ON reply
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_reply_version();

-- (10) A review has at least one review version
CREATE OR REPLACE FUNCTION check_review_version()
RETURNS TRIGGER as $$
DECLARE 
    num_of_version INTEGER;
BEGIN 
    num_of_version := 0;
    SELECT count(*) INTO num_of_version
    FROM review_version R 
    WHERE R.review_id = NEW.id;

    IF num_of_version = 0 THEN 
        RAISE EXCEPTION 'No review version';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS insert_review_version ON review;

CREATE CONSTRAINT TRIGGER insert_review_version
AFTER INSERT ON review
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_review_version();

-- (11) A delivery complaint can only be made when the product has been delivered
CREATE OR REPLACE FUNCTION check_delivery_complaint()
RETURNS TRIGGER AS $$
DECLARE
  status orderline_status;
  
BEGIN 
  select O.status into status
  from orderline O
  where (NEW.order_id = O.order_id) and (NEW.shop_id = O.shop_id) and 
  (NEW.product_id = O.product_id) and (NEW.sell_timestamp = O.sell_timestamp);

  IF status <> 'delivered' THEN 
    RETURN NULL;
  ELSE 
    RETURN NEW;
  END IF;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_delivery_complaint ON delivery_complaint;
CREATE TRIGGER check_delivery_complaint
BEFORE INSERT ON delivery_complaint
FOR EACH ROW 
EXECUTE FUNCTION check_delivery_complaint();


-- (12) A complaint is either a delivery-related complaint, a shop-related complaint or 
-- a comment-related complaint (non-overlapping and covering)
CREATE OR REPLACE FUNCTION check_type_complaint()
RETURNS TRIGGER AS $$ 

DECLARE 
  is_delivery BOOLEAN;
  is_shop BOOLEAN;
  is_comment BOOLEAN;

BEGIN 
  select (count(*) > 0) into is_shop 
  from shop_complaint C
  where C.id = NEW.id;

  select (count(*) > 0) into is_comment 
  from comment_complaint C
  where C.id = NEW.id; 

  select (count(*) > 0) into is_delivery
  from delivery_complaint C
  where C.id = NEW .id; 

  if (NOT (is_shop or is_comment or is_delivery)) then 
    RAISE EXCEPTION 'complaint is none of the type shop, comment, or delivery';
  elsif (is_shop and is_delivery) then 
    RAISE EXCEPTION 'complaint is both of type shop and delivery';
  elsif (is_delivery and is_comment) then 
    RAISE EXCEPTION 'complaint is both of type delivery and comment';
  elsif (is_comment and is_shop) then 
    RAISE EXCEPTION 'complaint is both of type comment and shop';
  else 
    RETURN NULL;
  END IF;
END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_insert_delivery_complaint() 
RETURNS TRIGGER AS $$ 

DECLARE 
  is_shop BOOLEAN;
  is_comment BOOLEAN;

BEGIN
  select (count(*) > 0) into is_shop
  from shop_complaint C 
  where NEW.id = C.id;

  select (count(*) > 0) into is_comment 
  from comment_complaint C
  where C.id = NEW.id;

  if (is_shop or is_comment) then 
    RETURN NULL;
  else 
    RETURN NEW;
  END IF;
END;

$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_insert_shop_complaint() 
RETURNS TRIGGER AS $$ 

DECLARE 
  is_delivery BOOLEAN;
  is_comment BOOLEAN;

BEGIN
  select (count(*) > 0) into is_delivery
  from delivery_complaint C 
  where NEW.id = C.id;

  select (count(*) > 0) into is_comment 
  from comment_complaint C
  where C.id = NEW.id;

  if (is_delivery or is_comment) then 
    RETURN NULL;
  else 
    RETURN NEW;
  END IF;

END;

$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_insert_comment_complaint() 
RETURNS TRIGGER AS $$ 

DECLARE 
  is_delivery BOOLEAN;
  is_shop BOOLEAN;

BEGIN
  select (count(*) > 0) into is_delivery
  from delivery_complaint C
  where C.id = NEW.id;

  select (count(*) > 0) into is_shop
  from shop_complaint C 
  where NEW.id = C.id;

  if (is_delivery or is_shop) then 
    RETURN NULL;
  else 
    RETURN NEW;
  END IF;

END;

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_type_complaint ON complaint;
DROP TRIGGER IF EXISTS check_insert_delivery_complaint ON delivery_complaint;
DROP TRIGGER IF EXISTS check_insert_shop_complaint ON shop_complaint;
DROP TRIGGER IF EXISTS check_insert_comment_complaint ON comment_complaint;

CREATE CONSTRAINT TRIGGER check_type_complaint
AFTER INSERT ON complaint
DEFERRABLE INITIALLY DEFERRED 
FOR EACH ROW EXECUTE FUNCTION check_type_complaint();

CREATE TRIGGER check_insert_delivery_complaint 
BEFORE INSERT ON delivery_complaint
FOR EACH ROW EXECUTE FUNCTION check_insert_delivery_complaint();

CREATE TRIGGER check_insert_shop_complaint 
BEFORE INSERT ON shop_complaint
FOR EACH ROW EXECUTE FUNCTION check_insert_shop_complaint();

CREATE TRIGGER check_insert_comment_complaint 
BEFORE INSERT ON comment_complaint
FOR EACH ROW EXECUTE FUNCTION check_insert_comment_complaint();

/* PROCEDURES */

-- (1) place_order
CREATE OR REPLACE PROCEDURE place_order( 
    user_id INTEGER, _coupon_id INTEGER, shipping_address TEXT, 
    shop_ids INTEGER[], product_ids INTEGER[], sell_timestamps TIMESTAMP[], 
    quantities INTEGER[], shipping_costs NUMERIC[]
) AS $$
DECLARE
    payment NUMERIC;
    order_id INTEGER;
    i INTEGER;
    price NUMERIC;
BEGIN
    order_id := (SELECT COALESCE(MAX(id), 0) FROM Orders) + 1;
    INSERT INTO Orders(id, user_id, coupon_id, shipping_address, payment_amount)
    VALUES (order_id, user_id, NULL, shipping_address, 0);
    payment := 0;

    FOR i IN 1..array_upper(product_ids, 1)
    LOOP
        INSERT INTO Orderline
        VALUES (order_id, shop_ids[i], product_ids[i], sell_timestamps[i], quantities[i], shipping_costs[i], 'being_processed', NULL);
        
        UPDATE Sells
        SET quantity = quantity - quantities[i]
        WHERE ROW(shop_id, product_id, sell_timestamp) = ROW(shop_ids[i], product_ids[i], sell_timestamps[i]);
        
        price := (
            SELECT S.price
            FROM Sells S
            WHERE ROW(S.shop_id, S.product_id, S.sell_timestamp) = ROW(shop_ids[i], product_ids[i], sell_timestamps[i])
        );
        payment := payment + quantities[i] * price + shipping_costs[i];
    END LOOP;

    RAISE NOTICE 'payment: %', payment;
    UPDATE Orders
    SET payment_amount = payment - COALESCE((
        SELECT C.reward_amount
        FROM Coupon_batch C
        WHERE C.id = _coupon_id
    ), 0), coupon_id = _coupon_id
    WHERE id = order_id;
END;
$$ LANGUAGE plpgsql;

-- (2) review
CREATE OR REPLACE PROCEDURE review( user_id INTEGER, order_id INTEGER, shop_id INTEGER, product_id INTEGER, sell_timestamp
TIMESTAMP, content TEXT, rating INTEGER, comment_timestamp TIMESTAMP)
AS $$
DECLARE
  a_order_id alias for order_id;
  a_shop_id alias for shop_id;
  a_product_id alias for product_id;
  a_sell_timestamp alias for sell_timestamp;
  comment_id INTEGER;
  is_duplicate BOOLEAN;

BEGIN  
  select (count(*) > 0) INTO is_duplicate from review R
  where R.order_id = a_order_id and R.shop_id = a_shop_id and R.product_id = a_product_id
        and R.sell_timestamp = a_sell_timestamp;
  
  IF is_duplicate THEN 
    -- if review for product purchase alr exists, just add the latest version to review_version,
    -- no need to change comment and review table
    select R.id into comment_id from review R
    where R.order_id = a_order_id and R.shop_id = a_shop_id and R.product_id = a_product_id 
        and R.sell_timestamp = a_sell_timestamp;
    insert into review_version (review_id, review_timestamp, content, rating) values 
                (comment_id, comment_timestamp, content, rating);

  ELSE 
    -- if first time review, need to add into all comment + review + review_version table
    select COALESCE(max(C.id) + 1, 1) INTO comment_id from comment C;
    insert into comment(id, user_id) values (comment_id, user_id); 
    insert into review (id, order_id, shop_id , product_id, sell_timestamp) values 
                (comment_id, order_id, shop_id, product_id, sell_timestamp);
    insert into review_version (review_id, review_timestamp, content, rating) values 
                (comment_id, comment_timestamp, content, rating);
  END IF;
   
END;
$$ LANGUAGE plpgsql;

-- (3) reply
CREATE OR REPLACE PROCEDURE reply(user_id INTEGER, other_comment_id INTEGER, content TEXT, reply_timestamp TIMESTAMP)
AS $$
DECLARE
    a_user_id ALIAS FOR user_id;
    a_other_comment_id ALIAS FOR other_comment_id;
    is_duplicate BOOLEAN;
    comment_id INTEGER;
BEGIN
    SELECT (count(*) > 0) INTO is_duplicate 
    FROM reply R, comment C 
    WHERE C.user_id = a_user_id 
        AND C.id = R.id 
        AND R.other_comment_id = a_other_comment_id;

    IF is_duplicate THEN 
        SELECT R.id INTO comment_id 
        FROM reply R, comment C
        WHERE C.user_id = a_user_id 
            AND C.id = R.id 
            AND R.other_comment_id = a_other_comment_id;
        
        INSERT INTO reply_version(reply_id, reply_timestamp, content) VALUES (comment_id, reply_timestamp, content);

    ELSE
        SELECT COALESCE(max(id) + 1, 1) INTO comment_id FROM comment;
        INSERT INTO comment(id, user_id) VALUES (comment_id, user_id);
        INSERT INTO reply(id, other_comment_id) VALUES (comment_id, other_comment_id);
        INSERT INTO reply_version(reply_id, reply_timestamp, content) VALUES (comment_id, reply_timestamp, content);
    END IF;

END;
$$ LANGUAGE plpgsql;

/* FUNCTIONS */

-- (1) view_comments
CREATE OR REPLACE FUNCTION view_comments(shop_id INTEGER, product_id INTEGER, sell_timestamp TIMESTAMP)
RETURNS TABLE (username TEXT, content TEXT, rating INTEGER, comment_timestamp TIMESTAMP) AS $$
DECLARE
    a_shop_id ALIAS FOR shop_id;
    a_product_id ALIAS FOR product_id;
    a_sell_timestamp ALIAS FOR sell_timestamp;

    curs CURSOR FOR (
        WITH RECURSIVE related_comments(username, account_closed, comment_id, content, rating, comment_timestamp) AS (
            SELECT U.name, U.account_closed, C.id, RV.content, RV.rating, RV.review_timestamp
            FROM users U, comment C, review R, review_version RV 
            WHERE R.product_id = a_product_id AND R.shop_id = a_shop_id AND R.sell_timestamp = a_sell_timestamp
                AND R.id = C.id AND C.user_id = U.id 
                AND R.id = RV.review_id AND RV.review_timestamp >= ALL (
                    SELECT review_timestamp
                    FROM review_version
                    WHERE review_id = RV.review_id 
                )
            
            UNION ALL 

            SELECT U.name, U.account_closed, C.id, RV.content, NULL, RV.reply_timestamp
            FROM users U, comment C, reply R, reply_version RV, related_comments RC 
            WHERE RC.comment_id = R.other_comment_id AND R.id = C.id AND C.user_id = U.id AND R.id = RV.reply_id
                AND RV.reply_timestamp >= ALL (
                    SELECT reply_timestamp
                    FROM reply_version 
                    WHERE reply_id = RV.reply_id
                )
        ) 
        SELECT * FROM related_comments ORDER BY comment_timestamp, comment_id
    );
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;

        IF r.account_closed = TRUE 
            THEN username := 'A Deleted User';
            ELSE username := r.username;
        END IF;

        content := r.content;
        rating := r.rating;
        comment_timestamp = r.comment_timestamp;

        RETURN NEXT;
    END LOOP;

    CLOSE curs;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- (2)
CREATE OR REPLACE FUNCTION get_most_returned_products_from_manufacturer(IN manufacturer_id INTEGER, IN n INTEGER)
RETURNS TABLE(product_id INTEGER, product_name TEXT, return_rate NUMERIC(3, 2)) AS $$
DECLARE
    curs CURSOR FOR (
        WITH product_accept_rate AS (
            SELECT R.product_id, count(id) as num_accept
            FROM refund_request R
            WHERE status = 'accepted'
            GROUP BY R.product_id
        ),
        product_total AS (
            SELECT R.product_id, count(id) as total_refund
            FROM refund_request R
            GROUP BY R.product_id
        ),
        product_rate AS (
            SELECT R1.product_id, ROUND(num_accept::decimal/total_refund, 2) as rate
            FROM product_accept_rate R1 NATURAL JOIN product_total R2
        )
        SELECT P.id, P.name, coalesce(R.rate, 0.00) as rate
        FROM product P FULL OUTER JOIN product_rate R ON P.id = R.product_id
        WHERE P.manufacturer = manufacturer_id
        ORDER BY rate DESC, P.id
    );
    r1 RECORD;
BEGIN 
    OPEN curs;
    FOR c in 1..n LOOP 
        FETCH curs into r1;
        EXIT WHEN NOT FOUND;
        product_id := r1.id;
        product_name := r1.name;
        return_rate := r1.rate;
        RETURN NEXT;
    END LOOP; 
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

-- (3)
CREATE OR REPLACE FUNCTION get_worst_shops(n INTEGER)
RETURNS TABLE(shop_id INTEGER, shop_name TEXT, num_negative_indicators INTEGER) AS $$

DECLARE 
  curs CURSOR FOR (
    select S.id, S.name, (Negative1.count_refund + Negative2.count_shop_complaint + Negative3.count_delivery_complaint + Negative4.count_bad_review) count_negative_indicators

    from shop S, (select S1.id, COALESCE((select count(*) from refund_request R 
                                  where R.shop_id = S1.id 
                                  group by (R.order_id, R.product_id, R.sell_timestamp)),0) count_refund
                  from Shop S1) as Negative1,
                  
                  (select S1.id, COALESCE((select count(*) from shop_complaint C 
                                    where C.shop_id = S1.id), 0) count_shop_complaint
                  from Shop S1) as Negative2,

                  (select S1.id, COALESCE((select count(*) from delivery_complaint C 
                                    where C.shop_id = S1.id
                                    group by (C.order_id, C.product_id, C.sell_timestamp)), 0) count_delivery_complaint
                  from Shop S1) as Negative3,

                  (select S1.id, COALESCE((select count(*) from review R, review_version RV 
                                    where R.shop_id = S1.id and R.id = RV.review_id and 
                                    RV.rating = 1 and 
                                    RV.review_timestamp >= ALL (select review_timestamp 
                                                                from review_version RV1
                                                                where RV1.review_id = R.id)), 0) count_bad_review
                  from Shop S1) as Negative4

        where Negative1.id = S.id and Negative2.id = S.id and Negative3.id = S.id and 
              Negative4.id = S.id
        order by count_negative_indicators DESC, id ASC
        limit n
      );
  r RECORD;

BEGIN 
  OPEN curs;
  LOOP 
    FETCH curs INTO r;
    EXIT WHEN NOT FOUND;
    shop_id := r.id;
    shop_name := r.name;
    num_negative_indicators := r.count_negative_indicators;

    RETURN NEXT;
  END LOOP;
  CLOSE curs;
  RETURN;
END;
$$ LANGUAGE plpgsql;
