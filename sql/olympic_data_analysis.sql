-- =========================================
-- Olympic Data Analysis Project
-- Dataset: athlete_events & noc_regions
-- Description:
-- This project analyzes Olympic history to understand trends
-- in participation, sports, athletes, and medal performance
-- across countries and years using SQL.
-- =========================================

-- SECTION 1: Database & Tables
-- ===============================
-- create database,
CREATE DATABASE IF NOT EXISTS olympics_db;
USE olympics_db;

-- Drop table if it already exists
DROP TABLE IF EXISTS athlete_events;

-- create database, tables here

-- create  tables here
CREATE TABLE athlete_events (
    ID INT null ,
    Name VARCHAR(255),
    Sex VARCHAR(20),
    Age INT,
    Height VARCHAR(50),
    Weight VARCHAR(50),
    Team VARCHAR(255),
    NOC VARCHAR(50),
    Games VARCHAR(255),
    Year INT,
    Season VARCHAR(50),
    City VARCHAR(100),
    Sport VARCHAR(200),
    Event VARCHAR(200),
    Medal VARCHAR(50)
);

-- Load data from CSV (secure-file-priv folder)
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/athlete_events.csv'
INTO TABLE athlete_events
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
 @ID, @Name, @Sex, @Age, @Height, @Weight, @Team, @NOC,
 @Games, @Year, @Season, @City, @Sport, @Event, @Medal
)
SET
 ID = NULLIF(@ID, 'NA'),
 Name = @Name,
 Sex = @Sex,
 Age = NULLIF(@Age, 'NA'),
 Height = NULLIF(@Height, 'NA'),
 Weight = NULLIF(@Weight, 'NA'),
 Team = @Team,
 NOC = @NOC,
 Games = @Games,
 Year = NULLIF(@Year, 'NA'),
 Season = @Season,
 City = @City,
 Sport = @Sport,
 Event = @Event,
 Medal = NULLIF(@Medal, 'NA');

-- Check count
SELECT COUNT(*) FROM athlete_events;
# Total count = 271116
SELECT COUNT(*) FROM athlete_events
WHERE age IS  NULL ; 

-- creating seond table 
CREATE TABLE noc_regions (
NOC VARCHAR(50),
REGION VARCHAR(255),
NOTES VARCHAR(300)
) ;
-- SECTION 2: Data Loading

-- Load data from CSV (secure-file-priv folder)

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/noc_regions.csv'
INTO TABLE noc_regions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- Check total number of rows in noc_regions table
SELECT COUNT(*) FROM noc_regions;

-- SECTION 3: Data Exploration ----

-- Preview data to understand the structure and columns
SELECT * FROM athlete_events;
SELECT * FROM noc_regions;

-- The column "NOC" is common in both tables.
-- We will use it as the key to join athlete_events and noc_regions
-- whenever we need to combine data from both tables.

-- =========================================
-- Q1: How many Olympic Games have been held so far?
-- There have been 51 Olympic Games held so far.
SELECT DISTINCT COUNT(DISTINCT Games) AS Total_Game_has_held FROM athlete_events ;
-- =========================================
-- Q2: List down all Olympic Games held so far
-- This are games held in Olmpic Games 
SELECT distinct Games FROM athlete_events ;
-- =========================================
-- Q3: Total number of nations participated in each Olympic Games
-- This query shows how many different countries participated
-- in each Olympic Games.
SELECT Games,COUNT(DISTINCT NOC) AS Total_Nations_participated_count FROM athlete_events 
GROUP BY Games ;

-- =========================================
-- Q4: Which year saw the highest and lowest number of countries participating?
-- Highest number of countries participating in an Olympic Games
SELECT Games,Count(DISTINCT NOC)  Total_Nations FROM athlete_events 
GROUP BY Games 
ORDER BY  Total_Nations DESC 
LIMIT 1;
-- Lowest number of countries participating in an Olympic Games
SELECT Games,Count(DISTINCT NOC) Total_Nations FROM athlete_events
GROUP BY Games 
ORDER BY Total_Nations  ASC 
LIMIT 1;
-- =========================================
-- Q5: Which nation has participated in all of the Olympic Games?
-- This query shows which country has always participated
-- in all Olympic Games.
SELECT * FROM athlete_events ;
SELECT NOC, COUNT(DISTINCT Games) AS Most_Participated_Nations  FROM athlete_events 
GROUP BY NOC 
HAVING Most_Participated_Nations = 51 ;
-- =========================================
-- Q6: Identify the sport which was played in all Summer Olympics
-- This query shows which sport was always played
-- in all Summer Olympic Games.
SELECT * FROM athlete_events ;
SELECT Sport,COUNT(DISTINCT Games) AS total_summer_games From athlete_events 
WHERE Season = 'Summer'
GROUP BY Sport 
HAVING COUNT(DISTINCT Games ) = (
	SELECT COUNT(DISTINCT Games)
    FROM athlete_events
    WHERE Season = 'Summer'
);

-- =========================================
-- Q7: Which sports were played only once in the Olympics
-- This query shows which sports were played only once
-- in the Olympic Games.
SELECT * FROM athlete_events ;
SELECT Sport,Count(DISTINCT Games ) AS Total_Games FROM athlete_events 
GROUP BY Sport 
HAVING Total_Games <= 1;
-- =========================================
-- Q8: Total number of sports played in each Olympic Games
-- This query shows the count of sports played
-- in each Olympic Games.
SELECT * FROM athlete_events ;
SELECT Games, COUNT(DISTINCT Sport) AS Total_Sports_Played FROM athlete_events 
GROUP BY Games ;
-- =========================================
-- Q9: Fetch details of the oldest athletes to win a gold medal
-- This query retrieves the details of the oldest athlete
-- who won a gold medal, including their name, age, gender,
-- country, sport/event, and the year they won the medal.SELECT * FROM athlete_events ;
SELECT Name,Sex,Age,NOC,Year,Sport,Event, Medal FROM athlete_events 
WHERE Age  = (
 SELECT MAX(Age) FROM athlete_events 
WHERE Medal = "gold"
);
-- =========================================
-- Q10: Find the ratio of male and female athletes in all Olympic Games
-- This query shows the ratio of male and female athletes
-- who participated in the Olympic Games.
SELECT * FROM athlete_events ;
SELECT 
	COUNT(CASE WHEN Sex = "M"  THEN 1 END ) AS Male_Count,
    COUNT(CASE WHEN Sex = "F" THEN 1 END ) AS Female_Count
    FROM athlete_events ;
    
    -- QX/Q10A : Count of Winners (Gold), Runners (Silver/Bronze) and Athletes with No Medal

    SELECT 
    COUNT(CASE WHEN Medal = "Gold" Then 1 END ) AS Winner ,
    COUNT(CASE WHEN Medal = "Silver" OR  Medal = "Bronze" THEN 1 END ) AS Runner,
    COUNT(CASE WHEN Medal IS NULL THEN 1 END ) AS No_Medal 
    FROM athlete_events ;
 -- =========================================
-- Q11: Fetch the top 5 athletes who have won the most gold medals
-- This query finds the top five athletes who have won
-- the highest number of gold medals across all Olympic Games,
-- along with their names and gold medal counts.SELECT * FROM athlete_events ;
SELECT Name,COUNT(Medal) AS Gold_Medals FROM athlete_events
WHERE Medal = "Gold"
GROUP BY Name
ORDER BY Gold_Medals DESC
LIMIT 5;
-- =========================================
-- Q12: Fetch the top 5 athletes who have won the most medals
-- This query finds the top five athletes who have won
-- the highest number of total medals (gold, silver, and bronze)
-- across all Olympic Games, along with their names and medal counts
SELECT * FROM athlete_events ;
SELECT Name,COUNT(Medal) AS Total_Medals FROM athlete_events 
GROUP BY Name
ORDER BY Total_Medals DESC  
LIMIT 5 ;
-- =========================================
-- Q13: Fetch the top 5 most successful countries in the Olympics
-- This query identifies the top five countries that have been
-- the most successful in Olympic history, based on the total
-- number of medals won across all Olympic Games.
SELECT NOC,COUNT(Medal) Most_Successful_Countries FROM athlete_events 
GROUP BY NOC
ORDER BY Most_Successful_Countries DESC
LIMIT 5 ;
-- =========================================
-- Q14: Total gold, silver, and bronze medals won by each country
-- This query calculates how many Gold, Silver, and Bronze medals
-- each country (NOC) has won across all Olympic Games.
-- It uses CASE statements to count each medal type separately.
SELECT * FROM athlete_events ;
SELECT NOC,
COUNT(CASE WHEN Medal = 'Gold' THEN 1 END ) AS Total_Gold_Medals,
COUNT(CASE WHEN Medal = 'Silver' THEN 1 END ) AS Total_Silver_Medals,
COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END ) AS Total_Bronze
			FROM athlete_events 
GROUP BY NOC ;
-- =========================================
-- Q15: Total gold, silver, and bronze medals by each country for each Olympic Games
-- This query displays medal counts (gold, silver, bronze)
-- for each country in each Olympic Games using NOC codes.

SELECT NOC,Games,
COUNT(CASE WHEN Medal = 'Gold' THEN 1 END ) AS Total_Gold_Medals,
COUNT(CASE WHEN Medal = 'Silver' THEN 1 END ) AS Total_Silver_Medals,
COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END ) AS Total_Bronze_Medals
FROM athlete_events
GROUP BY Games,NOC ;
-- =========================================
-- Q16: Country with most gold, silver, and bronze medals in each Olympic Games
-- This query identifies, for every Olympic Games, the country
-- that won the highest number of gold, silver, and bronze medals.
-- It helps highlight which nation dominated each medal category
-- in every edition of the Games.
SELECT t.Games,
       t.NOC,
       t.Total_Gold_Medals,
       t.Total_Silver_Medals,
       t.Total_Bronze_Medals
FROM (
    SELECT Games, NOC,
           COUNT(CASE WHEN Medal = 'Gold' THEN 1 END)   AS Total_Gold_Medals,
           COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Total_Silver_Medals,
           COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Total_Bronze_Medals
    FROM athlete_events
    GROUP BY Games, NOC
) t
WHERE 
    t.Total_Gold_Medals = (
        SELECT MAX(g.Total_Gold_Medals)
        FROM (
            SELECT Games, NOC,
                   COUNT(CASE WHEN Medal = 'Gold' THEN 1 END) AS Total_Gold_Medals
            FROM athlete_events
            GROUP BY Games, NOC
        ) g
        WHERE g.Games = t.Games
    )
 OR t.Total_Silver_Medals = (
        SELECT MAX(s.Total_Silver_Medals)
        FROM (
            SELECT Games, NOC,
                   COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Total_Silver_Medals
            FROM athlete_events
            GROUP BY Games, NOC
        ) s
        WHERE s.Games = t.Games
    )
 OR t.Total_Bronze_Medals = (
        SELECT MAX(b.Total_Bronze_Medals)
        FROM (
            SELECT Games, NOC,
                   COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Total_Bronze_Medals
            FROM athlete_events
            GROUP BY Games, NOC
        ) b
        WHERE b.Games = t.Games
    );
-- =========================================
SELECT * FROM athlete_events ;
-- Q17: Country with most gold, silver, bronze, and total medals in each Olympic Games
-- This query finds, for each Olympic Games, the country that won
-- the highest number of gold, silver, bronze, and overall medals.
-- It uses medal counts and ranking to determine
DROP VIEW IF EXISTS q17_top_countries_v2; 
CREATE VIEW q17_top_countries_v2 AS
SELECT Games,
       NOC,
       Gold,
       Silver,
       Bronze,
       Total
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Games ORDER BY Gold DESC)   AS Gold_Rank,
           RANK() OVER (PARTITION BY Games ORDER BY Silver DESC) AS Silver_Rank,
           RANK() OVER (PARTITION BY Games ORDER BY Bronze DESC) AS Bronze_Rank,
           RANK() OVER (PARTITION BY Games ORDER BY Total DESC)  AS Total_Rank
    FROM (
        SELECT Games,
               NOC,
               COUNT(CASE WHEN Medal = 'Gold' THEN 1 END)   AS Gold,
               COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Silver,
               COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Bronze,
               COUNT(Medal) AS Total
        FROM athlete_events
        GROUP BY Games, NOC
    ) base
) ranked
WHERE Gold_Rank = 1
   OR Silver_Rank = 1
   OR Bronze_Rank = 1
   OR Total_Rank = 1;

-- =========================================
-- Q18: Countries with no gold medals but with silver or bronze medals
-- This query identifies countries that have never won a gold medal
-- in the Olympics but have won at least one silver or bronze medal.
-- It highlights nations that reached the podium but never the top position.
SELECT * FROM athlete_events;
DROP VIEW IF EXISTS q18_no_gold_countries;

CREATE VIEW q18_no_gold_countries AS
SELECT NOC,
       COUNT(CASE WHEN Medal = 'Gold' THEN 1 END)   AS Gold_Count,
       COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Silver_Count,
       COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Bronze_Count
FROM athlete_events
GROUP BY NOC
HAVING 
    COUNT(CASE WHEN Medal = 'Gold' THEN 1 END) = 0
    AND (
        COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) > 0
        OR COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) > 0
    );

-- =========================================
-- Q20: Olympic Games where India won medals in Hockey and medal count per Games
-- This query shows all Olympic Games in which India won medals
-- in the sport of Hockey, along with the total number of medals
-- won in each Games.
-- It helps analyze India's performance in Hockey over time.
# and future queries.
SELECT * FROM athlete_events;
DROP VIEW IF EXISTS india_hockey_medals;

CREATE VIEW india_hockey_medals AS
SELECT N.REGION,
       A.Games,
       COUNT(*) AS Medal_Count
FROM athlete_events A
JOIN noc_regions N
  ON A.NOC = N.NOC
WHERE N.REGION = 'India'
  AND A.Sport = 'Hockey'
  AND A.Medal IS NOT NULL
GROUP BY N.REGION, A.Games
ORDER BY Medal_Count DESC;
-- =========================================
-- Check View Output: india_hockey_medals
-- This query is used to verify the data stored in the view.
-- It displays all Olympic Games where India won medals in Hockey
-- along with the total number of medals won in each Games.
SELECT * FROM india_hockey_medals;
-- =========================================











