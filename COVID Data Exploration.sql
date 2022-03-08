/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
from PortfolioProject..CovidDeaths
order by 3,4

Select *
from PortfolioProject..CovidVaccination
order by 3,4

-----------------------------------------------------------------------------------------------------------------------------------------

--select data that we are going to use (no need)

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------

--looking at total cases vs total deaths
--shows likelihood of dying percentage if you contact covid in your country

Select location, date, total_cases, total_deaths, cast((total_deaths/total_cases)*100 as decimal(10,2)) as Death_percent
from PortfolioProject..CovidDeaths
where location = 'india' and continent is not null
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------

--looking at the total cases vs population
--shows what percentage of population infected with covid

Select location, date, total_cases, population, cast((total_cases/population)*100 as decimal(10,2)) as infected_percentage
from PortfolioProject..CovidDeaths
where location = 'india'
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------

--looking at countries with highest infection rate as compare to population

Select location, population, max (total_cases) as highest_infection_rate , (max(total_cases)/population)*100 as infected_percentage
from PortfolioProject..CovidDeaths
GROUP BY location, population
order by 4 desc

-----------------------------------------------------------------------------------------------------------------------------------------

--looking at countries with highest death count as compare to infection count

Select location, population, max(total_cases) as max_total_cases, max (total_deaths) as highest_deaths , (max(total_deaths)/max(total_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
GROUP BY location, population
order by 5 desc

-----------------------------------------------------------------------------------------------------------------------------------------

--showing countries with highest death count per population 

Select location, population, max (total_deaths) as highest_deaths , (max(total_deaths)/population)*100 as death_percentage
from PortfolioProject..CovidDeaths
GROUP BY location, population
order by 4 desc

-----------------------------------------------------------------------------------------------------------------------------------------

--LET'S BREAK THINGS DOWN BY CONTINENTS

--showing countries with highest death count

Select continent, max(cast(total_deaths as int)) as highest_deaths_count 
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
order by highest_deaths_count  desc

-----------------------------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------

--looking at total population vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--now here we cant use RollingPeopleVaccinated to find the percentage , so we have to create CTE or Temp table for it
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-----------------------------------------------------------------------------------------------------------------------------------------

-- USE CTE

-- Using CTE to perform Calculation on Partition By in previous query

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageOfVaccinated
from popvsvac

-----------------------------------------------------------------------------------------------------------------------------------------

--TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #percentPopulationVaccinated
CREATE Table #percentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(numeric, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentageOfVaccinated
from #percentPopulationVaccinated


-----------------------------------------------------------------------------------------------------------------------------------------


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


