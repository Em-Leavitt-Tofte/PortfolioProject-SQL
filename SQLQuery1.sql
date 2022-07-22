select*
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--Select*
--From [Portfolio Project]..CovidVaccinations$
--order by 3,4
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2

--Total Cases vs. Total Deaths
-- Shows likelihood of dying if ou contract covid in your country
Select continent,Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Total Cases vs. Population
--Shows what percentage of populaiton got covid
Select continent,Location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Countries with highest infection rate compared to population
Select Location,Population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Breakdown by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc 

--Global Numbers
Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where continent is not null
Group by date
order by 1,2


--Total population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--CTE
With Popsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopsVac


--Temp Table

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null


Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null


