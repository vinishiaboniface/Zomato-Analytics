Create Database Zomato;
Use zomato;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zomata Sql_Datasets.csv'
     INTO TABLE `zomata Sql_Datasets`
     FIELDS TERMINATED BY ','
     ENCLOSED BY '"'
     LINES TERMINATED BY '\n'
     IGNORE 1 rows;
     
SELECT * FROM `zomata Sql_Datasets`;

-- 1. Build a country Map Table
CREATE TABLE Country_Map (
    CountryCode INT PRIMARY KEY,
    CountryName VARCHAR(100)
);

 SELECT * FROM Country_Map;
 
INSERT INTO Country_Map (CountryCode, CountryName)
VALUES
    (1, 'India'),
    (216, 'United States'),
    (215, 'United Kingdom'),
    (37, 'Canada'),
    (14, 'Australia'),
    (214, 'UAE'),
    (189, 'South Africa'),
    (148, 'New Zealand'),
    (30, 'Brazil'),
    (184, 'Singapore'),
    (94, 'Indonesia'),
    (162, 'Phillipines'),
    (166, 'Qatar'),
    (191, 'Sri Lanka'),
    (208, 'Turkey');
    

SELECT z.ï»¿RestaurantID, z.RestaurantName, z.City, cm.CountryName, z.Average_Cost_for_two, z.Rating
FROM `zomata Sql_Datasets` z
JOIN Country_Map cm ON z.CountryCode = cm.CountryCode;

####################################################################################################
-- 2. Build a Calendar Table using the Column Datekey
 --  Add all the below Columns in the Calendar Table using the Formulas.
  
CREATE TABLE Calendar_table (
    DateKey text,
    Year INT,
    MonthNo INT,
    MonthFullname VARCHAR(15),
    Quarter VARCHAR(2),
    YearMonth VARCHAR(10),
    WeekdayNo INT,
    WeekdayName VARCHAR(10),
    FinancialMonth VARCHAR(5),
    FinancialQuarter VARCHAR(3)
);


select * from Calendar_table;
-- AA.Year
INSERT INTO Calendar_table (DateKey, Year)
SELECT Datekey_Opening AS DateKey,
YEAR(STR_TO_DATE(Datekey_Opening, '%Y_%m_%d')) AS Year
FROM `zomata Sql_Datasets`
WHERE Datekey_Opening IS NOT NULL;
commit;

-- B.Monthno
UPDATE Calendar_table
SET MonthNo = MONTH(STR_TO_DATE(DateKey, '%Y_%m_%d'))
WHERE DateKey IS NOT NULL;
commit;
SET SQL_SAFE_UPDATES = 0;

-- C.Monthfullname
UPDATE Calendar_table
SET Monthfullname = MONTHNAME(STR_TO_DATE(DateKey, '%Y_%m_%d'))
WHERE DateKey IS NOT NULL;
commit;

SELECT * FROM Calendar_table;

-- D.Quarter(Q1,Q2,Q3,Q4)
UPDATE calendar_table
SET Quarter = CASE
WHEN MONTH(STR_TO_DATE(DateKey, '%Y_%m_%d')) IN (1, 2, 3) THEN 'Q1'
WHEN MONTH(STR_TO_DATE(DateKey, '%Y_%m_%d')) IN (4, 5, 6) THEN 'Q2'
WHEN MONTH(STR_TO_DATE(DateKey, '%Y_%m_%d')) IN (7, 8, 9) THEN 'Q3'
WHEN MONTH(STR_TO_DATE(DateKey, '%Y_%m_%d')) IN (10, 11, 12) THEN 'Q4'
END
WHERE DateKey IS NOT NULL;
commit;

SELECT * FROM calendar_table;

-- E. YearMonth ( YYYY-MMM)
UPDATE Calendar_table
SET YearMonth = DATE_FORMAT(STR_TO_DATE(DateKey, '%Y_%m_%d'), '%Y-%b')
WHERE DateKey IS NOT NULL;
commit;

SELECT * FROM Calendar_table;
-- F. Weekdayno
UPDATE Calendar_table
SET WeekdayNo = DAYOFWEEK(STR_TO_DATE(DateKey, '%Y_%m_%d')) - 1
WHERE DateKey IS NOT NULL;
commit;

-- G.Weekdayname
UPDATE Calendar_table
SET WeekdayName = DAYNAME(STR_TO_DATE(DateKey, '%Y_%m_%d'))
WHERE DateKey IS NOT NULL;
commit;

-- H.FinancialMOnth ( April = FM1, May= FM2  …. March = FM12)
UPDATE Calendar_table
SET FinancialMonth = CASE 
    WHEN MonthNo = 4 THEN 'FM1'
    WHEN MonthNo = 5 THEN 'FM2'
    WHEN MonthNo = 6 THEN 'FM3'
    WHEN MonthNo = 7 THEN 'FM4'
    WHEN MonthNo = 8 THEN 'FM5'
    WHEN MonthNo = 9 THEN 'FM6'
    WHEN MonthNo = 10 THEN 'FM7'
    WHEN MonthNo = 11 THEN 'FM8'
    WHEN MonthNo = 12 THEN 'FM9'
    WHEN MonthNo = 1 THEN 'FM10'
    WHEN MonthNo = 2 THEN 'FM11'
    WHEN MonthNo = 3 THEN 'FM12'
END
WHERE DateKey IS NOT NULL;
commit;

-- I. Financial Quarter ( Quarters based on Financial Month)

UPDATE Calendar_table
SET FinancialQuarter = CASE 
    WHEN FinancialMonth IN ('FM1', 'FM2', 'FM3') THEN 'FQ1'
    WHEN FinancialMonth IN ('FM4', 'FM5', 'FM6') THEN 'FQ2'
    WHEN FinancialMonth IN ('FM7', 'FM8', 'FM9') THEN 'FQ3'
    WHEN FinancialMonth IN ('FM10', 'FM11', 'FM12') THEN 'FQ4'
END
WHERE DateKey IS NOT NULL;

select * from calendar_table;
#############################
-- Truncate code
 -- UPDATE calendar_table
-- SET Quarter = NULL
-- WHERE Quarter IS NOT NULL;
##################################################################################################################

-- 3.Find the Numbers of Resturants based on City and Country.

select * from `zomata sql_datasets`;

SELECT 
    Country_Map.Countryname,
    `zomata sql_datasets`.City,
    COUNT(`zomata sql_datasets`.ï»¿RestaurantID) AS Number_of_Restaurants
FROM 
    `zomata sql_datasets`
JOIN 
    Country_Map ON `zomata sql_datasets`.CountryCode = Country_Map.Countrycode
GROUP BY 
    Country_Map.Countryname, `zomata sql_datasets`.City
ORDER BY 
    Number_of_Restaurants DESC;
commit;
##########################################################################################################
-- 4. Numbers of Resturants opening based on Year , Quarter , Month

SELECT c.Year, 
c.FinancialQuarter AS Quarter, 
c.MonthFullname AS Month,
COUNT(z.Datekey_Opening) AS NumberOfRestaurantsOpened
FROM calendar_table c
JOIN `zomata sql_datasets` z ON c.Datekey = z.Datekey_Opening
GROUP BY c.Year, c.FinancialQuarter, c.MonthFullname
ORDER BY c.Year, c.FinancialQuarter, c.MonthFullname;
commit;
###########################################################################################################
-- 5. Count of Resturants based on Average Ratings
SELECT Rating, COUNT(*) AS NumberOfRestaurants
FROM `zomata sql_datasets`
GROUP BY Rating
Order BY Rating;
#####################################################################################################
-- 6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT 
    CASE
        WHEN Average_Cost_for_two < 500 THEN 'Under 500'
        WHEN Average_Cost_for_two BETWEEN 500 AND 999 THEN '500 - 999'
        WHEN Average_Cost_for_two BETWEEN 1000 AND 1999 THEN '1000 - 1999'
        WHEN Average_Cost_for_two BETWEEN 2000 AND 2999 THEN '2000 - 2999'
        ELSE '3000 and above'
    END AS Price_Bucket,
    COUNT(`ï»¿RestaurantID`) AS Restaurant_Count
FROM `zomata sql_datasets`
WHERE Average_Cost_for_two IS NOT NULL
GROUP BY Price_Bucket
ORDER BY Restaurant_Count DESC;

##########################################################################################
-- 7.Percentage of Resturants based on "Has_Table_booking"

SELECT Has_Table_booking, COUNT(*) AS Restaurant_Count, 
ROUND((COUNT(*) / (SELECT COUNT(*) FROM `zomata sql_datasets`) * 100), 2) AS Percentage
FROM `zomata sql_datasets`
GROUP BY Has_Table_booking;
############################################################################################
-- 8.Percentage of Resturants based on "Has_Online_delivery"
SELECT Has_Online_delivery, COUNT(*) AS Restaurant_Count,
ROUND((COUNT(*) / (SELECT COUNT(*) FROM `zomata sql_datasets`) * 100), 2) AS Percentage
FROM `zomata sql_datasets`
GROUP BY Has_Online_delivery;

#############################################################################################
-- 9. Develop Charts based on Cusines, City, Ratings
SELECT Cuisines, COUNT(*) AS Restaurant_Count
FROM `zomata sql_datasets`
GROUP BY Cuisines
ORDER BY Restaurant_Count DESC
LIMIT 10; 
-- Show top 10 cuisines
