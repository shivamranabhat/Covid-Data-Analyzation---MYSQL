--use PROJECT_SQL

--select * from covid_vaccinations order by 3,4

--select * from covid_deaths order by 3,4

-- select the data that we are going to use
select continent, location, date, total_cases, new_cases, total_deaths, population from covid_deaths order by 2,3

-- total cases vs total deaths
-- showing how many percentage of people died due to covid
select continent, location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as total_death_percentage  from covid_deaths order by 2,3

--ALTER TABLE covid_deaths Alter column total_cases int

-- total cases vs populations
-- showing what percentage of people got covid
select continent, location, date,population, total_cases, (total_cases/population)*100 as CasePerPopulation from covid_deaths order by 2,3


-- Showing maximum case per population
select top 1 continent, location, date,population, total_cases, MAX(total_cases/population)*100  as CasePerPopulation 
from covid_deaths group by  continent, location, date,population, total_cases order by CasePerPopulation Desc


-- showing which country got highest covid cases
select top 1 continent, location, date, population, MAX(total_cases) AS Highest_Infection_Count, (total_cases/population)*100  as CasePerPopulation 
from covid_deaths WHERE continent is not null group by continent, location, date, population,total_cases order by Highest_Infection_Count desc


-- showing country with highest death count per population
select top 1 continent, location, date, population, MAX(cast(total_deaths as int)) AS Highest_Death_Count, (total_deaths/population)*100  as DeathPerPopulation 
from covid_deaths WHERE continent is not null group by continent, location, date, population,total_deaths order by Highest_Death_Count desc

-- Let's break things out by continent
select continent, MAX(cast(total_deaths as int)) AS Highest_Death_Count
from covid_deaths where continent is not null group by continent order by Highest_Death_Count desc

-- showing the continent with the highest death count per population
select continent, Max(total_deaths/ total_cases) * 100 AS DeathPercentage from covid_deaths group by continent, total_deaths, total_cases order by DeathPercentage desc


--Global Numbers
select date, Sum(cast(total_cases as int)) AS NewCase from covid_deaths where continent is not null group by date order by NewCase desc

select date, Sum(cast(new_cases as int)) AS NewCase, sum(cast(new_deaths as int)) As NewDeaths from covid_deaths where continent is not null group by date order by NewCase desc

SELECT SUM(new_cases) AS NewCase, SUM(CAST(new_deaths AS int)) AS NewDeaths, SUM(new_deaths)/SUM(CAST(new_cases AS int))*100 as DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

---------- Covid Vaccination -------------
Select * from covid_deaths cd join covid_vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
order by 3,4

-- How many people have covid vaccination
select cd.location, cv.date,cd.population, cv.new_vaccinations, (cv.new_vaccinations/cd.population) * 100 as No_Of_Vaccinated_People, 
sum(cast(new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS Total_Vaccination
from covid_deaths cd join covid_vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 1,2

-- i. Using temp table
DROP TABLE IF EXISTS #Vaccinated_People
CREATE TABLE #Vaccinated_People
(location nvarchar(20),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
select cd.location, cv.date,cd.population, cv.new_vaccinations, (cv.new_vaccinations/cd.population) * 100 as No_Of_Vaccinated_People, 
sum(cast(new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS Total_Vaccination
from covid_deaths cd join covid_vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

Select *,(rolling_people_vaccinated/population)*100 from #Vaccinated_People order by 1


-- ii. Using view

create view Vaccinated_People as
select cd.location, cv.date,cd.population, cv.new_vaccinations, (cv.new_vaccinations/cd.population) * 100 as No_Of_Vaccinated_People, 
sum(cast(new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS Total_Vaccination
from covid_deaths cd join covid_vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

-- Country having highest no of total vaccincation
Select location, MAX(Total_Vaccination) As Highest_Vaccination
from Vaccinated_People where new_vaccinations is not null and No_Of_Vaccinated_People is not null
group by location
order by Highest_Vaccination desc



-- Which country have the highest vaccination
Select top 10 location, MAX(CAST(new_vaccinations AS float)) AS Highest_Vaccination from covid_vaccinations 
where continent is not null 
group by location 
order by Highest_Vaccination DESC


