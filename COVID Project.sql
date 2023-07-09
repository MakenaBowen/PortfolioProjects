SELECT *
FROM CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT Location, date,total_cases, new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 
--Shows likeliood on dying if you contract covid in your country 

SELECT Location, date,total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Total cases vs Population 
--Shows what percenatge of population got Covid 

SELECT Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected 
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countries with highest infection rate compared to population 

SELECT Location, Population, MAX (total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as 
PercentPopulationInfected 
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population			

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--WHERE location like '%states%'
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Breaking Data down by Continent


--Showing Continents With the Highest Death Counts 


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--WHERE location like '%states%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM (New_cases) *100 as DeathPercentage 
FROM CovidDeaths
--WHERE location like '%states%'
WHERE Continent is not null
--Group By date 
ORDER BY 1,2

--Looking at Total Population Vs Vaccinations

Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER by dea.location, dea. Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population) * 100
FROM CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location= vac.location 
	and dea.date= vac.date 
	WHERE dea.Continent is not null
	ORDER BY 2,3 

	--Use CTE
	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
	as 
	(
	Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER by dea.location, dea. Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population) * 100
FROM CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location= vac.location 
	and dea.date= vac.date 
	--WHERE dea.Continent is not null
	--ORDER BY 2,3 
	)
	Select *, (RollingPeopleVaccinated/Population)*100 
	From PopvsVac

	--Temp Table 
	Drop Table if exists  #PercentPopulationVaccinated 
	Create table #PercentPopulationVaccinated 
	(
	Continent nvarchar (255), 
	Loaction nvarchar (255), 
	date datetime, 
	Population numeric, 
	New_vaccinations numeric,
	RollingPeoplevaccinated numeric 
	)

	Insert into  #PercentPopulationVaccinated 

	Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER by dea.location, dea. Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population) * 100
FROM CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location= vac.location 
	and dea.date= vac.date 
	WHERE dea.Continent is not null
	--ORDER BY 2,3 

		Select *, (RollingPeopleVaccinated/Population)*100 
	From  #PercentPopulationVaccinated 

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER by dea.location, dea. Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population) * 100
FROM CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location= vac.location 
	and dea.date= vac.date 
	WHERE dea.Continent is not null
	--ORDER BY 2,3 

Select * 
From PercentPopulationVaccinated 