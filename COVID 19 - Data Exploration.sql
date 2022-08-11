SELECT *
FROM PROJECT ..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PROJECT ..CovidVaccinations$
--ORDER BY 3, 4

--SELECT THE DATA WE ARE USING
--SHOW LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
FROM PROJECT..CovidDeaths$
--WHERE location = 'United States' same thing we can do in other way
WHERE location like '%states%'
ORDER BY 1, 2

--SHOW WHAT % OF POPULATION GOT COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfection
FROM PROJECT ..CovidDeaths$
WHERE location = 'United States'
ORDER BY 1, 2

--Looking at countries with Higeast number of Infection rate 
SELECT location, population, MAX(total_cases) AS HigestInfectedCount, MAX(total_cases/population) AS PercentPolupationInfected
FROM PROJECT ..CovidDeaths$
GROUP BY location, population 
ORDER BY 1 ,2 DESC

--Looking at countries with Higeast number of Infection rate(2) 
SELECT location, population, MAX(total_cases) AS HigestInfectedCount, MAX(total_cases/population)*100 AS PercentPolupationInfected
FROM PROJECT ..CovidDeaths$
GROUP BY location, population 
ORDER BY PercentPolupationInfected DESC

--COUNTRY WITH HIGEST DEATH COUNT PRE POPULATION
SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PROJECT ..CovidDeaths$
WHERE continent is not null 

GROUP BY location
ORDER BY TotalDeathCount DESC

---break things down by continents
SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PROJECT ..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

---Global Number
SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT ))/SUM(new_cases)*100 AS DeathPercentage
FROM PROJECT ..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1 ,2


SELECT * 
FROM PROJECT ..CovidDeaths$ dea
JOIN PROJECT ..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date

---looking at the total population vs vaccination
---Shows Percentage of Population that has recieved at least one Covid Vaccin
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PROJECT ..CovidDeaths$ dea
JOIN PROJECT ..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--- USING CET to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PROJECT ..CovidDeaths$ dea
JOIN PROJECT ..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PROJECT ..CovidDeaths$ dea
JOIN PROJECT ..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PROJECT ..CovidDeaths$ dea
JOIN PROJECT ..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
