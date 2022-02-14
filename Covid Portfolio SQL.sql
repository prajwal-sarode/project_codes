-- covid 19 Data Exploration

Select *
From [dbo].['covid deadths$']
Where continent is not null 
order by 3,4

-- selecting data that i am using

Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].['covid deadths$']
Where continent is not null 
order by 1,2

-- Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in INDIA

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].['covid deadths$']
Where location like '%INDIA%'
and continent is not null 
order by 1,2

-- Total cases vs Population
--shows what percentage of population infected with covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [dbo].['covid deadths$']
order by 1,2

-- Countries with highest infection rate compaierd to population


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].['covid deadths$']
Group by Location, Population
order by PercentPopulationInfected desc

-- countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].['covid deadths$']
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT
-- showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].['covid deadths$']
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [dbo].['covid deadths$']
where continent is not null 
order by 1,2

-- Total population vs Vaccinations
-- shows percentage of popilation that has recieved at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from [dbo].['covid deadths$'] dea
join  [dbo].['covid vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

 

 --CTE

 with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as rollingpeoplevaccinated
from [dbo].['covid deadths$'] dea
join  [dbo].['covid vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


-- creating view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['covid deadths$'] dea
Join [dbo].['covid vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 