SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

--SELECT DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--TOTAL CASES V TOTAL DEATHS
--likelihood of death after contracting covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM CovidDeaths$
WHERE location LIKE '%states%' 
ORDER BY 1,2

--Total Cases v Population 
--shows what percentage of population contracted covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected 
FROM CovidDeaths$
WHERE location LIKE '%states%' 
ORDER BY 1,2

--Countries w/ highest infection rate compared to population 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM CovidDeaths$
--WHERE location LIKE '%states%' 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Countries w/highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Break down by continent 
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Total Population v Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
 
 --USE CTE	 
 WITH PopulationvsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
 AS 
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
) 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopulationvsVaccination

--Temp Table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 


--Creating View for later visualizations 
CREATE VIEW	PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 

SELECT *
FROM PercentPopulationVaccinated