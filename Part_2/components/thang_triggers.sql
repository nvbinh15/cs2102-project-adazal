/*
    -------TRIGGERS-------
*/

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

-- (3)  A coupon can only be used on an order whose total amount (before the coupon is applied) exceeds 
-- the minimum order amount.

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
        RAISE EXCEPTION 'A coupon can only be used on an order whose total amount (before the coupon is applied) exceeds the minimum order amount.';
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_coupon_trigger ON Orders;

CREATE TRIGGER order_coupon_trigger
BEFORE INSERT ON Orders
FOR EACH ROW EXECUTE FUNCTION check_order_coupon();
