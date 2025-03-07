
# Global COVID Analytics Project


### Tableau Dynamic Dashboard Link : https://public.tableau.com/app/profile/marwah.al.badran7318/viz/Covid19Dashboard_17412275319120/Covid19Dashboard#1


## Project Description:

This Tableau Global COVID Analytics Dashboard provides a comprehensive analysis of the pandemic’s global impact. It is a powerful tool for understanding COVID-19’s global impact, facilitating data-driven public health strategies. It enables policymakers, researchers, and analysts to track trends, assess regional disparities, and make data-driven decisions.


## Key Metrics Tracked:

- Total Cases – Cumulative confirmed COVID-19 cases globally.

- Total Deaths – Number of reported deaths due to COVID-19.

- Death Percentage – Mortality rate based on confirmed cases.

- Total Deaths by Continent – Breakdown of fatalities across major regions.

- Percent Population Infected by Country – Infection rates relative to the total population.

- Top 10 Countries with the Highest Infection Rate – Identifies the most affected countries over time.


## Key Features

- Global Overview Panel – Displays total cases, deaths, and mortality rate in a structured format.

- Interactive Heat Map – Visualizes the infection rate by country for easy regional comparison.

- Death Distribution by Continent – A pie chart representing COVID-19 fatalities by continent.

- Time-Series Analysis – Tracks infection rates across multiple quarters to identify trends.

- Country-Level Deep Dive – Highlights the highest infection rates relative to population.



## Use Cases

- Policy Decision-Making – Governments can use insights to evaluate past interventions and plan future strategies.

- Public Awareness – Offers an interactive way for individuals to understand COVID-19 trends in their region.

- Healthcare Resource Allocation – Helps organizations identify high-risk areas requiring urgent medical support.


## Insights & Findings

- Global Impact – Over 150 million reported cases and 3.18 million deaths, with a 2.11% mortality rate.

- Regional Disparities – Europe and North America show the highest fatality numbers, followed by South America and Asia.

- Infection Hotspots – Countries like Andorra, Montenegro, Czechia, and San Marino show the highest infection rates.

- Quarterly Trends – Infection rates peaked in specific quarters, reflecting policy changes, lockdowns, and vaccination efforts.


## Recommendations

- Vaccination & Prevention – High-risk countries should strengthen vaccination campaigns and preventive measures.

- Healthcare System Readiness – Authorities should assess healthcare capacity based on mortality rate trends.

- Data Transparency & Reporting – More granular data can enhance global understanding and response strategies.



## Technical Details Summary

- Data Source: Excel CSV files (CovidDeath & CovidVaccinations).

- Database & Querying:  Creating database views using SQL for analysis).

- Visualization Tool: Tableau (interactive dashboards, geographic maps, trend analysis).






## Final Dashboard (Snapshot)

![Image](https://github.com/user-attachments/assets/83a46aee-6ffb-4663-b5f4-0be0faa76d96)




## Step-by-Step Data Analysis & Visualization Process in SQL & Tableau

- Created SQL queries and saved them as views for efficient data retrieval.

- Structured data in a way that allowed seamless integration with Tableau.

- Visualization Tool: Tableau for interactive data representation and insights.


# 1.SQL 

#### Test the Data in both main tables of  Dataset 

       Select *
       From Covid19..CovidDeaths
       Where continent is NOT NULL
       Order by 3,4

       Select *
       From Covid19..CovidVaccinations
       Order by 3,4



#### Select the Data that we are being to be using 

        Select location,date ,total_cases,new_cases,total_deaths,population
        From Covid19..CovidDeaths
        Where continent is NOT NULL
        Order by 1,2


#### Create View for Total Cases Vs Total Death 

      CREATE VIEW TotalCases_vs_TotalDeaths AS
      Select location,date,total_cases,total_deaths
      ,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
     --Return Null if total_cases=0 (to avoid division by zreo as division
     --by zero is not allowed in SQL
       From Covid19..CovidDeaths
       Where location like '%states%' and continent is NOT NULL
     --Order by 1,2

#### Creat view Total cases vs population

       Create View TotalCases_vs_Population as
      --Looking at the Total Cases vs Population
      --Shows what percentage of population got covid
       Select  location ,date ,total_cases ,total_deaths ,population
      ,(total_cases/population)*100 as CovidSpreadRate
      --To round result to 3 decimal point use Round functon directly to the calcualtion
      --,Round((total_cases/population)*100,3) as CovidSpreadRate
       From Covid19..CovidDeaths
       Where continent is NOT NULL
      --WHERE location Like '%States%'
      -Order by 1,2


##### Finding the Highest Infection rate comared to Population

      Select location ,populatio ,Max(total_cases) as HighestInfectionCount
     ,Max((total_cases/population))*100 as CovidSpreadRate
      From Covid19..CovidDeaths
      Where continent is NOT NULL
      Group by location, population
      Order by  CovidSpreadRate Desc


#### Showing the Vountries with the highest death count per population

      Select location ,population
     ,Max (cast(total_deaths as int)) as HighestDeathCount
     ,Max(Total_deaths/population) as CovidDeathPercentage
      From Covid19..CovidDeaths
      Where continent is NOT NULL
     Group by location, population
     Order by HighestDeathCount desc

#### Braking things down by continent 

      Select location
     ,Max (cast(total_deaths as int)) as HighestDeathCount
      From Covid19..CovidDeaths
      Where continent is NULL
      Group by location
      Order by HighestDeathCount Desc


#### Finding the continent with highest Deaths Count per population

     Select 
     continent
     ,Max (cast(total_deaths as int)) as HighestDeathCount
     From Covid19..CovidDeaths
     Where continent is Not NULL
     Group by continent
     Order by HighestDeathCount Desc

#### Daily Global Numbers 

       Select date
      ,SUM(new_cases) as Total_Cases
      ,SUM(cast(new_deaths as int)) as Total_Deaths
      ,SUM (cast(new_deaths as int))/SUM (new_cases)*100 as GlobalDeathsPercentage
       From Covid19..CovidDeaths
       Where continent is not null
       Group by date
       Order by 1,2

#### Total Global Numbers

     Select 
     SUM(new_cases) as Total_Cases
     ,SUM(cast(new_deaths as int)) as Total_Deaths
     ,SUM (cast(new_deaths as int))/SUM (new_cases)*100 as GlobalDeathsPercentage
     From Covid19..CovidDeaths
     Where continent is not null


#### Create Join table to look to Total population vs Vaccination 

      Select *
      From Covid19..CovidVaccinations  D
      Join Covid19..CovidVaccinations  V
      on D.location=V.location
      and D.date=V.date

## Then

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

 #### Showing the rolling count of daily new vaccinations for each country, 
####  Using order by location and date it will keep adding  up the daily new VAC.
#### Using Parttition by function mean breaking down


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


##### Finding the Percentage of vaccinations relative to population

       Select
       D.continent
      ,D.location
      ,D.date
      ,D.population
      ,V.new_vaccinations
      ,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,D.date) As Rolling_People_Vaccinated
     --,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
       you just cannot use a column you just created to do another one so we need to do a Common Table Expression (CTE) or a temp-table
      From Covid19..CovidDeaths  D
      Join Covid19..CovidVaccinations  V
      on D.location=v.location
      and D.date=v.date 
      where D.continent is not null
      order by 2,3


#### USE Common Table Expression CTE

     
     With 
     Pop_vs_Vac (continent, location, date,population,new_vaccinations, Rolling_People_Vaccinated)
     as
     (
     Select
     D.continent
     ,D.location
     ,D.date
     ,D.population
     ,V.new_vaccinations
     ,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by    D.location,D.date) As Rolling_People_Vaccinated
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


#### To find the Max getrid of the date and keep location and other columns.

     With 
     Pop_vs_Vac (continent, location,population,new_vaccinations,Rolling_People_Vaccinated)
     as
     (
     Select
     D.continent
    ,D.location
    ,D.population
    ,V.new_vaccinations
    ,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by   D.location,D.date) As Rolling_People_Vaccinated
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



#### Option 2 is using TEMP Table 
#### The final query calculates and retrieves the percentage of the populatoin vaccinated.
    

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
    ,Sum(convert(int,V.new_vaccinations)) over (partition by D.location order by   D.location,D.date) As Rolling_People_Vaccinated
    --,(Rolling_People_Vaccinated/population)*100 As Vac_vs_Pop
    From Covid19..CovidDeaths  D
    Join Covid19..CovidVaccinations  V
    on D.location=v.location
    and D.date=v.date 
    where D.continent is not null
    --order by 2,3

    Select *
    ,(Rolling_People_Vaccinated/Population)*100 as   Percentage_Population_Vaccninaed
    From #PercentagePopulationVaccninaed
    order by location, date





# 2.Tableau

## The Queries Queries used for Tableau Project are:

### View 1 (TotalCases_VS_TotalDeaths)

     DROP VIEW IF EXISTS 
     Go
     Create View TotalCases_VS_TotalDeaths as
     Select 
     SUM(new_cases) as total_cases
     ,SUM(cast(new_deaths as int)) as total_deaths
     ,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
     From Covid19..CovidDeaths
    --Where location like '%states%'
    where continent is not null 
    --Group By date
    order by 1,2

  This view aggregates total cases and deaths and calculates the death percentage, which is used in the Global Overview Panel.

  ![Image](https://github.com/user-attachments/assets/db2a9df0-d78f-4377-b1b4-733e4b8d5d3a)


### View 2 (Total Deaths Count by Continent)


      Select 
      location
     ,SUM(cast(new_deaths as int)) as TotalDeathCount
      From Covid19..CovidDeaths
      --Where location like '%states%'
      Where continent is null 
      and location not in ('World', 'European Union', 'International')
      Group by location
      order by TotalDeathCount desc

 This view helps generate a pie chart of total Global Covid deaths by continent.


![Image](https://github.com/user-attachments/assets/fea6d982-7dee-49de-84ef-d5df7067499a)


### View 3 (Countries with the hightest Infection count per population)

     Select
     Location
     , Population
     , MAX(total_cases) as HighestInfectionCount
     , Max((total_cases/population))*100 as PercentPopulationInfected
     From Covid19..CovidDeaths
     --Where location like '%states%'
     Group by Location, Population
     order by PercentPopulationInfected desc)

This view supports the heat map visualization, showing the infection rate per country.

![Image](https://github.com/user-attachments/assets/af1ca8fd-4803-4d7a-a04e-842fbc1b8297)


#### View 4 (Countries with the hightest Infection count per population by dates)

     Select 
     Location
    ,Population
    ,date
    ,MAX(total_cases) as HighestInfectionCount
    ,Max((total_cases/population))*100 as PercentPopulationInfected
    From Covid19..CovidDeaths
    --Where location like '%states%'
    Group by Location, Population, date
    order by PercentPopulationInfected desc

This view enables a time-series analysis to track infection rates by date.

![Image](https://github.com/user-attachments/assets/76404f60-9719-41e4-ba68-1eac991a85ea)
