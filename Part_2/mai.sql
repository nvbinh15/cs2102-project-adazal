/*
1. Constraints to be Enforced using Triggers
Complaint related:
(11) A delivery complaint can only be made when the product has been delivered.
(12) A complaint is either a delivery-related complaint, a shop-related complaint or a comment-related
complaint (non-overlapping and covering)
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
CREATE TRIGGER check_type_complaint
AFTER INSERT OR UPDATE ON complaint 
FOR EACH ROW 
EXECUTE FUNCTION check_delivery_complaint();


-- 2 (2)
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
  curs CURSOR FOR (select shop_id, shop_name from shop);
  r record;
  refund_count INTEGER;
  shop_complaint_count INTEGER;
  delivery_complaint_count INTEGER;
  bad_review_count INTEGER;
  
BEGIN

  OPEN curs;
  LOOP 
    FETCH curs INTO r;
    select count(*) INTO refund_count
    from refund_request R
    where R.shop_id = r.shop_id 
    group by (R.order_id, R.shop_id, R.product_id, R.sell_timestamp));

    select count(*) INTO shop_complaint_count
    from shop_complaint C 
    where C.shop_id = r.shop_id;

    select count(*) INTO delivery_complaint_count 
    from delivery_complaint C 
    where C.shop_id = r.shop_id 
    group by (C.order_id, C.shop_id, C.product_id, C.sell_timestamp);

    select count(*) INTO bad_review_count 
    from review R, review_version RV 
    where R.shop_id = r.shop_id and R.id = RV.review_id and RV.rating = 1 and 
          RV.review_timestamp >= ALL (select review_timestamp from review_version);

    shop_id := r.shop_id;
    shop_name := r.shop_name;
    num_negative_indicators := refund_count + shop_complaint_count + delivery_complaint_count + bad_review_count;

    RETURN NEXT;
    EXIT WHEN NOT FOUND;
  
  END LOOP;
  CLOSE curs;
  RETURN;

  -- ABOVE PART IS CTE count_negative_indicators, not sure how to include CTE in SQL function?
  select shop_id, shop_name, num_negative_indicators 
  from count_negative_indicators
  order by num_negative_indicators DESC 
  limit n;

END;

$$ LANGUAGE plpgsql;