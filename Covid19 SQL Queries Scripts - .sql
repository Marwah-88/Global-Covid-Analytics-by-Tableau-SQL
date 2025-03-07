

Select *
From Covid19..CovidDeaths
Where continent is NOT NULL
Order by 3,4

--Select *
--From Covid19..CovidVaccinations
--Order by 3,4


--Select Data that we are being to be using 
Select 
location
,date
,total_cases
,new_cases
,total_deaths
,population
From Covid19..CovidDeaths
Where continent is NOT NULL
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

DROP VIEW IF EXISTS dbo.TotalCases_vs_TotalDeaths
Go

CREATE VIEW TotalCases_vs_TotalDeaths AS
Select
location
,date
,total_cases
,total_deaths
,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
--Return Null if total_cases=0 (to avoid division by zreo as division
--by zero is not allowed in SQL
From Covid19..CovidDeaths
Where location like '%states%' and continent is NOT NULL
--Order by 1,2


Select SUM(new_cases) as total_cases
,SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid19..CovidDeaths
----Where location like '%states%'
where location = 'World'
--Group By date
order by 1,2




DROP VIEW IF EXISTS dbo.TotalCases_vs_Population
Go

Create View TotalCases_vs_Population as
--Looking at the Total Cases vs Population
--Shows what percentage of population got covid
Select 
location
,date
,total_cases
,total_deaths
,population
,(total_cases/population)*100 as CovidSpreadRate
--To round result to 3 decimal point use Round functon directly to the calcualtion
--,Round((total_cases/population)*100,3) as CovidSpreadRate
From Covid19..CovidDeaths
Where continent is NOT NULL
--WHERE location Like '%States%'
--Order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
Select
location
,population	
,Max(total_cases) as HighestInfectionCount
,Max((total_cases/population))*100 as CovidSpreadRate
From Covid19..CovidDeaths
Where continent is NOT NULL
Group by location, population
Order by  CovidSpreadRate Desc

--Showing the Countries with the hightest death count per population
 Select 
 location
 ,population
 ,Max (cast(total_deaths as int)) as HighestDeathCount
 ,Max(Total_deaths/population) as CovidDeathPercentage
 From Covid19..CovidDeaths
 Where continent is NOT NULL
 Group by location, population
 Order by HighestDeathCount desc

 -- Breaking  things down by continent 
 Select 
 location
 ,Max (cast(total_deaths as int)) as HighestDeathCount
 From Covid19..CovidDeaths
 Where continent is NULL
 Group by location
 Order by HighestDeathCount Desc

 --Note that the Dateset including  total case numbers for the every continent 
 --as well as coutry-specific breakdown. This structure allows for effective drill-down analysis during the vidualization stage.
 --Continent then countries 

--Showing the continent with highest Deaths Count per population
 Select 
 continent
 ,Max (cast(total_deaths as int)) as HighestDeathCount
 From Covid19..CovidDeaths
 Where continent is Not NULL
 Group by continent
 Order by HighestDeathCount Desc


 --Daily Global Numbers
Select 
date
,SUM(new_cases) as Total_Cases
,SUM(cast(new_deaths as int)) as Total_Deaths
,SUM (cast(new_deaths as int))/SUM (new_cases)*100 as GlobalDeathsPercentage
From Covid19..CovidDeaths
Where continent is not null
Group by date
Order by 1,2



 --Total Global Numbers
Select 
SUM(new_cases) as Total_Cases
,SUM(cast(new_deaths as int)) as Total_Deaths
,SUM (cast(new_deaths as int))/SUM (new_cases)*100 as GlobalDeathsPercentage
From Covid19..CovidDeaths
Where continent is not null



--Looking to total population vs vaccinations by creating Join between tables 
Select *
From Covid19..CovidVaccinations  D
Join Covid19..CovidVaccinations  V
on D.location=V.location
and D.date=V.date

--Looking to total population vs vaccinations
Select 
 D.continent
,D.location
,D.date
,D.population
,V.new_vaccinations
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
On D.location=V.location
and D.date=V.date
Where D.continent is not Null
Order by 2,3


--Showing the rolling count of daily new vaccinations for each country.
--Without the order by location and date the new column will keep showing the final total of Vac for the locaction 
--while with using order by location and date it will keep adding  up the daily new VAC 
--Using Parttition by function mean breaking down
Select
 D.continent
,D.location
,D.date
,D.population
,V.new_vaccinations
,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vsccinated
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
on D.location=v.location
and D.date=v.date 
where D.continent is not null
order by 2,3


--Showing the percentage of vacciatons relative to population 
Select
 D.continent
,D.location
,D.date
,D.population
,V.new_vaccinations
,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
--you just cannot use a column you just created to do another one so we need to do a Common Table Expression (CTE) or a temp-table
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
on D.location=v.location
and D.date=v.date 
where D.continent is not null
order by 2,3


 
-- USE Common Table Expression (CTE)

 With 
 Pop_vs_Vac (continent, location, date,population,new_vaccinations,Rolling_People_Vaccinated)
 as
 (
Select
 D.continent
,D.location
,D.date
,D.population
,V.new_vaccinations
,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
on D.location=v.location
and D.date=v.date 
where D.continent is not null
--order by 2,3
)
Select *
,(Rolling_People_Vaccinated/Population)*100 as Vaccinated_People_Rate
From Pop_vs_Vac
order by location, date
--For example 12% of people vaccinated in Albania



 
 --To find the Max getrid of the date and keep location and other columns.
 With 
 Pop_vs_Vac (continent, location,population,new_vaccinations,Rolling_People_Vaccinated)
 as
 (
Select
 D.continent
,D.location
,D.population
,V.new_vaccinations
,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
on D.location=v.location
and D.date=v.date 
where D.continent is not null

--order by 2,3
)
Select
 location
,population
,Max(Rolling_People_Vaccinated) as Max_Rolling_Vaccinated
,Max(Rolling_People_Vaccinated/Population)*100 as Vaccinated_People_Rate
From Pop_vs_Vac
Group by location,population
order by Vaccinated_People_Rate Desc



--Option 2 TEMP TABLE
--The final query calculates and retrieves the percentage of the population vaccinated.

DROP Table if exists  #PercentagePopulationVaccninaed
Create Table #PercentagePopulationVaccninaed
(
continent nvarchar(225)
,location nvarchar(225)
,date datetime
,population numeric
,New_vaccinations numeric
,Rolling_People_Vaccinated Numeric
)
insert into #PercentagePopulationVaccninaed
Select
 D.continent
,D.location
,D.date
,D.population
,V.new_vaccinations
,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
From Covid19..CovidDeaths  D
Join Covid19..CovidVaccinations  V
on D.location=v.location
and D.date=v.date 
where D.continent is not null
--order by 2,3
Select *
,(Rolling_People_Vaccinated/Population)*100 as Percentage_Population_Vaccninaed
From #PercentagePopulationVaccninaed
order by location, date








 
