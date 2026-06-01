Select *
from PortfolioPoject..CovidDeaths$
where continent is not null

-- Select Data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioPoject..CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths

select location,SUM(CAST(total_cases as float)) as total_cases,SUM(CAST(total_deaths as float)) as total_deaths,
(SUM(CAST(total_deaths as float))/SUM(CAST(total_cases as float)))*100 as Death_Percentage
from PortfolioPoject..CovidDeaths$
group by location order by location


-- Looking at Total Cases vs Population 
-- Shows the percentage of population go covid

select location,date,population,total_cases,
(total_cases/population)*100 as Covid_Percentage
from PortfolioPoject..CovidDeaths$

-- Looking as Countries with Highest Infection Rate compared to Population

select Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioPoject..CovidDeaths$
group by location,population    
order by PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count per Population

select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioPoject..CovidDeaths$
where continent is not null 
group by location
order by TotalDeathCount desc
-- Problem with above query is that it is grouping the entire continents 
-- in the dataset there are some NULL values so we have to deal with them now

-- CORRECTED ABOVE QUERY
select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioPoject..CovidDeaths$
where continent is not null 
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioPoject..CovidDeaths$
where continent is null
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

select continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioPoject..CovidDeaths$
where continent is not null 
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as int)) as Total_Deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioPoject..CovidDeaths$
where continent is not null 
group by date
order by date

-- QUERY FOR TABLEAU TABLE 1 ( for visualization)
Select SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as int)) as Total_Deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioPoject..CovidDeaths$
where continent is not null 


-- Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioPoject..CovidDeaths$ as dea,
PortfolioPoject..CovidVaccinations$ as vac
where dea.location=vac.location and
dea.date=vac.date 
and dea.continent is not null 
order by 2,3

-- USE CTE 

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioPoject..CovidDeaths$ as dea,
PortfolioPoject..CovidVaccinations$ as vac
where dea.location=vac.location and
dea.date=vac.date 
and dea.continent is not null 
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac
order by location,date


--	TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioPoject..CovidDeaths$ as dea,
PortfolioPoject..CovidVaccinations$ as vac
where dea.location=vac.location and
dea.date=vac.date 
and dea.continent is not null 

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by location,date

-- Creating View to store data for later visualizations 

Create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioPoject..CovidDeaths$ as dea,
PortfolioPoject..CovidVaccinations$ as vac
where dea.location=vac.location and
dea.date=vac.date 
and dea.continent is not null 
