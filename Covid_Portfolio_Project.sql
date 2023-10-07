
-- SELECT * FROM PortfolioProject..CovidVaccinations$ ORDER BY 3,4;

-- Select Dataset for project

SELECT location, date,total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths$ ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM PortfolioProject..CovidDeaths$ 
WHERE location like '%Nigeria%'
ORDER BY 1,2;


-- looking at the Total Cases vs Total Population
-- shows the percentage of the population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_percentage 
FROM PortfolioProject..CovidDeaths$ 
WHERE location like '%Nigeria%'
ORDER BY 1,2;

--looking at countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, 
	MAX((total_cases/population)*100) as Percent_Population_Infected
	FROM PortfolioProject..CovidDeaths$
	WHERE continent is not null 
	GROUP BY location,population
	ORDER BY Percent_Population_Infected DESC;


-- Showing countries with the Highest Death Count Per Population
SELECT location,population,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS OUT BY CONTINENT

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT date, 
	SUM(new_cases) as global_new_cases, 
	SUM(cast(new_deaths as int)) as global_new_deaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as global_death_percentage
	FROM PortfolioProject..CovidDeaths$
	WHERE continent is not null
	GROUP BY date
	ORDER BY 1,2;


-- total number of cases across the world
SELECT 
	SUM(new_cases) as total_cases , 
	SUM(cast(new_deaths as int)) as total_deaths, 
   (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..CovidDeaths$


-- Join the covidVaccinations table and create a view

SELECT * 
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ vaccinations
ON	vaccinations.location = deaths.location
and vaccinations.date = deaths.date
 

-- Looking at total population vs vaccinations
-- it shows the new vaccinations per day

With PopvsVac (continent,location,date,population,new_vaccinations, rolling_people_vaccinated)
as
(
SELECT 
deaths.continent,deaths.location,deaths.date,deaths.population,cast(vacc.new_vaccinations as int) as new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ vacc
	ON	vacc.location = deaths.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 as vaccinated_Percentage FROM PopvsVac;


--TEMP TABLE

DROP TABLE IF EXISTS #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_people_vaccinated NUMERIC,
)

INSERT INTO #percentPopulationVaccinated
SELECT 
deaths.continent,deaths.location,deaths.date,deaths.population,cast(vacc.new_vaccinations as int) as new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ vacc
	ON	vacc.location = deaths.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 as percentageVaccinated FROM #percentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVacccinated AS
SELECT 
deaths.continent,deaths.location,deaths.date,deaths.population,cast(vacc.new_vaccinations as int) as new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ deaths
JOIN PortfolioProject..CovidVaccinations$ vacc
	ON	vacc.location = deaths.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null
--ORDER BY 2,3

SELECT *FROM PercentPopulationVacccinated