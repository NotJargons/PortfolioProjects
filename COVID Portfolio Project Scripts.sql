SELECT * 
FROM coviddeaths;

SELECT * 
FROM covidvaccinations;

-- Focusing on the data that we need

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;

-- Total Cases Vs Total Deaths -  Percentage of people that have died from covid in the United States

SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
Where Location = 'United States';

-- Total Cases Vs Population - for the Percentage of the population that has gotten covid

SELECT location, date, population, total_cases,
(total_cases/population)*100 as CovidInfectionPercentage
FROM coviddeaths
Where continent <> 'Null'
Order by CovidInfectionPercentage DESC; 

-- Average Covid Infection Percentage accross the world
SELECT location, AVG((total_cases/population)*100) as AvgCovidInfectionPercentage
FROM coviddeaths
Where continent <> 'Null'
Group by location
Order by CovidInfectionPercentage DESC; 


-- Looking at the countries with the highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 as CovidInfectionPercentage
FROM coviddeaths
Where continent <> 'NULL'
Group By location, population
Order by CovidInfectionPercentage DESC;

-- The most infected country 

SELECT location, MAX(total_cases) AS HighestInfectionCount
FROM coviddeaths
Where continent <> 'Null'
Group By location
Order by HighestInfectionCount DESC;


-- Total Cases Vs Total Deaths -  Percentage of people that have died from covid

SELECT location, MAX(total_cases) AS HighestInfectionCount, 
MAX(CAST(total_deaths as UNSIGNED)) AS TotalDeathCount, 
MAX((total_deaths/total_cases)*100) AS DeathPercentage
FROM coviddeaths
Where continent <> 'Null'
Group By location
Order by TotalDeathCount DESC;


-- Looking at the countries with the highest death count

SELECT location, MAX(CAST(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
Where continent <> 'Null'
Group By location
Order by TotalDeathCount DESC;

-- GROUPING BY CONTINENT
-- Getting the total number of deaths within each continent

SELECT  continent, sum(new_deaths) AS total_deaths
FROM coviddeaths
Where continent <> 'Null'
Group By continent
Order by total_deaths DESC;

-- GLOBAL NUMBERS

-- Daily Numbers on cases, deaths and death percentage globally
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM coviddeaths
Where continent <> 'Null'
Group by date
order by total_cases;

-- Overall number of cases, deaths and death percentage globally
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM coviddeaths
Where continent <> ''
order by total_cases;

-- Joining both tables

SELECT *
FROM coviddeaths as dea
JOIN covidvaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date;

-- Getting the total number of people in the world that have been vaccinated 
-- Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent <> 'Null'
order by 2,3; 

SELECT *
FROM covidvaccinations;

-- USING A CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent <> 'Null')

SELECT *,(RollingPeopleVaccinated/Population) * 100
FROM PopvsVac; 

-- TEMP TABLE
DROP TEMPORARY TABLE if exists PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
continent varchar(255),
location varchar (255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated int)
;

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent <> 'Null'
order by 2,3; 

SELECT * FROM PercentPopulationVaccinated;

-- CREATING VIEWS FOR DATA VISUALIZATION

CREATE View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent <> 'Null'
order by 2,3;

