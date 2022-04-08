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
    order_id := (SELECT MAX(id) FROM Orders) + 1;
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