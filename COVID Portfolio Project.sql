
Select * 
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths$
 where continent is not null
 order by 1,2

 --Looking at Total Cases vs Total Deaths
 --Shows likelihood of dying if you contract COVID in your country

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths$
 Where location like '%states%'
 order by 1,2

 --Looking at Total Cases vs Population
 --Shows what % of population got COVID
 Select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopInfected
 From PortfolioProject..CovidDeaths$
 Where location like '%states%'
 order by 1,2

 --Looking at countries with highest infection rate compared to population
  
  Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths$
 --Where location like '%states%'
 where continent is not null
 Group by location, population
 order by PercentPopulationInfected desc

 --Showing countries with the highest death count per population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths$
 --Where location like '%states%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc

 -- LETS BREAK THINGS DOWN BY CONTINENT

   Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths$
 --Where location like '%states%'
 where continent is not null and location not like '%income%'
 Group by continent
 order by TotalDeathCount desc


 -- Showing continents with the highest death count per population

   Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths$
 --Where location like '%states%'
 where continent is not null and location not like '%income%'
 Group by continent
 order by TotalDeathCount desc

 -- GLOBAL NUMBERS

  Select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
--group by date
 order by 1,2

 
 -- Looking at total population vs vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, sum(convert(int,vax.new_vaccinations )) 
 OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax
  From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVax (Continent, location, date, population, new_vaccinations, RollingPeopleVax)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, sum(convert(int,vax.new_vaccinations )) 
 OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax
  From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVax/population)*100
From PopvsVax



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVax numeric
)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, sum(convert(int,vax.new_vaccinations )) 
 OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax
  From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vax
	On dea.location = vax.location
	and dea.date = vax.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVax/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, sum(convert(int,vax.new_vaccinations )) 
 OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax
  From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated