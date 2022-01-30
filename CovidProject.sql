-- SELECT *
-- FROM Project..CovidVaccination
-- Order by 3,4

SELECT *
FROM Project..CovidDeaths
Where continent is not null
Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Project..CovidDeaths

--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths
Order by 1,2

--changes data type of column
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths float
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases float
ALTER TABLE dbo.CovidDeaths ALTER COLUMN population float
-- You can also do (cast(total_deaths as int))


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths
Where location like '%states%'
Order by 1,2

--total cases vs population: percentage of the pop getting covid in the US
SELECT location, date, population, total_cases, (total_cases/population)*100 as CovidPopPercentage 
FROM Project..CovidDeaths
Where location like '%states%' 
Order by 1,2

-- Looking at countries with Highest Infection Rate compare to Population
SELECT location, population, Max(total_cases) as HighestInfection, Max((total_cases/population))*100 as CovidPopPercentage 
FROM Project..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by CovidPopPercentage DESC

--Let's break things down by continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Project..CovidDeaths
Where continent is NULL
--Where location like '%states%'
Group by location
Order by TotalDeathCount DESC

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Project..CovidDeaths
Where continent is not NULL
--Where location like '%states%'
Group by location
Order by TotalDeathCount DESC

--Showing the continent with highest death count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Project..CovidDeaths
Where continent is NULL
--Where location like '%states%'
Group by location
Order by TotalDeathCount DESC

--Global Numbers

SELECT SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths
where continent is not NULL
Order by 1,2 

-- Looking at total pop vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollinPplVacc
From Project..CovidDeaths dea
Join Project..CovidVaccination vac 
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3    

--Use CTE
With PopvsVacc (continent, location, date, population, new_vaccinations, RollinPplVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollinPplVacc
From Project..CovidDeaths dea
Join Project..CovidVaccination vac 
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3  
)
Select *, (RollinPplVacc/population)*100
From PopvsVacc

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vacc numeric,
RollingPplVacc numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollinPplVacc
From Project..CovidDeaths dea
Join Project..CovidVaccination vac 
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (RollingPplVacc/population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollinPplVacc
From Project..CovidDeaths dea
Join Project..CovidVaccination vac 
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL

select *
From PercentPopulationVaccinated
