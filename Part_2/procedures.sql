-- (1) place_order

CREATE OR REPLACE PROCEDURE place_order( 
    user_id INTEGER, coupon_id INTEGER, shipping_address TEXT, 
    shop_ids INTEGER[], product_ids INTEGER[], sell_timestamps TIMESTAMP[], 
    quantities INTEGER[], shipping_costs NUMERIC[]
) AS $$
    
$$ LANGUAGE plpgsql;