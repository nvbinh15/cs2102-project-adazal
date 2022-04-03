/*
1. Constraints to be Enforced using Triggers
Complaint related: 
(11) A delivery complaint can only be made when the product has been delivered.
(12) A complaint is either a delivery-related complaint, a shop-related complaint or a comment-related
complaint (non-overlapping and covering).

2. Routines
2.1 Procedures
(2) review( user_id INTEGER, order_id INTEGER, shop_id INTEGER, product_id INTEGER, sell_timestamp
TIMESTAMP, content TEXT, rating INTEGER, comment_timestamp TIMESTAMP)
- Creates a review by the given user for the particular ordered product

2.2 Functions
(3) get_worst_shops( n INTEGER )
- Output: TABLE( shop_id INTEGER, shop_name TEXT, num_negative_indicators INTEGER )
- Finds the N worst shops, judging by the number of negative indicators that they have
  + Each ordered product from that shop which has a refund request (regardless of status) is
considered as one negative indicator
  + Multiple refund requests on the same orderline only count as one negative indicator
- Each shop complaint (regardless of status) is considered as one negative indicator
- Each delivery complaint (regardless of status) for a delivered product by that shop is considered as
one negative indicator
  + Multiple complaints on the same orderline only count as one negative indicator
- Each 1-star review is considered as one negative indicator
  + Only consider the latest version of the review
  + i.e., if there is a previous version that is 1-star but the latest version is 2-star, then we do
not consider this as a negative indicator
- Results should be ordered descending by num_negative_indicators (the total number of all negative
indicators listed above)
  + In the case of a tie in num_negative_indicators, order them ascending by shop_id
*/

-- 1 (11)
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


-- 1 (12) 
CREATE OR REPLACE FUNCTION check_type_complaint()
RETURNS TRIGGER AS $$ 

DECLARE 
  is_delivery BOOLEAN;
  is_shop BOOLEAN;
  is_comment BOOLEAN;

BEGIN 
  select (count(*) > 0) into is_shop 
  from shop_complaint C
  where C.id = OLD.id;

  select (count(*) > 0) into is_comment 
  from comment_complaint C
  where C.id = OLD.id; 

  select (count(*) > 0) into is_delivery
  from delivery_complaint C
  where C.id = OLD.id; 

  if (is_shop or is_comment or is_delivery) then 
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
DROP TRIGGER IF EXISTS check_type_complaint ON complaint;
CREATE CONSTRAINT TRIGGER check_type_complaint
AFTER INSERT ON complaint 
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW 
EXECUTE FUNCTION check_type_complaint();


-- 2.1 (2) 
CREATE OR REPLACE PROCEDURE review( user_id INTEGER, order_id INTEGER, shop_id INTEGER, product_id INTEGER, sell_timestamp
TIMESTAMP, content TEXT, rating INTEGER, comment_timestamp TIMESTAMP)
AS $$
DECLARE
  comment_id INTEGER;
BEGIN
  INSERT INTO comment(user_id) VALUES (user_id) RETURNING id INTO comment_id;
  INSERT INTO review(id, order_id, shop_id, product_id, sell_timestamp) VALUES 
    (comment_id, order_id, shop_id, product_id, sell_timestamp);
  INSERT INTO review_version(review_id, review_timestamp, content, rating) VALUES 
    (comment_id, comment_timestamp, content, rating);

END;
$$ LANGUAGE plpgsql;

--2.2 (3) 
CREATE OR REPLACE FUNCTION get_worst_shops(n INTEGER)
RETURNS TABLE(shop_id INTEGER, shop_name TEXT, num_negative_indicators INTEGER) AS $$

DECLARE 
  curs CURSOR FOR (
    select S.shop_id, S.shop_name, (Negative1.count_refund + Negative2.count_shop_complaint + Negative3.count_delivery_complaint + Negative4.count_bad_review) count_negative_indicators
    from (select R.shop_id, count(*) as count_refund
          from refund_request R 
          group by (R.order_id, R.shop_id, R.product_id, R.sell_timestamp)) Negative1,

          (select C.shop_id, count(*) as count_shop_complaint
          from shop_complaint C) Negative2,

          (select C.shop_id, count(*) as count_delivery_complaint
          from delivery_complaint C 
          group by (C.order_id, C.shop_id, C.product_id, C.sell_timestamp)) Negative3,

          (select R.shop_id, RV.count(*) as count_bad_review 
          from review R, review_version RV 
          where R.id = RV.review_id and RV.rating = 1 and 
              RV.review_timestamp >= ALL (select review_timestamp from review_version)) Negative4,
          shop S 
    where Negative1.shop_id = S.shop_id and Negative2.shop_id = S.shop_id and Negative3.shop_id = S.shop_id and Negative4 = S.shop_id 
    order by count_negative_indicators DESC 
    limit n
  );
  r RECORD;

BEGIN 
  OPEN curs;
  LOOP 
    FETCH curs INTO r;
    EXIT WHEN NOT FOUND;
    shop_id := r.shop_id;
    shop_name := r.shop_name;
    num_negative_indicators := r.count_negative_indicators;

    RETURN NEXT;
  END LOOP;
  CLOSE curs;
  RETURN;
END;

$$ LANGUAGE plpgsql;