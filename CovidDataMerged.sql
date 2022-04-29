-- Contains Locationwise,Continentwise,worldwide Parameters and DailyChange Parameters
-------------------------------------------------------------------------------------
SELECT *
FROM CovidPortfolioProject..CovidDeaths
---------------------------------------------------------------------------------------
SELECT *
FROM CovidPortfolioProject..CovidVaccinations
WHERE location LIKE '%india%'
--------------------------------------------------------------------------------------------------------
--LOCATION,CONTINENT AND GLOBAL STATISTICS

SELECT	dea.continent AS Continent,
		dea.location AS Location,
		dea.population Population,
		MAX(dea.total_cases) AS TotalCases,						-- Gives total Number Of Cases for each location
		SUM(dea.new_cases) AS RollingCases,						-- Gives total Number Of Cases for each location by using SUM function on column new_cases.(This is just to check TotalCases = RollingCases)
		MAX(CONVERT(bigint,dea.total_deaths)) AS TotalDeaths,	-- Gives total number of deaths for ech location
		SUM(CONVERT(bigint,dea.new_deaths)) AS RollingDeaths,	-- Gives total number of deaths for each location by using SUM function on column new_deaths.(This is just to check TotalDeaths = RollingDeaths)
		MAX(CONVERT(bigint,vac.total_tests)) AS TotalTests,     -- Gives total number of covid tests for each location
		SUM(CONVERT(bigint,vac.new_tests)) AS RollingTests,     -- Gives total number of covid tests for each location by using SUM function on column new_tests.(This is just to check TotalTests = RollingTests)
		SUM(CONVERT(bigint,vac.new_tests_smoothed)) AS RollingTestsSmoothed, -- Corrected column for new_tests
		MAX(CONVERT(bigint,vac.total_vaccinations)) AS TotalVaccinations,  -- Gives number of Vaccinations Used
		SUM(CONVERT(bigint,vac.new_vaccinations)) AS RollingVaccinations,  -- Gives number of Vaccinations Used by using SUM function on column new_vaccinations.(This is just to check TotalVaccinations = RollingVaccinations)
		SUM(CONVERT(bigint,vac.new_vaccinations_smoothed)) AS RollingVaccinationsSmoothed, --Corrected column for new_Vaccinations
		MAX(CONVERT(bigint,vac.people_vaccinated)) AS AtleastFirstDose,   -- Gives number of people having first or Both dosage
		MAX(CONVERT(bigint,vac.people_fully_vaccinated))AS FullVaccinations, -- Gives number of people with both dosage 
		MAX(CONVERT(bigint,vac.total_boosters)) AS BoosterVaccinations -- Gives number of people with Booster dosage
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND
dea.location = vac.location
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent,
		 dea.location,
		 dea.population
ORDER BY dea.continent,dea.location

DROP TABLE IF EXISTS #CovidAnalysis 
CREATE TABLE #CovidAnalysis
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Population numeric,
	TotalCases numeric,
	RollingCases numeric,
	TotalDeaths numeric,
	RollingDeaths numeric,
	TotalTests numeric,
	RollingTests numeric,
	RollingTestsSmoothed numeric,
	TotalVaccinations numeric,
	RollingVaccinations numeric,
	RollingVaccinationsSmoothed numeric,
	AtleastFirstDose numeric,
	FullVaccinations numeric,
	BoosterVaccinations numeric
)
INSERT INTO #CovidAnalysis
SELECT	dea.continent AS Continent,
		dea.location AS Location,
		dea.population Population,
		MAX(dea.total_cases) AS TotalCases,						
		SUM(dea.new_cases) AS RollingCases,						
		MAX(CONVERT(bigint,dea.total_deaths)) AS TotalDeaths,	
		SUM(CONVERT(bigint,dea.new_deaths)) AS RollingDeaths,	 
		MAX(CONVERT(bigint,vac.total_tests)) AS TotalTests,     
		SUM(CONVERT(bigint,vac.new_tests)) AS RollingTests,     
		SUM(CONVERT(bigint,vac.new_tests_smoothed)) AS RollingTestsSmoothed,
		MAX(CONVERT(bigint,vac.total_vaccinations)) AS TotalVaccinations,  
		SUM(CONVERT(bigint,vac.new_vaccinations)) AS RollingVaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations_smoothed)) AS RollingVaccinationsSmoothed,
		MAX(CONVERT(bigint,vac.people_vaccinated)) AS AtleastFirstDose,   
		MAX(CONVERT(bigint,vac.people_fully_vaccinated))AS FullVaccinations,  
		MAX(CONVERT(bigint,vac.total_boosters)) AS BoosterVaccinations 
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND
dea.location = vac.location
GROUP BY dea.continent,
		 dea.location,
		 dea.population
ORDER BY dea.continent,dea.location
-------------------------------------------------------------------------------
SELECT *
FROM  #CovidAnalysis
---------------------------------------------------------------------------------

--LOCATION WISE INFORMATION
SELECT	Continent,
		Location,
		Population,
		TotalCases,
        TotalCases/Population*100 As PercentPopulationInfect,
	    TotalTests,
		TotalTests/Population*100 AS PercentPopulationTest,
		TotalDeaths,
		TotalDeaths/Population*100 AS PercentPopulationDeath,
		TotalDeaths/TotalCases*100 AS InfectionDeathPercentage,
		TotalVaccinations,
		TotalVaccinations/Population*100 AS PercentVaccinationsUsed, 
		AtleastFirstDose,
		AtleastFirstDose/Population*100 AS FirstorBothDosePercentage,
		FullVaccinations,
		FullVaccinations/Population*100 AS BothDosagePercentage,
		(AtleastFirstDose-FullVaccinations) AS PartiallyVaccinated,    -- Number of People having only first dose
		(AtleastFirstDose-FullVaccinations)/Population*100 AS PartiallyVaccinatedPercentage,
		BoosterVaccinations,
		BoosterVaccinations/Population*100 AS BoosterDosePercentage
FROM #CovidAnalysis
WHERE Continent IS NOT NULL


-- CONTINENT WISE INFORMATION
SELECT	Location,
		Population,
		TotalCases,
        TotalCases/Population*100 As PercentPopulationInfect,
	    TotalTests,
		TotalTests/Population*100 AS PercentPopulationTest,
		TotalDeaths,
		TotalDeaths/Population*100 AS PercentPopulationDeath,
		TotalDeaths/TotalCases*100 AS InfectionDeathPercentage,
		TotalVaccinations,
		TotalVaccinations/Population*100 AS PercentVaccinationsUsed, 
		AtleastFirstDose,
		AtleastFirstDose/Population*100 AS FirstorBothDosePercentage,
		FullVaccinations,
		FullVaccinations/Population*100 AS BothDosagePercentage,
		(AtleastFirstDose-FullVaccinations) AS PartiallyVaccinated,    -- Number of People having only first dose
		(AtleastFirstDose-FullVaccinations)/Population*100 AS PartiallyVaccinatedPercentage,
		BoosterVaccinations,
		BoosterVaccinations/Population*100 AS BoosterDosePercentage
FROM #CovidAnalysis
WHERE Location IN ('Africa', 'Asia','Europe','North America','Oceania','South America')


-- GLOBAL INFORMATION
SELECT	Location,
		Population,
		TotalCases,
        TotalCases/Population*100 As PercentPopulationInfect,
	    TotalTests,
		TotalTests/Population*100 AS PercentPopulationTest,
		TotalDeaths,
		TotalDeaths/Population*100 AS PercentPopulationDeath,
		TotalDeaths/TotalCases*100 AS InfectionDeathPercentage,
		TotalVaccinations,
		TotalVaccinations/Population*100 AS PercentVaccinationsUsed, 
		AtleastFirstDose,
		AtleastFirstDose/Population*100 AS FirstorBothDosePercentage,
		FullVaccinations,
		FullVaccinations/Population*100 AS BothDosagePercentage,
		(AtleastFirstDose-FullVaccinations) AS PartiallyVaccinated,    -- Number of People having only first dose
		(AtleastFirstDose-FullVaccinations)/Population*100 AS PartiallyVaccinatedPercentage,
		BoosterVaccinations,
		BoosterVaccinations/Population*100 AS BoosterDosePercentage
FROM #CovidAnalysis
WHERE Location like '%world%'

-------------------------------------------------------------------------------------------------------------------------

-- Daily Statistics 

WITH DailyCovidStats(Date,Continent,Location,Population,TotalCases,DailyCases,PositiveRate,TestPerCase,StringencyIndex,TotalDeaths,DailyDeaths,TotalTests,DailyTest,DailyTestsSmoothed,TotalVaccinations,DailyVaccinations,DailyVaccinationsSmoothed,AtleastFirstDose,FullVaccinations,BoosterVaccinations,ReproductionRate)
AS
(
SELECT	dea.date AS Date,
		dea.continent AS Continent,
		dea.location AS Location,
		dea.population Population,
		dea.total_cases AS TotalCases,					
		CONVERT(bigint,dea.new_cases) AS DailyCases,
		CONVERT(float,vac.positive_rate) AS PositiveRate,
		CONVERT(float,vac.tests_per_case) AS TestPerCase,
		vac.stringency_index AS StringencyIndex,
		CONVERT(bigint,dea.total_deaths) AS TotalDeaths, 	
		CONVERT(bigint,dea.new_deaths)  AS DailyDeaths ,	 
		CONVERT(bigint,vac.total_tests) AS TotalTests,     
		CONVERT(bigint,vac.new_tests) AS DailyTests, -- not reliable
		CONVERT(bigint,vac.new_tests_smoothed) AS DailyTestsSmoothed, --Corrected column for new_tests
		CONVERT(bigint,vac.total_vaccinations) AS TotalVaccinations,  
		CONVERT(bigint,vac.new_vaccinations)  AS DailyVaccinations, -- not reliable
		CONVERT(bigint,vac.new_vaccinations_smoothed) AS DailyVaccinationsSmoothed, -- Corrected column for new_vaccinations
		CONVERT(bigint,vac.people_vaccinated) AS AtleastFirstDose,   
		CONVERT(bigint,vac.people_fully_vaccinated) AS FullVaccinations,  
		CONVERT(bigint,vac.total_boosters) AS BoosterVaccinations,
		CONVERT(float,dea.reproduction_rate) AS ReproductionRate
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac
ON dea.date = vac.date AND
dea.location = vac.location 
WHERE dea.location NOT IN('Lower middle income','World','Low income','European Union','International','Upper middle income','High income')
)
SELECT Continent,
	    Location,	
		Date,
		DailyCases,
		TotalCases,
		TotalCases/Population*100 AS PercentPopulationInfected,
		PositiveRate,
		TestPerCase,
		StringencyIndex,
		DailyDeaths,
		TotalDeaths,
		TotalDeaths/Population*100 AS PercentPopulationDeath,
		TotalDeaths/TotalCases*100 AS DeathperCasePercentage,
		ReproductionRate,
		DailyTestsSmoothed,
		TotalTests,
		TotalTests/Population*100 AS PercentPopulationTested,
		DailyVaccinationsSmoothed,
		TotalVaccinations,
		TotalVaccinations/Population*100 AS PercentVaccinationsUsed,
		AtleastFirstDose,
		AtleastFirstDose/Population*100 AS AtleastFirstDosePercentage,
		FullVaccinations,
		FullVaccinations/Population*100 AS FullVaccinationsPercentage,
		AtleastFirstDose-FullVaccinations AS PartiallyVaccinated,
		(AtleastFirstDose-FullVaccinations)/Population*100 PartialVaccinationPercentage,
		BoosterVaccinations,
		BoosterVaccinations/Population*100 As BoosterDosePercentage
FROM DailyCovidStats
ORDER BY 1,2,3

--------------------------------------------------------------------------------------------------------

--looking at constant parameters
SELECT DISTINCT continent,
				location,
				CONVERT(FLOAT,male_smokers) AS MaleSmokerPercentage,
				CONVERT(FLOAT,female_smokers) AS FemaleSmokerPercentage,
				CONVERT(FLOAT,cardiovasc_death_rate) AS CardioVascDeathRate,
				CONVERT(FLOAT,diabetes_prevalence) AS DiabetesPrevalence,
				CONVERT(FLOAT,handwashing_facilities) AS HandWashingFacilities,
				CONVERT(FLOAT,hospital_beds_per_thousand) AS HospitalBedsPerThousand,
				CONVERT(FLOAT,life_expectancy) AS LifeExpectancy,
				CONVERT(FLOAT,population_density) AS PopulationDensity,
				CONVERT(FLOAT,extreme_poverty) AS ExtremePoverty,
				CONVERT(FLOAT,median_age) AS MedianAge,
				CONVERT(FLOAT,aged_65_older) AS Age65_Older,
				CONVERT(FLOAT,aged_70_older) AS Age70_Older,
				CONVERT(FLOAT,gdp_per_capita) AS GDPPerCapita,
				CONVERT(FLOAT,human_development_index) AS HumanDevelopmentIndex
FROM CovidPortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY continent 
