/*
1. Constraints to be Enforced using Triggers
Refund related
(4) The refund quantity must not exceed the ordered quantity
(5) The refund request date must be within 30 days of the delivery date
(6) Refund request can only be made for a delivered product

2. Routines
2.1 Procedures
(3) reply( user_id INTEGER, other_comment_id INTEGER, content TEXT, reply_timestamp TIMESTAMP ) 
    - Creates a reply from user on another comment
2.2 Functions
(1) view_comments( shop_id INTEGER, product_id INTEGER, sell_timestamp TIMESTAMP )
- Output: TABLE ( username TEXT, content TEXT, rating INTEGER, comment_timestamp
TIMESTAMP )
- Retrieves info about all comments related to a product listing (an instance of the Sells relation)
    + This includes reviews, and also replies to the reviews for that product listing
- If the comment is a reply, the rating should be NULL for that row
- If a comment has multiple versions, return only the latest version
- If a comment belongs to a deleted user, display their name as ‘A Deleted User’ rather than their original username
- Results should be ordered ascending by the timestamp of the latest version of each comment
    + In the case of a tie in comment_timestamp, order them ascending by comment_id
*/

-- 1.(4)
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
        and R.refund_status <> 'rejected';

    IF NEW.quantity + current_refund_quantity > order_quantity THEN 
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_quantity_not_exceed_ordered_quantity ON refund_request;

CREATE TRIGGER refund_quantity_not_exceed_ordered_quantity
BEFORE INSERT ON refund_request
FOR EACH ROW EXECUTE FUNCTION check_refund_quantity();


-- 1.(5)
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
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_request_date ON refund_request;

CREATE TRIGGER refund_request_date
BEFORE INSERT ON refund_request 
FOR EACH ROW EXECUTE FUNCTION check_refund_request_date();

-- 1.(6)
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
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS refund_only_delivered_product ON refund_request;

CREATE TRIGGER refund_only_delivered_product
BEFORE INSERT ON refund_request
FOR EACH ROW EXECUTE FUNCTION check_refund_delivered_product();


-- 2.1.(3)
CREATE OR REPLACE PROCEDURE reply(user_id INTEGER, other_comment_id INTEGER, content TEXT, reply_timestamp TIMESTAMP)
AS $$
DECLARE
    comment_id INTEGER;
BEGIN
    INSERT INTO comment(user_id) VALUES (user_id) RETURNING id INTO comment_id;
    INSERT INTO reply(id, other_comment_id) VALUES (comment_id, other_comment_id);
    INSERT INTO reply_version(reply_id, reply_timestamp, content) VALUES (comment_id, reply_timestamp, content);
END;
$$ LANGUAGE plpgsql;


-- 2.2.(1)
CREATE OR REPLACE FUNCTION view_comments(shop_id INTEGER, product_id INTEGER, sell_timestamp TIMESTAMP)
RETURNS TABLE (username TEXT, content TEXT, rating INTEGER, comment_timestamp TIMESTAMP) AS $$
DECLARE
    curs CURSOR FOR (
        WITH RECURSIVE related_comments(username, account_closed, comment_id, content, rating, comment_timestamp) AS (
            SELECT U.name, U.account_closed, C.id, RV.content, RV.rating, RV.review_timestamp
            FROM users U, comment C, review R, review_version RV 
            WHERE R.shop_id = shop_id AND R.product_id = product_id AND R.sell_timestamp = sell_timestamp
                AND R.id = C.id AND C.user_id = U.id 
                AND R.id = RV.id AND RV.review_timestamp >= ALL (
                    SELECT review_timestamp
                    FROM review_version
                    WHERE review_id = RV.id 
                )
            
            UNION ALL 

            SELECT U.name, U.account_closed, C.id, RV.content, NULL, RV.review_timestamp
            FROM users U, comment C, reply R, reply_version RV 
            JOIN related_comments RC 
            ON RC.comment_id = R.other_comment_id
            WHERE R.id = C.id AND C.user_id = U.id AND R.id = RV.id
                AND RV.reply_timestamp >= ALL (
                    SELECT reply_timestamp
                    FROM reply_version 
                    WHERE reply_id = RV.id
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

        IF r.account_closed = TRUE THEN username := "A deleted user";
        END IF;

        RETURN NEXT;
    END LOOP;

    CLOSE curs;
    RETURN;
END;
$$ LANGUAGE plpgsql;
