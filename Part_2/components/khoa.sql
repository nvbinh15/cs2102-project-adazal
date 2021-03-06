/*
1. Comment related:
(7) A user can only make a product review for a product that they themselves purchased.
(8) A comment is either a review or a reply, not both (non-overlapping and covering).
(9) A reply has at least one reply version.
(10) A review has at least one review version.

2.2 Functions
(2) get_most_returned_products_from_manufacturer( manufacturer_id INTEGER, n INTEGER)
- Output: TABLE ( product_id INTEGER, product_name TEXT, return_rate NUMERIC(3, 2) )
- Obtains the N products from the provided manufacturer that have the highest return rate
(successfully refunded)
    o Products are only successfully refunded if the refund_request status is ‘accepted’
    o The output table may have fewer than N records if the manufacturer has produced fewer
    than N products
- Return rate for a product is calculated as (sum of quantity successfully returned across all orders)
/ (sum of quantity delivered across all orders)
    o The return rate should be a numeric value between 0.00 and 1.00, rounded off to the
    nearest 2 decimal places
    o If a product has never been ordered, its return_rate should default to 0.00
- Results should be ordered descending by return_rate
    o In the case of a tie in return_rate, order them ascending by product_id
*/

-- 1.(7)
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

-- 1.(8)
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
-- Add trigger when insert into review and reply

-- 1.(9)
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

-- 1.(10)
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

-- 2.2.(2)
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