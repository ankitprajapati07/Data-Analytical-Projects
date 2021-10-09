

--1.Globel Numbers --------------------------------------------------------------------

Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage

From [covid-19]..CovidDeaths
where continent is not null 
order by 1,2



--2.Contintents with the highest death count per population ---------------------------------------


Select location, 
       SUM(cast(new_deaths as int)) as TotalDeathCount

From [covid-19]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3.Countries with Highest Infection Rate compared to Population ------------------------------------------------------

Select Location, 
       Population, 
	   MAX(total_cases) as HighestInfectionCount,  
	   Max((total_cases/population))*100 as PercentPopulationInfected

From [covid-19]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


--4.Just added date in previous query --------------------------------------------------------------


Select Location, 
       Population,
	   date, 
	   MAX(total_cases) as HighestInfectionCount,  
	   Max((total_cases/population))*100 as PercentPopulationInfected

From [covid-19]..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc




--5.Total Population vs Vaccinations (Percentage of Population that has recieved at least one Covid Vaccine) -------------------


Select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population,
       MAX(vac.total_vaccinations) as RollingPeopleVaccinated

From [covid-19]..CovidDeaths dea
Join [covid-19]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




--6.Total Cases vs Total Deaths ------------------------------------------------------------


Select Location, 
       date, 
	   population, 
	   total_cases, 
	   total_deaths

From [covid-19]..CovidDeaths
where continent is not null 
order by 1,2


--7.Using CTE to perform Calculation on Partition in first query --------------------------------------------------------



With PopvsVac (Continent, 
               Location, 
			   Date, 
			   Population, 
			   New_Vaccinations, 
			   RollingPeopleVaccinated)
as
(
      Select dea.continent, 
	         dea.location, 
			 dea.date, 
			 dea.population, 
			 vac.new_vaccinations,
             SUM(CONVERT(int,vac.new_vaccinations)) OVER 
			 (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [covid-19]..CovidDeaths dea
Join [covid-19]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac




--8.Using Temp Table to perform Calculation on Partition By in previous query ------------------------------------------------

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	   (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [covid-19]..CovidDeaths dea
Join [covid-19]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--9.Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	   (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [covid-19]..CovidDeaths dea
Join [covid-19]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
