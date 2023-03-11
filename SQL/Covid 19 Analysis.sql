--shows what percentage of people have got covid

select location , date , total_cases , (total_cases/population)*100 as InfectionPercentage
from [covid-deaths]
order by 1,2


--shows what percentage of people have died from covid

select location , date , total_deaths , (total_deaths/population)*100 as DeathPercentage
from [covid-deaths]
order by 1,2


--shows which countries have the most covid infection 

select location , max(total_cases) as InfectionCount
from [covid-deaths]
group by location
order by InfectionCount desc

--shows what countries have the most covid death 

select location , max(cast(total_deaths as int)) as DeathsCount
from [covid-deaths]
where continent is not null
group by location
order by DeathsCount desc

--shows how many of people have died by continent

select location , max(cast(total_deaths as int)) as DeathsCount
from [covid-deaths]
where continent is null
group by location
order by DeathsCount desc

--shows how many of people have infected by continent

select continent , max(total_cases) as CasesCount
from [covid-deaths]
where continent is not null
group by continent
order by CasesCount desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from [covid-deaths]
where continent is not null
--group by date
order by 1,2



--shows total population vs vaccination

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location , dea.date) as CurrentVaccinated
 -- , (CurrentVaccinated/population)*100 it didn't work so we should do it with CTE
from [covid-deaths] dea
join [covid-vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopVSVac(continent, location, date, population, new_vaccinations, CurrentVaccinated)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location , dea.date) as CurrentVaccinated
from [covid-deaths] dea
join [covid-vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
--some people have done the second dose some haven't
select *, (CurrentVaccinated/population)*100 as popvsvac
from PopVSVac



--temp taple
create table #poppervacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CurrentVaccinated numeric,
)
insert into #poppervacc
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location , dea.date) as CurrentVaccinated
from [covid-deaths] dea
join [covid-vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (CurrentVaccinated/population)*100
from #poppervacc



--create view to store data for later visuallization
create view poppervacc as 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location , dea.date) as CurrentVaccinated
from [covid-deaths] dea
join [covid-vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from poppervacc