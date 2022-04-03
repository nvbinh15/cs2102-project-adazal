-- (1) place_order

CREATE OR REPLACE PROCEDURE place_order( 
    user_id INTEGER, coupon_id INTEGER, shipping_address TEXT, 
    shop_ids INTEGER[], product_ids INTEGER[], sell_timestamps TIMESTAMP[], 
    quantities INTEGER[], shipping_costs NUMERIC[]
) AS $$
DECLARE
    payment_amount NUMERIC;
    order_id INTEGER;
    i INTEGER;
    price NUMERIC;
BEGIN
    INSERT INTO Orders AS O
    VALUES (DEFAULT, user_id, NULL, shipping_address, 0)
    RETURNING O.id INTO order_id;
    payment_amount := 0;

    FOR i IN 1..array_upper(product_ids)
    LOOP
        INSERT INTO Orderline
        VALUES (order_id, shop_ids[i], product_ids[i], sell_timestamps[i], quantities[i], shipping_costs[i], 'being_processed', NULL);
        
        UPDATE Sells AS S
        SET S.quantity = S.quantity - quantities[i]
        WHERE ROW(S.shop_id, S.product_id, S.sell_timestamp) = ROW(shop_ids[i], product_ids[i], sell_timestamps[i]);
        
        price := (
            SELECT S.price
            FROM Sells S
            WHERE ROW(S.shop_id, S.product_id, S.sell_timestamp) = ROW(shop_ids[i], product_ids[i], sell_timestamps[i])
        );
        payment_amount := payment_amount + quantities[i] * price + shipping_costs[i];
    END LOOP;

    UPDATE Orders AS O
    SET O.payment_amount = payment_amount - (
        SELECT C.reward_amount
        FROM Coupon_batch C
        WHERE C.id = coupon_id
    ), O.coupon_id = coupon_id
    WHERE O.id = order_id;
END;
$$ LANGUAGE plpgsql;