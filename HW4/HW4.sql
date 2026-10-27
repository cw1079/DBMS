#Question 1: Retrieve the mission name, rocket name, 
#organization name, launch site name, destination, launch year, and outcome
-- JOIN connects missions to their rockets, organizations and launch sites
-- Primary Keys: missions.missionid, rockets.rocketid, organizations.orgid and launch_sites.siteid
-- Foreign Keys: missions.rocketid, missions.siteid and rockets.orgid
-- ORDER BY sorts by newest launch year first, then mission name A-Z
SELECT missions.missionname,
       rockets.rocketname,
       organizations.orgname,
       launch_sites.sitename,
       missions.destination,
       missions.launchyear,
       missions.outcome
FROM missions
JOIN rockets
    ON missions.rocketid = rockets.rocketid
JOIN organizations
    ON rockets.orgid = organizations.orgid
JOIN launch_sites
    ON missions.siteid = launch_sites.siteid
ORDER BY missions.launchyear DESC,
         missions.missionname ASC;
         
#Question 2:
#Retrieve the mission name, rocket name, payload name, 
#payload type, and payload mass (in kg) for all payloads launched in 2024
-- Primary Keys: payloads.payloadid, missions.missionid, rockets.rocketid
-- Foreign Keys: payloads.missionid and missions.rocketid
-- JOIN connects payloads to their missions and rockets and WHERE only includes missions launched in 2024
-- ORDER BY sorts payloads from heaviest to lightest
SELECT missions.missionname,
       rockets.rocketname,
       payloads.payloadname,
       payloads.payloadtype,
       payloads.masskg
FROM payloads
JOIN missions
    ON payloads.missionid = missions.missionid
JOIN rockets
    ON missions.rocketid = rockets.rocketid
WHERE missions.launchyear = 2024
ORDER BY payloads.masskg DESC;

#Question 3:
#Retrieve all launch sites along with their matching mission names, 
#rockets, and launch years for missions that took place in 2024
-- Primary Keys: launch_sites.siteid, missions.missionid and rockets.rocketid
-- Foreign Keys: missions.siteid and missions.rocketid
-- LEFT JOIN includes launch sites even if they have no 2024 missions
-- Null values are shown
-- ORDER BY sorts launch sites alphabetically
SELECT launch_sites.sitename,
       missions.missionname,
       rockets.rocketname,
       missions.launchyear
FROM launch_sites
LEFT JOIN missions
    ON launch_sites.siteid = missions.siteid
    AND missions.launchyear = 2024
LEFT JOIN rockets
    ON missions.rocketid = rockets.rocketid
ORDER BY launch_sites.sitename ASC;


#Question 4:
#Common Table Expression (CTE) to calculate 
#the total payload mass (in kg) deployed by each organization across all missions
-- Primary Keys: organizations.orgid, rockets.rocketid, missions.missionid, and payloads.payloadid
-- Foreign Keys: rockets.orgid, missions.rocketid, payloads.missionid
-- WITH makes a CTE to calculate total payload mass by organization
-- ORDER BY sorts from highest to lowest total payload mass
-- JOIN connects organizations, rockets, missions, and payloads
-- SUM adds payload masses, and also GROUP BY groups them by organization
WITH OrganizationPayload AS (
    SELECT organizations.orgid,
           SUM(payloads.masskg) AS TotalPayloadMass
    FROM organizations
    JOIN rockets
        ON organizations.orgid = rockets.orgid
    JOIN missions
        ON rockets.rocketid = missions.rocketid
    JOIN payloads
        ON missions.missionid = payloads.missionid
    GROUP BY organizations.orgid
)

SELECT organizations.orgname,
       organizations.headquarterscountry,
       organizations.orgtype,
       OrganizationPayload.TotalPayloadMass
FROM organizations
JOIN OrganizationPayload
    ON organizations.orgid = OrganizationPayload.orgid
ORDER BY OrganizationPayload.TotalPayloadMass DESC;

#Question 5:
#Writing two CTEs
-- Primary Keys: countries.countrycode, launch_sites.siteid, missions.missionid, and payloads.payloadid
-- Foreign Keys: launch_sites.countrycode, missions.siteid and payloads.missionid
-- First CTE counts the number of missions launched from each country
-- The second CTE calculates total payload mass launched from each country
-- COUNT counts missions and SUM adds the payload masses
-- LEFT JOIN includes countries without missions or payloads
-- ORDER BY sorts countries from highest to lowest total payload mass
WITH CountryMissions AS (
    SELECT launch_sites.countrycode,
           COUNT(missions.missionid) AS TotalMissions
    FROM launch_sites
    JOIN missions
        ON launch_sites.siteid = missions.siteid
    GROUP BY launch_sites.countrycode
),

CountryPayload AS (
    SELECT launch_sites.countrycode,
           SUM(payloads.masskg) AS TotalPayloadMass
    FROM launch_sites
    JOIN missions
        ON launch_sites.siteid = missions.siteid
    JOIN payloads
        ON missions.missionid = payloads.missionid
    GROUP BY launch_sites.countrycode
)

SELECT countries.countryname,
       COALESCE(CountryMissions.TotalMissions, 0) AS TotalMissions,
       COALESCE(CountryPayload.TotalPayloadMass, 0) AS TotalPayloadMass
FROM countries
LEFT JOIN CountryMissions
    ON countries.countrycode = CountryMissions.countrycode
LEFT JOIN CountryPayload
    ON countries.countrycode = CountryPayload.countrycode
ORDER BY TotalPayloadMass DESC;








