select * from PortfolioProject..CovidDeaths
	order by 3,4

 --select * from PortfolioProject..CovidVaccinations
	--order by 3,4

-- select relevant data
select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
	order by 1,2

-- Total Cases vs Total Deaths
-- shows the likelihood of dying based an Country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths 
	where location like '%Canada%'
	order by 1,2

-- total cases versus population
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage from PortfolioProject..CovidDeaths 
	where location like '%Canada%'
	order by 1,2

-- Countries with higbhest Infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionPercentage from PortfolioProject..CovidDeaths 
	--where location like '%Canada%'
	group by location, population
	order by InfectionPercentage desc

-- Countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths 
	where continent is not null
	group by location
	order by TotalDeathCount desc

-- Break down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths 
	where continent is null
	group by location
	order by TotalDeathCount desc

-- continents by highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths 
	where continent is not null
	group by continent
	order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
	from PortfolioProject..CovidDeaths 
	--where location like '%Canada%'
	where continent is not null
	--group by date
	order by 1,2


	-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- create view for data vizualizations
create view PercentPopulationVaccinated as

	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	select * from PercentPopulationVaccinated