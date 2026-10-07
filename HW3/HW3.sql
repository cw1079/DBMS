USE Assignment3;
#Question 1
#__________________________________________________________________

#Used 3 JOINs and they connect each power plant to its country, operator, and fuel type. DESC sorts the plants from highest capacity to lowest.
#PKs = CountryCode, OperatorID, FuelID
#FKs = CountryCode, OperatorID, FuelID

SELECT power_plants.PlantName,
       countries.CountryName,
       operators.OperatorName,
       fuel_types.FuelCategory,
       fuel_types.FuelName,
       power_plants.CapacityMW,
       power_plants.CommisionYear
FROM power_plants
JOIN countries
    ON power_plants.CountryCode = countries.CountryCode
JOIN operators
    ON power_plants.OperatorID = operators.OperatorID
JOIN fuel_types
    ON power_plants.FuelID = fuel_types.FuelID
ORDER BY power_plants.CapacityMW DESC;






#Question 2
#_________________________________________________

#Uses 2 tables and 1 JOIN. power_plants gives us the plant name/CountryCode. 
#generation_records gives the year and generation. WHERE limits it to 2024 and DESC puts highest generation first.
#-PK = PlantID
#FK = plantid
#Composite PK = (plantid, year) 

SELECT power_plants.PlantName, 
       power_plants.CountryCode,
       generation_records.year,
       generation_records.generationgwh
FROM power_plants
JOIN generation_records
    ON power_plants.PlantID = generation_records.plantid
WHERE generation_records.year = 2024
ORDER BY generation_records.generationgwh DESC;



#Question 3
#_______________________________________________
#Used 3 tables and 2 JOINs. One join gets generation and the other gets emissions. 
#I matched the plant and year so the generation and emissions belong to the same record
#PK = PlantID
#FKs = plantid
#Composite PKs = (plantid, year) in both record tables

SELECT power_plants.PlantName,
       power_plants.CountryCode,
       generation_records.year,
       generation_records.generationgwh,
       emission_metrics.co2emissionstonnes
FROM power_plants
JOIN generation_records
    ON power_plants.PlantID = generation_records.plantid
JOIN emission_metrics
    ON power_plants.PlantID = emission_metrics.plantid
    AND generation_records.year = emission_metrics.year
WHERE generation_records.year = 2024
ORDER BY emission_metrics.co2emissionstonnes ASC;

#Question 4
#_______________________________________________

#The CTE uses SUM() to add all generation for each operator. 
#GROUP BY creates one total per operator and then I join to operators to get the operator's name and headquarters country
#PKs = PlantID, OperatorID
#FKs = plantid, OperatorID
#Composite PK = (plantid, year)

WITH operator_generation AS (
    SELECT power_plants.OperatorID,
           SUM(generation_records.generationgwh) AS total_generation
    FROM power_plants
    JOIN generation_records
        ON power_plants.PlantID = generation_records.plantid
    GROUP BY power_plants.OperatorID
)
SELECT operators.OperatorName,
       operators.HeadquartersCountry,
       operator_generation.total_generation
FROM operators
JOIN operator_generation
    ON operators.OperatorID = operator_generation.OperatorID
ORDER BY operator_generation.total_generation DESC;



#Question 5
#_______________________________________________

#This uses 2 CTEs, the first one totals generation for each country. 
#The second CTE totals co2 emissions for each country. Then both are joined with countries to get the country name
#PKs = PlantID, CountryCode
#FKs = plantid, CountryCode
#Composite PKs = (plantid, year) 


WITH country_generation AS (
    SELECT power_plants.CountryCode,
           SUM(generation_records.generationgwh) AS total_generation
    FROM power_plants
    JOIN generation_records
        ON power_plants.PlantID = generation_records.plantid
    GROUP BY power_plants.CountryCode
),
country_emissions AS (
    SELECT power_plants.CountryCode,
           SUM(emission_metrics.co2emissionstonnes) AS total_emissions
    FROM power_plants
    JOIN emission_metrics
        ON power_plants.PlantID = emission_metrics.plantid
    GROUP BY power_plants.CountryCode
)
SELECT countries.CountryName,
       country_generation.total_generation,
       country_emissions.total_emissions
FROM countries
JOIN country_generation
    ON countries.CountryCode = country_generation.CountryCode
JOIN country_emissions
    ON countries.CountryCode = country_emissions.CountryCode
ORDER BY country_generation.total_generation DESC;
