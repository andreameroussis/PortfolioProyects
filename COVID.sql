SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--WHERE continent is not null
--order by 3,4


--Seleccionar data que usaremos

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

select location
from PortfolioProject..CovidDeaths
WHERE continent is not null
group by location
order by location ASC

--Revisando los casos totales VS total de fallecidos
--Muestra la probabilidad de fallecer en tu pais si te contagias de Covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
WHERE continent is not null
AND WHERE location like '%peru%'
order by 2 


-- Casos totales VS Población
-- Muestra quee porcentaje de la población tiene Covid

select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
WHERE continent is not null
-- WHERE location like '%peru%'
order by 1,2


-- Analizando los países con la tasa de infección más alta en comparación con la población

select location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
WHERE continent is not null
-- WHERE location like '%peru%'
GROUP BY location,  population
order by PercentPopulationInfected DESC


-- Mostrando los países con el mayor recuento de muertes por población

select location, MAX(total_deaths) AS TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
-- WHERE location like '%peru%'
GROUP BY location
order by TotalDeathCount DESC


-- Vamos a desglosar las cosas por continente

-- Mostrando los continentes con el mayor recuento de muertes por población

select continent, MAX(total_deaths) AS TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
-- WHERE location like '%peru%'
GROUP BY continent
order by TotalDeathCount DESC


-- NUMEROS GLOBALES

SELECT 
	SUM(cast(new_cases AS float)) AS Total_cases, 
	SUM(cast(new_deaths AS float)) AS Total_deaths, 
	SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- AND location like '%peru%'
-- GROUP BY date
ORDER BY 1, 2


-- Revisando el total de Poblacion VS Vacunados

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVacinated,
	-- (RollingPeopleVacinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USAR CTE

WITH PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVacinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



-- TEMP TABLE

CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVacinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creando una vista para almacenar datos para visualizaciones posteriores

create view PercentPopulationVaccinated AS 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVacinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

------------------------------------------

create view DeathPercentage AS 
SELECT 
	SUM(cast(new_cases AS float)) AS Total_cases, 
	SUM(cast(new_deaths AS float)) AS Total_deaths, 
	SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- AND location like '%peru%'
-- GROUP BY date
-- ORDER BY 1, 2

----------


create view ContinentDeathCount AS 
select continent, MAX(total_deaths) AS TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
-- WHERE location like '%peru%'
GROUP BY continent
-- order by TotalDeathCount DESC