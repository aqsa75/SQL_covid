Select *
From CovidProject..CovidDeaths
Order by 3, 4

--Select *
--From CovidProject..CovidVaccinations
--Order by 3, 4

--Select Data that I am going to use

Select [location], [date], total_cases, new_cases,total_deaths, population
From CovidProject..CovidDeaths
Order by 1, 2

-- Looking at total cases vs total deaths and then filtering this out
-- Shows likelihood of dying if you contract covid in your country
Select [location], [date], total_cases,total_deaths,  (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0))* 100 AS death_rate
From CovidProject..CovidDeaths
where location like '%states%'
Order by 1, 2

-- Looking at total cases vs population
-- shows what percentage of population got Covid
Select [location], [date], population, total_cases, (CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%states%'
Order by 1, 2

-- Looking at countries with highest infection rate compared to population
Select [location],  population, max(total_cases) as HighestInfectionCount, (MAX(CAST(total_cases AS FLOAT)) / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%states%'
group BY population, [location]
Order by  PercentPopulationInfected desc


-- Let's break things down by contintent
Select [continent],  max(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
group BY [continent]
Order by  TotalDeathCount desc

-- code to get the correct breakdown by continent :
Select [location],  max(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is  null
group BY [location]
Order by  TotalDeathCount desc

-- Showing countries with highest death count per population
Select [location],  max(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
group BY [location]
Order by  TotalDeathCount desc

--Showing continents with the highest death count per population
Select [continent],  max(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
group BY [continent]
Order by  TotalDeathCount desc


-- Global Numbers
Select [date], sum(new_cases) as totalcases, sum(new_deaths)  as totaldeaths, sum(CAST(new_deaths AS float)) / sum(cast(new_cases as float))* 100 AS death_percentage
From CovidProject..CovidDeaths
where continent is not null
group by date
Order by 1, 2



--looking at total populaiton vs vaccinations

-- use cte:

With PopvsVac(continent, location, date, population, new_vaccinations, rolling_ppl_vaccinated)
as
(

select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated

from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
ON dea.[location] =vac.[location]
and dea.date = vac.date
where dea.continent is not null

)

SELECT *, 
    CAST(rolling_ppl_vaccinated AS FLOAT) / CAST(population AS INT) * 100 AS vaccination_percentage
FROM 
    PopvsVac;


-- Temp Table


create table #percentpopulationvaccinated
(
continent nvarchar(255),
LOCATION nvarchar(255),
DATE datetime,
population numeric,
new_vaccinations numeric,
rolling_ppl_vaccinated numeric )

insert into #percentpopulationvaccinated
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated

from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
ON dea.[location] =vac.[location]
and dea.date = vac.date
where dea.continent is not null

SELECT *, 
    CAST(rolling_ppl_vaccinated AS FLOAT) / CAST(population AS INT) * 100 AS vaccination_percentage
FROM 
    #percentpopulationvaccinated;


-- creating view to store data for later visualizations

Create VIEW percentpopulationvaccinated as
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated

from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
ON dea.[location] =vac.[location]
and dea.date = vac.date
where dea.continent is not null
