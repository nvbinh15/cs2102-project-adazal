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
        WHERE S.product_id = OLD.id
    );
    IF num_of_products < 1 THEN
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS shop_products_trigger ON Shop;

CREATE TRIGGER shop_products_trigger
BEFORE INSERT ON Shop
DEFERRABLE INITIALLY IMMEDIATE
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
        WHERE O.order_id = OLD.id
    );
    IF num_of_products < 1 THEN
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_products_trigger ON Orders;

CREATE TRIGGER order_products_trigger
BEFORE INSERT ON Orders
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW EXECUTE FUNCTION check_order_products();

-- (3)  A coupon can only be used on an order whose total amount (before the coupon is applied) exceeds 
-- the minimum order amount.

CREATE OR REPLACE FUNCTION check_order_coupon()
RETURNS TRIGGER AS $$
DECLARE
    minimum_amount INTEGER;
BEGIN
    minimum_amount := (
        SELECT C.min_order_amount
        FROM Coupon_batch C
        WHERE C.id = OLD.coupon_id
    );
    IF OLD.payment_amount < minimum_amount THEN
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_coupon_trigger ON Orders;

CREATE TRIGGER order_coupon_trigger
BEFORE INSERT ON Orders
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW EXECUTE FUNCTION check_order_coupon();
