select *
from PorfolioProject..CovidDeaths$
where continent is not null
order by 3,4


--Select data I'm going to use
select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Total cases vs total death
--showing the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases),4)*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
WHERE continent IS NOT NULL and location like ('%Taiw%')
ORDER BY DeathPercentage 

--Total case vs population
Select location, date, total_cases, population, round((total_cases/population),7)*100 as PercentagePopulationInfected
from PorfolioProject..CovidDeaths$
where continent is not null and location = 'Taiwan'
order by PercentagePopulationInfected

--Countries with highest infection rate compare to population
Select location, population, max(total_cases) as TotalCases, max(total_cases/population)as PercentPopulationInfected
from PorfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by TotalCases asc


--countries with highest death count per population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths$
where continent is not null
group by location 
order by TotalDeathCount

--Showing the continents with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Global number
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) as DeathPercentage
from PorfolioProject..CovidDeaths$
where continent is not null

--Total population vs vaccinations
--Showing percentage of population that have recieved at least one covid vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

--Using CTE to perform calculation on partition by in previous query
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinationRate
from PopvsVac
where location = 'Taiwan'



--Create temp table
drop table if exists #PercentPopulationVaccination
Create table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 as VaccinatedRate
from #PercentPopulationVaccination


--Create view
use PorfolioProject
drop view if exists PercentPopulationVaccination
Create view PercentPopulationVaccination As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
