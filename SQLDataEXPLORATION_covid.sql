--Select * 
--From Portfolioproject.dbo.CovidDeaths
--Where Continent is not NULL
--order by 3,4

--Select * 
--From Portfolioproject.dbo.CovidVaccinations
--order by 3,4


--Selecting Data that we are going to use :

Select Location,date,total_cases,new_cases,total_deaths,population
From Portfolioproject.dbo.CovidDeaths
Where Continent is not NULL
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if someone contracts covid in your country

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
From Portfolioproject.dbo.CovidDeaths
WHERE location like '%stral%' AND date > '2022-12-31' AND Continent is not NULL
order by 1,2 desc

--Looking at Total cases vs Population
-- shows what percentage of population got covid 

Select Location,date,total_cases,Population,(total_cases/population)*100 AS covid_Popluation_Percentage
From Portfolioproject.dbo.CovidDeaths
--WHERE location like '%stral%' AND date > '2022-12-31' AND Continent is not NULL
order by 1,2 desc

--Looking at countries with highest infection rate compared to population

Select Location,MAX(total_cases) AS HighestInfectionCount,Population,MAX((total_cases/population))*100 AS covid_Population_Percentage
From Portfolioproject.dbo.CovidDeaths
Where Continent is not NULL

--group by population, location
--order by covid_Population_Percentage desc

--showing countries with highest death count per population

select location,Population,Max(Cast(Total_deaths As int)) AS TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
Where Continent is not NULL
group by location,population
order by TotalDeathCount desc

--Lets break things down by CONTINENT

select continent,Max(Cast(Total_deaths As int)) AS TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
Where continent is not NULL
group by continent
order by TotalDeathCount desc

--showing the Continent with Highest Death Count 

select continent,Max(Cast(Total_deaths As int)) AS TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
Where continent is not NULL
group by continent
order by TotalDeathCount desc

--GLobal Numbers

Select Date,SUM(new_cases) AS TOTAL_CASES,SUM(CAST(new_deaths as int)) AS TOTAL_DEATHS,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS NEW_Death_Percentage
from PortfolioProject.dbo.CovidDeaths
Where Continent is not NULL
Group By Date
Order by 1,2

Select SUM(new_cases) AS TOTAL_CASES,SUM(CAST(new_deaths as int)) AS TOTAL_DEATHS,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS NEW_Death_Percentage
from PortfolioProject.dbo.CovidDeaths
Where Continent is not NULL
--Group By Date
Order by 1,2

--Joining the tables 

--Looking at total population VS Vaccinations

Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,
From PortfolioProject.dbo.CovidDeaths Dea
Join Portfolioproject.dbo.CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is not NULL
order by 2,3

--USE CTE

With PopVsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths Dea
Join Portfolioproject.dbo.CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--USE Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 