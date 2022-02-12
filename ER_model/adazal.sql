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
    category INTEGER REFERENCES Categories,
    manufacturer INTEGER REFERENCES Manufacturers,
    description TEXT,
    shop INTEGER REFERENCES Shops ON DELETE CASCADE ON UPDATE CASCADE, 
    price NUMERIC,
    quantity INTEGER CHECK (integer >= 0),
    PRIMARY KEY (pid, shop) -- shop?
);

CREATE TABLE Manufacturers (
    mid INTEGER PRIMARY KEY,
    name TEXT,
    country VARCHAR(128) -- varchar(128) instead of TEXT SINCE no country has to long name
);

CREATE TABLE Categories (
    cid INTEGER PRIMARY KEY,
    name TEXT,
    parent_category INTEGER DEFAULT NULL REFERENCES Categories
);

CREATE TABLE Employees (
    eid INTEGER PRIMARY KEY,
    name TEXT, 
    monthly_salary NUMERIC
);

CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    name TEXT,
    address TEXT
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
    content TEXT,
    PRIMARY KEY (user, shop, product)
);


