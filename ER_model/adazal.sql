DROP TABLE IF EXISTS
Shops, Products, Manufacturers, Categories,
Employees, Users, Orders, CartItems, Comments, 
ArchivedComments, Replies, ArchivedReplies, Refunds,
Requests, HandlesRefunds, Coupons, Rewarded, Applies,
Complaints, CartItemComplaints, AboutCartItems, ShopComplaints,
AboutShops, OrderComplaints, AboutOrders, CommentComplaints,
AboutComments, Files, HandlesComplaints;

CREATE TABLE Shops (
    sid INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE Manufacturers (
    mid INTEGER PRIMARY KEY,
    name TEXT,
    country VARCHAR(128)
);

CREATE TABLE Categories (
    cid INTEGER PRIMARY KEY,
    name TEXT,
    parent_id INTEGER DEFAULT NULL REFERENCES Categories,
    CHECK (cid IS DISTINCT FROM parent_id)
);

CREATE TABLE Products (
    pid INTEGER,
    name TEXT,
    category INTEGER REFERENCES Categories ON UPDATE CASCADE,
    manufacturer_id INTEGER REFERENCES Manufacturers ON UPDATE CASCADE,
    description TEXT,
    shop_id INTEGER REFERENCES Shops ON DELETE CASCADE ON UPDATE CASCADE, 
    price NUMERIC CHECK (price >= 0),
    quantity INTEGER CHECK (quantity >= 0),
    PRIMARY KEY (pid)
);

CREATE TABLE Employees (
    eid INTEGER PRIMARY KEY,
    name TEXT, 
    monthly_salary NUMERIC CHECK (monthly_salary >= 0)
);

CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    name TEXT, 
    address TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE Orders (
    order_id INTEGER,
    -- User delete account then the order must have also deleted
    user_id INTEGER REFERENCES Users ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    -- Delete product_id as it only need to reference in CartItems
    total_shipping_cost NUMERIC CHECK (total_shipping_cost >= 0),
    shipping_address TEXT,
    PRIMARY KEY (order_id, user_id)
);

CREATE TABLE CartItems (
    cart_id INTEGER,
    product_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    -- Add user_id as an foregin key to CartItems reference Orders
    user_id INTEGER NOT NULL,
    status TEXT CHECK (status IN ('being processed', 'shipped', 'delivered')),
    quantity INTEGER CHECK (quantity > 0), 
    shipping_cost NUMERIC CHECK (shipping_cost >= 0),
    estimated_delivery_date DATE,
    delivery_date DATE,
    PRIMARY KEY (order_id, cart_id),
    FOREIGN KEY (product_id) REFERENCES Products(pid) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (order_id, user_id) REFERENCES Orders(order_id, user_id)
    ON DELETE CASCADE ON UPDATE CASCADE
    UNIQUE (user_id, order_id, product_id)
);

CREATE TABLE Refunds (
    rid INTEGER,
    refund_quantity INTEGER CHECK (refund_quantity > 0),
    cart_id INTEGER NOT NULL,
    FOREIGN KEY (user_id, order_id, product_id) REFERENCES CartItems(user_id, order_id, product_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (rid)
);

CREATE TABLE Requests (
    refund_id INTEGER REFERENCES Refunds ON UPDATE CASCADE ON DELETE CASCADE,
    user_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    date DATE,
    PRIMARY KEY (refund_id, user_id)
);

CREATE TABLE HandlesRefunds (
    refund_id INTEGER REFERENCES Refunds ON UPDATE CASCADE ON DELETE CASCADE,
    employee_id INTEGER REFERENCES Employees ON UPDATE CASCADE ON DELETE CASCADE,
    status TEXT CHECK (status IN ('processing', 'accepted', 'rejected')),
    reason_of_rejection TEXT,
    processed_date DATE,
    PRIMARY KEY (refund_id, employee_id),
    UNIQUE (refund_id),
    CHECK ((reason_of_rejection IS NULL) OR (status = 'rejected'))
);

CREATE TABLE Ratings (
    user_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    rating INTEGER CHECK (rating IN (1,2,3,4,5)),
    FOREIGN KEY (user_id, order_id, shop_id, product_id) 
    REFERENCES CartItems (user_id, order_id, shop_id, product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, shop_id, product_id)
    -- Add order_id to make foreign key -> Can capture condition rating after buying
);

CREATE TABLE ArchivedRatings (
    user_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    rating INTEGER CHECK (rating IN (1,2,3,4,5)),
    FOREIGN KEY (user_id, order_id, shop_id, product_id) 
    REFERENCES CartItems (user_id, order_id, shop_id, product_id) ON UPDATE CASCADE,
    PRIMARY KEY (user_id, shop_id, product_id, created_timestamp)
    -- not on delete cascade to archive the data
)

CREATE TABLE Comments (
    user_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    FOREIGN KEY (user_id, order_id, shop_id, product_id) 
    REFERENCES CartItems (user_id, order_id, shop_id, product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, shop_id, product_id)
); -- Add order_id to make foreign key -> Can capture condition comment after buying

CREATE TABLE ArchivedComments (
    user_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    FOREIGN KEY (user_id, order_id, shop_id, product_id) 
    REFERENCES CartItems (user_id, order_id, shop_id, product_id) ON UPDATE CASCADE,
    PRIMARY KEY (user_id, shop_id, product_id, created_timestamp)
); -- not on delete cascade to archive the data

CREATE TABLE Replies (
    comment_id INTEGER,
    order_id INTEGER, 
    shop_id INTEGER,
    product_id INTEGER,
    reply_id INTEGER REFERENCES Users ON UPDATE CASCADE ON DELETE CASCADE,
    content TEXT,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Comment must belong to people that have bought the product
    FOREIGN KEY (comment_id, order_id, shop_id, product_id) 
    REFERENCES CartItems(user_id, order_id, shop_id, product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (comment_id, shop_id, product_id, reply_id)
);

CREATE TABLE ArchivedReplies (
    comment_id INTEGER,
    order_id INTEGER, 
    shop_id INTEGER,
    product_id INTEGER,
    reply_id INTEGER REFERENCES Users ON UPDATE CASCADE ON DELETE CASCADE,
    content TEXT,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comment_id, order_id, shop_id, product_id) 
    REFERENCES CartItems(user_id, order_id, shop_id, product_id) ON UPDATE CASCADE,
    PRIMARY KEY (comment_id, shop_id, product_id, reply_id, created_timestamp)
    
); -- not on delete cascade to archive the data

CREATE TABLE Coupons (
    cid INTEGER PRIMARY KEY,
    reward NUMERIC CHECK (reward >= 0),
    validity_period INTERVAL,
    minimun_order_value NUMERIC CHECK (minimun_order_value >= 0)
);

CREATE TABLE Rewarded (
    user_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    coupon_id INTEGER REFERENCES Coupons ON UPDATE CASCADE ON DELETE CASCADE,
    issued_date DATE,
    quantity INTEGER CHECK (quantity >= 0),
    PRIMARY KEY (user_id, coupon_id)
);

CREATE TABLE Applies (
    user_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    order_id INTEGER REFERENCES Orders ON UPDATE CASCADE ON DELETE CASCADE,
    coupon_id INTEGER REFERENCES Coupons ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (order_id)
);

CREATE TABLE Complaints (
    cid INTEGER PRIMARY KEY,
    status TEXT CHECK (status IN ('pending', 'being processed', 'addressed'))
);

CREATE TABLE CartItemComplaints (
    cid INTEGER PRIMARY KEY REFERENCES Complaints ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AboutCartItems (
    cid INTEGER PRIMARY KEY REFERENCES CartItemComplaints ON DELETE CASCADE ON UPDATE CASCADE,
    shop_id INTEGER REFERENCES CartItems ON DELETE CASCADE ON UPDATE CASCADE,
    product_id INTEGER REFERENCES CartItems ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ShopComplaints (
    cid INTEGER PRIMARY KEY REFERENCES Complaints ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AboutShops (
    cid INTEGER PRIMARY KEY REFERENCES ShopComplaints ON DELETE CASCADE ON UPDATE CASCADE,
    shop_id INTEGER REFERENCES Shops ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OrderComplaints (
    cid INTEGER PRIMARY KEY REFERENCES Complaints ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AboutOrders (
    cid INTEGER PRIMARY KEY REFERENCES OrderComplaints ON DELETE CASCADE ON UPDATE CASCADE,
    order_id INTEGER REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CommentComplaints (
    cid INTEGER PRIMARY KEY REFERENCES Complaints ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AboutComments (
    cid INTEGER PRIMARY KEY REFERENCES CommentComplaints ON DELETE CASCADE ON UPDATE CASCADE,
    user_id INTEGER REFERENCES Comments (user_id) ON UPDATE CASCADE,
    shop_id INTEGER REFERENCES Comments (shop_id) ON DELETE CASCADE ON UPDATE CASCADE,
    product_id INTEGER REFERENCES Comments (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AboutComments (
    cid INTEGER PRIMARY KEY REFERENCES CommentComplaints ON DELETE CASCADE ON UPDATE CASCADE,
    user_id INTEGER,
    shop_id INTEGER,
    product_id INTEGER,
    FOREIGN KEY (user_id, shop_id, product_id) REFERENCES Comments (user_id, shop_id, product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Files (
    user_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    complaint_id INTEGER REFERENCES Complaints ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, complaint_id)
);

CREATE TABLE HandlesComplaints (
    user_id INTEGER,
    complaint_id INTEGER,
    FOREIGN KEY (user_id, complaint_id) REFERENCES Files (user_id, complaint_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    employee_id INTEGER REFERENCES Employees ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, complaint_id, employee_id)
);
