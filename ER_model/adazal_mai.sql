
CREATE TABLE Shops (
    sid INTEGER PRIMARY KEY,
    name TEXT 
);

CREATE TABLE Products (
    pid INTEGER,
    name TEXT,
    sid INTEGER NOT NULL REFERENCES Shops
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    cid INTEGER NOT NULL REFERENCES Categories,
    mid INTEGER NOT NULL REFERENCES Manufacturers
        ON DELETE CASCADE
        ON UPDATE CASCADE, 
    description TEXT,
    price INTEGER 
        CHECK (price >= 0),
    quantity INTEGER
        CHECK (quantity >= 0),
    PRIMARY KEY (pid, sid) -- diff
);

CREATE TABLE Manufacturers (
    mid INTEGER PRIMARY KEY,
    name TEXT,
    country VARCHAR(100)
);

CREATE TABLE Categories (
    cid  INTEGER PRIMARY KEY,
    parent_cid INTEGER DEFAULT NULL REFERENCES Categories
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE,
    name TEXT,
    PRIMARY KEY (cid),
    CHECK (cid IS DISTINCT FROM parent_cid)
);

CREATE TABLE Employees (
    eid INTEGER PRIMARY KEY,
    name VARCHAR(100), 
    monthly_salary NUMERIC 
        CHECK (monthly_salary >= 0)
);

CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
);

CREATE TABLE CartItems (
    order_id INTEGER REFERENCES Order
        ON DELETE CASCADE,
    pid INTEGER,
    quantity INTEGER 
        CHECK (quantity >= 0),
    shipping_cost INTEGER 
        CHECK (shipping_cost >= 0),
    estimated_delivery_date DATE, --diff
    status TEXT DEFAULT "being processed"
        CHECK (status in ("being processed", "shipped", "delivered")),
    PRIMARY KEY (pid, order_id),
    FOREIGN KEY (pid) REFERENCES Products
);

CREATE TABLE Orders (
    order_id INTEGER,
    uid INTEGER,
    shipping_address TEXT,
    total_cost NUMERIC 
        CHECK (total_cost >= 0),
    PRIMARY KEY (order_id)
);

CREATE TABLE HandleRefunds (
    rid INTEGER REFERENCES Refunds,
    eid INTEGER REFERENCES Employees,
    status TEXT CHECK (status IN ('processing', 'accepted', 'rejected')),
    processed_date DATE,
    reason_of_rejection TEXT,
    PRIMARY KEY (rid, eid),
    CHECK ((reason_of_rejection IS NULL) OR (status = 'rejected'))
);

CREATE TABLE Refunds (
    rid INTEGER PRIMARY KEY,
    pid INTEGER,
    sid INTEGER,
    order_id INTEGER,
    uid INTEGER REFERENCES Users,
    request_date DATE,
    quantity INTEGER 
        CHECK (quantity >= 0)
    FOREIGN KEY (pid, sid, order_id) REFERENCES CartItems,
); --cannot capture request_date within 30 CartItems date, Refunds.quantity <= CartItems.quantity (TRIGGERS)

CREATE TABLE Comments (
    uid INTEGER REFERENCES Users
        ON UPDATE CASCADE,
    pid INTEGER
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    sid INTEGER
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    order_id INTEGER,
    content TEXT,
    rating INTEGER 
        CHECK (rating in (1,2,3,4,5)),
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (uid, pid, sid, order_id),
    FOREIGN KEY (pid, sid, order_id) REFERENCES CartItems
    
) -- cannot capture Each time a user purchases a product from a shop

CREATE TABLE ArchivedComments (
    uid INTEGER REFERENCES Users,
    pid INTEGER,
    sid INTEGER,
    order_id INTEGER,
    content TEXT,
    rating INTEGER 
        CHECK (rating in (1,2,3,4,5)),
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (uid, pid, sid, order_id),
    FOREIGN KEY (pid, sid, order_id) REFERENCES CartItems
)

CREATE TABLE Replies (
    user1_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    shop_id INTEGER REFERENCES Shops ON DELETE CASCADE ON UPDATE CASCADE,
    product_id INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    user2_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    content TEXT,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user1_id, shop_id, product_id, user2_id, created_timestamp)
); -- created_timestamps should also be part of PK

CREATE TABLE ArchivedReplies (
    user1_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    shop_id INTEGER REFERENCES Products ON UPDATE CASCADE,
    product_id INTEGER REFERENCES Products ON UPDATE CASCADE,
    user2_id INTEGER REFERENCES Users ON UPDATE CASCADE,
    content TEXT,
    created_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user1_id, shop_id, product_id, user2_id, created_timestamp)
); 

/*
Note ER diagram:
1) CartItems must have quantity
2) Order don’t have estimated deli date
3) Employee: edi -> eid
4) Refunds: request_date, quantity
5) Refunds -> Users: total participation
6) User -> Comments/Replies: key constraint
7) Comments/Replies/Archived.. -> User: total participation
8) User – Replies – Comments: created_time_stamps part of PK (can replies many)


Constraints ignored by ER: 
1) The effects of coupons are ignored during product refunds
2) Request date within 30 days refund




Constraints ignored by schema:
1) “Each time a user purchases a product from a shop”: can only comment/rate after purchase
2) Request date within 30 days refund
3) Refund quantity <= CartItems quantity

*/






