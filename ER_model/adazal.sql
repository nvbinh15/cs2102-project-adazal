DROP TABLE IF EXISTS
Shops, Products, Manufacturers, Categories,
Employees, Users, Orders;

CREATE TABLE Shops (
    sid INTEGER PRIMARY KEY,
    name TEXT
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
    PRIMARY KEY (pid, shop_id)
);

CREATE TABLE Manufacturers (
    mid INTEGER PRIMARY KEY,
    name TEXT,
    country VARCHAR(128) -- varchar(128) instead of TEXT SINCE no country has to long name
);

CREATE TABLE Categories (
    cid INTEGER PRIMARY KEY,
    name TEXT,
    parent_id INTEGER DEFAULT NULL REFERENCES Categories,
    CHECK (cid IS DISTINCT FROM parent_id)
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

CREATE TABLE CartItems (
    shop INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    product INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    quantity INTEGER CHECK (quantity > 0),
    shipping_cost NUMERIC CHECK (shipping_cost >= 0),
    delivery_date DATE,
    PRIMARY KEY (product, shop)
);

CREATE TABLE Orders (
    user INTEGER REFERENCES Users ON DELETE CASCADE ON UPDATE CASCADE,
    shop INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    product INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    total_shipping_cost NUMERIC CHECK (total_shipping_cost >= 0),
    shipping_address TEXT,
    status TEXT CHECK (status IN ('being processed', 'shipped', 'delivered')),
    estimated_delivery_date DATE,
    PRIMARY KEY (user, shop, product)
);

CREATE TABLE Comments (
    user INTEGER REFERENCES Users ON DELETE CASCADE ON UPDATE CASCADE,
    shop INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    product INTEGER REFERENCES Products ON DELETE CASCADE ON UPDATE CASCADE,
    created_timestamp CURRENT_TIMESTAMP,
    content TEXT,
    rating INTEGER CHECK (rating IN (1,2,3,4,5))
    PRIMARY KEY (user, shop, product, created_timestamp)
);

CREATE TABLE ArchivedComments (
    user INTEGER REFERENCES Users,
    shop INTEGER REFERENCES Products,
    product INTEGER REFERENCES Products,
    created_timestamp CURRENT_TIMESTAMP,
    content TEXT,
    rating INTEGER CHECK (rating IN (1,2,3,4,5))
    PRIMARY KEY (user, shop, product, created_timestamp)
);

