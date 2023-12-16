select *
from SQL_project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from SQL_project..CovidVaccination
--order by 3,4


--Now we have to select the data that we are going to use here:

select location,date,total_cases,new_cases,total_deaths,population
from SQL_project..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100 as Death_percentage
from SQL_project..CovidDeaths
where continent is not null
order by 1,2

--to get particular country's Death percentage we can do by:
select location,date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100 as Death_percentage
from SQL_project..CovidDeaths
where location ='india'
and continent is not null
order by 1,2


--Total cases Vs Population ...it means we are going to calculate what percentage of population are get infected by covid or percentage of new cases of population

select location,date,total_cases,population,(total_cases/population)*100 as cases_percenatge
from SQL_project..CovidDeaths
where continent is not null
order by 1,2

--now we are going to looking at highest cases across the world or population:
select location,population,max(total_cases) as highestcases,max(total_cases/cast(population as float))*100 as Highestcase_per
from SQL_project..CovidDeaths
--where location ='india'
where continent is not null
group by location,population
order by 1,2

-- Highest Death count percentage
select location,population,max(total_deaths) as highestdeaths,max(total_deaths/cast(population as float))*100 as Highestdeath_per
from SQL_project..CovidDeaths
--where location ='india'
where continent is not null
group by location,population
order by highestdeaths desc


--continents with highest death counts

select continent,max(total_deaths) as highestdeaths
from SQL_project..CovidDeaths
--where location ='india'
where continent is not null
group by continent
order by highestdeaths desc

--Global:

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/Nullif(sum(new_cases),0))*100 as Deathper
from SQL_project..CovidDeaths
where continent is not null
group by date
order by 1,2


--covidvaccination data:

select * 
from SQL_project..CovidVaccination

--let's join both coviddeaths and covidvaccination data

select *
from SQL_project..CovidDeaths dea
join SQL_project..CovidVaccination vac
    on dea.location= vac.location
	and dea.date = vac.date


--Now totalpopulation vs vaccinations
-- so looking at the total people in the population get vaccinated

with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated )
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(nullif(Cast(vac.new_vaccinations as float),0)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from SQL_project..CovidDeaths dea
join SQL_project..CovidVaccination vac
    on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(Rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP TABLE:
drop table if exists vaccinatedpercent
create table vaccinatedpercent(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO vaccinatedpercent
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(nullif(Cast(vac.new_vaccinations as float),0)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from SQL_project..CovidDeaths dea
join SQL_project..CovidVaccination vac
    on dea.location= vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--Creating views which we are going to use for late visulaization

create view vaccinatedpercentage as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(nullif(Cast(vac.new_vaccinations as float),0)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from SQL_project..CovidDeaths dea
join SQL_project..CovidVaccination vac
    on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from vaccinatedpercentage