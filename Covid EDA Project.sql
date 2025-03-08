/*
	Covid 19 Exploratory Data Analysis (EDA) Project 
*/

SELECT *
FROM deaths
ORDER BY 3,4;

SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM deaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of death if one got Covid (in Egypt)
SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM deaths
WHERE location LIKE '%Egypt%'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population got infected (in Egypt)
SELECT location, `date`, total_cases, Population, (total_cases/Population)*100 AS case_percentage
FROM deaths
WHERE location LIKE '%Egypt%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/Population)*100 AS population_infected_percentage
FROM deaths
GROUP BY location, Population
ORDER BY population_infected_percentage DESC;

-- Countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) AS highest_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- Continents with the Highest Death Count per Population
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Global Numbers

-- Shows likelihood of death if one got Covid (global)
SELECT `date`, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM deaths
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1;

-- Shows overall global death percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM deaths
WHERE continent IS NOT NULL;

-- Total Population vs Vaccinations
SELECT * FROM deaths;
SELECT * FROM vaccinations;

SELECT d.continent, d.location, d.`date`, d.population, v.new_vaccinations
FROM deaths d
INNER JOIN vaccinations v
	ON d.location = v.location
    AND d.`date` = v.`date`
WHERE d.continent IS NOT NULL
ORDER BY 2,3;


DROP TABLE IF EXISTS pop_vs_vac;
CREATE TEMPORARY TABLE pop_vs_vac
(
	continent VARCHAR(255),
	location VARCHAR(255),
	`date` DATE,
	population FLOAT,
	new_vaccinations FLOAT,
	rolling_people_vaccinated FLOAT
);
INSERT INTO pop_vs_vac
SELECT d.continent, d.location, d.`date`, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.`date`) AS rolling_people_vaccinated
FROM deaths d
INNER JOIN vaccinations v
	ON d.location = v.location
	AND d.`date` = v.`date`
WHERE d.continent IS NOT NULL;

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_vaccinations_per_population 
FROM pop_vs_vac
ORDER BY 2,3;


-- Creating View to store data for later Visualizations
CREATE VIEW PercentPopulationVaccinatedA AS
SELECT d.continent, d.location, d.`date`, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.`date`) AS rolling_people_vaccinated
FROM deaths d
INNER JOIN vaccinations v
	ON d.location = v.location
	AND d.`date` = v.`date`
WHERE d.continent IS NOT NULL;