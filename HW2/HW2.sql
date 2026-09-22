#----------------------------------
##How the tables are created:
#----------------------------------
CREATE DATABASE IF NOT EXISTS Assignment2;
USE Assignment2;

#1. Baristas Table
#Stores baristas and their experience levels.
CREATE TABLE baristas (
    baristaID INT PRIMARY KEY,               -- Primary Key
    name VARCHAR(100) NOT NULL,
    experience_level VARCHAR(50) NOT NULL
);

#2. Shops Table
#Stores details about different coffee shop locations and cities.
CREATE TABLE shops (
    shopID INT PRIMARY KEY,                  -- Primary Key
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

#3. Employs Table (Junction Table)
#Manages the relationship between baristas and shops.
CREATE TABLE employs (
    baristaID INT,
    shopID INT,
    PRIMARY KEY (baristaID, shopID),         -- Composite Primary Key
    FOREIGN KEY (baristaID) REFERENCES baristas(baristaID) ON DELETE CASCADE, -- Foreign Key to baristas
    FOREIGN KEY (shopID) REFERENCES shops(shopID) ON DELETE CASCADE        -- Foreign Key to shops
);

#4. Pastries Table
#Stores information on pastries, muffins, and bakery
CREATE TABLE pastries (
    pastryID INT PRIMARY KEY,                -- Primary Key
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(5,2) NOT NULL
);

#5. Offers Table (Junction Table)
#Tracks which shops offer specific pastries and the date they were added.
CREATE TABLE offers (
    shopID INT,
    pastryID INT,
    date_added DATE NOT NULL,
    PRIMARY KEY (shopID, pastryID),          -- Composite Primary Key
    FOREIGN KEY (shopID) REFERENCES shops(shopID) ON DELETE CASCADE,       -- Foreign Key to shops
    FOREIGN KEY (pastryID) REFERENCES pastries(pastryID) ON DELETE CASCADE -- Foreign Key to pastries
);
#-----------------------------------------------------



#-------------------------
#Questions
#---------------------------
#1.Find the average price of pastries for each category from the pastries table.
SELECT category, AVG(price) AS average_price
FROM pastries
GROUP BY category;


#2. Find the total number of baristas at each experience level from the baristas table.
SELECT experience_level, COUNT(*) AS total_baristas
FROM baristas
GROUP BY experience_level;


#3. Count the total number of shops located in each city from the shops table.
SELECT city, COUNT(*) AS shop_count
FROM shops
GROUP BY city;


#4. Find the maximum price among pastries for each category from the pastries table.
SELECT category, MAX(price) AS max_price
FROM pastries
GROUP BY category;


#5. Count how many pastries have been added by each shop using the shopID column from the offers table.
SELECT shopID, COUNT(pastryID) AS pastry_count
FROM offers
GROUP BY shopID;


#6. Find the name, category, and price of any pastry whose price matches the maximum price within its category.
SELECT name, category, price
FROM pastries p
WHERE price = (
    SELECT MAX(price)
    FROM pastries
    WHERE category = p.category
);


#7. Find the unique shop IDs from the offers table that have offered at least one pastry whose price is strictly greater than the overall average price of all pastries.
SELECT DISTINCT shopID
FROM offers
WHERE pastryID IN (
    SELECT pastryID
    FROM pastries
    WHERE price > (
        SELECT AVG(price)
        FROM pastries
    )
);


#8. Find the shop ID and pastry ID for the records in the offers table that have the earliest date_added (minimum date).
SELECT shopID, pastryID, date_added
FROM offers
WHERE date_added = (SELECT MIN(date_added) FROM offers);


#9. Find the shop ID(s) that offer the highest number of pastries, utilizing a subquery to evaluate the maximum count per shop.
SELECT shopID
FROM offers
GROUP BY shopID
HAVING COUNT(pastryID) = (
    SELECT MAX(pastry_count)
    FROM (
        SELECT COUNT(pastryID) AS pastry_count
        FROM offers
        GROUP BY shopID
    ) AS shop_counts
);


#10. Find the names of baristas who work at shops located in 'Seattle' using nested subqueries.
SELECT name
FROM baristas
WHERE baristaID IN (
    SELECT baristaID
    FROM employs
    WHERE shopID IN (
        SELECT shopID
        FROM shops
        WHERE city = 'Seattle'
    )
);


