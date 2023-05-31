
/*
WHO WORLD COVID-19 DATA EXPLORATION WITH SQL


*/




-----------------------------------------------------------------------------------------------------

--KPISs FOR TABLEAU VISUALIZATION

--1. Total Cummulative Cases 
select sum(new_cases)   TotalCummulativeCases from PortfolioProjects..CovidDeaths 
where continent is not null


--2. Total Cummulative Deaths
select sum(new_deaths)  TotalCummulativeDeaths from PortfolioProjects..CovidDeaths
where continent is not null


--3. Total Vaccinations
select sum(cast(new_vaccinations as float))  TotalVaccinations 
from PortfolioProjects..CovidVaccinations
where continent is not null

-------------------------------------------------------------------------------------------------------


--MAIN INSIGHTS FOR TABLEAU VISUALIZATION

---1. Cases By year 
select date, max(cast(total_cases as int))  TotalCases
from PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by date 


---2. Deaths By year 
select date, max(cast(total_deaths as int))  TotalDeaths
from PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by date 


--3. Total Cases by Country 
select location  Country, 
max(cast(total_cases as int))  TotalCases
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
Order by TotalCases desc


--4. Total Deaths by country
select location  Country, 
max(cast(total_deaths as int))  TotalDeaths
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
Order by TotalDeaths desc


--5. Total Deaths by country (Top 10)
select Top (10) location  Country, 
max(cast(total_deaths as int))  TotalDeaths
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
Order by TotalDeaths desc


--6. Total Vaccinations by Country (Top 10)
select Top (10) location  Country, max(cast(total_vaccinations as float))  
TotalVaccinations
from PortfolioProjects..CovidVaccinations
where continent is not null
group by location
order by TotalVaccinations desc

--------------------------------------------------------------------------------------------


--OTHER INSIGHTS 

--Total cases vs Total deaths by Country 
select Location, date, cast(total_cases as int)  TotalCases,  
cast(total_deaths as int)  TotalDeaths, 
(cast(total_deaths as float))/(cast(total_cases as float))
  DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1, 2


--Total cases vs Total Population 
select Location, date, population,  
total_cases, (total_cases/population) * 100
  PercentCases
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1, 2


--Looking at Countries with Highest infection rate compared to Population?
select Location  Country, population, 
max(cast(total_cases as int))  HighestInfectionCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by Location, population,  
total_cases
order by HighestInfectionCount desc


--Countries with the Highest Death count per population
select location  Country,  
max(cast(total_deaths as int))  HihgestDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by HihgestDeathCount desc


--BREAKING BY CONTINENTS 
----Continents with the Highest Death count per population
select location  Continent, 
max(cast(total_deaths as int))  HihgestDeathCount
from PortfolioProjects..CovidDeaths
where continent is null
group by location
order by HihgestDeathCount desc


---NEW CASES VS NEW DEATHS GLOBALLY
select date, sum(new_cases)  TotalNewCases, sum(new_deaths)  TotalNewDeaths,
(sum(new_deaths))/(sum(new_cases)) * 100  DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null and new_cases <> 0
group by date  
order by 1



---Coountry By Population and Vaccination (TotalNewVaccinations)
select dea.date, dea.continent, dea.location  Country, 
population, new_vaccinations,
sum(convert(float, new_vaccinations)) over 
(Partition by dea.location)
  TotalNewVaccinations 
from PortfolioProjects..CovidDeaths  dea
join PortfolioProjects..CovidVaccinations  vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null 
order by 2, 3


---Coountry By Population and Vaccination (CummulativeNewVaccinations)
select dea.date, dea.continent, dea.location  Country, 
population, new_vaccinations,
sum(convert(float, new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date)
  CummulativeNewVaccinations
from PortfolioProjects..CovidDeaths  dea
join PortfolioProjects..CovidVaccinations  vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null 
order by 2, 3

-----------------------------------------------------------------------------------------------------------------



---USING #TEMP TABLE

Drop Table if exists #VaccinationPopulationPercentage
Create Table #VaccinationPopulationPercentage
(date datetime,
Continent nvarchar(255),
Country nvarchar(255),
Population numeric,
New_vaccinations numeric,
CummulativeNewVaccinations numeric)

Insert into #VaccinationPopulationPercentage
select dea.date, dea.continent, dea.location  Country, 
population, new_vaccinations,
sum(convert(float, new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date)
  CummulativeNewVaccinations 
from PortfolioProjects..CovidDeaths  dea
join PortfolioProjects..CovidVaccinations  vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null 
order by 2, 3

Select date, Continent, Country, Population, New_vaccinations,
CummulativeNewVaccinations, (CummulativeNewVaccinations/Population) * 100
  PercentNewCummVaccinations
from #VaccinationPopulationPercentage

----------------------------------------------------------------------------------------------------------



---VIEW FOR LATER VISUALIZATION

Create View PercentNewCummVaccinations as
select dea.date, dea.continent, dea.location  Country, 
population, new_vaccinations,
sum(convert(float, new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date)
  CummulativeNewVaccinations 
from PortfolioProjects..CovidDeaths  dea
join PortfolioProjects..CovidVaccinations  vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null 
--order by 2, 3

select * from PercentNewCummVaccinations