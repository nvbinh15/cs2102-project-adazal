
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
    sid INTEGER,
    quantity INTEGER 
        CHECK (quantity >= 0),
    shipping_cost INTEGER 
        CHECK (shipping_cost >= 0),
    estimated_delivery_date DATE, --diff
    status TEXT DEFAULT "being processed"
        CHECK (status in ("being processed", "shipped", "delivered")),
    PRIMARY KEY (pid, sid, order_id),
    FOREIGN KEY (pid, sid) REFERENCES Products
);

CREATE TABLE Orders (
    order_id INTEGER,
    uid INTEGER,
    shipping_address TEXT,
    total_cost NUMERIC 
        CHECK (total_cost >= 0),
    PRIMARY KEY (order_id, uid)
);

CREATE TABLE HandleRefunds (
    rid INTEGER REFERENCES Refunds,
    eid INTEGER REFERENCES Employees,
    status TEXT CHECK (status IN ('processing', 'accepted', 'rejected')),
    date_of_acceptance DATE,
    date_of rejection DATE,
    reason_of_rejection TEXT,
    PRIMARY KEY (rid, eid)
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





