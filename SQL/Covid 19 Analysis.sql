--Shows the percentage of people have got covid

SELECT Location , Date , Total_cases , (Total_cases/Population)*100 AS InfectionPercentage
FROM [Covid-deaths]
ORDER BY 1,2


--Shows what percentage of people have died from covid

SELECT Location , Date , Total_deaths , (Total_deaths/Population)*100 AS DeathPercentage
FROM [Covid-deaths]
ORDER BY 1,2


--Shows which countries have the most covid infection 

SELECT Location , MAX(Total_cases) AS InfectionCount
FROM [Covid-deaths]
GROUP BY Location
ORDER BY InfectionCount DESC

--Shows what countries have the most covid death 

SELECT Location , MAX(cast(Total_deaths AS INT)) AS DeathsCount
FROM [Covid-deaths]
WHERE continent IS NOT NULL
GROUP BY  Location
ORDER BY  DeathsCount DESC

--Shows how many of people have died by continent

SELECT Location , MAX(CAST(Total_deaths AS INT)) AS DeathsCount
FROM [Covid-deaths]
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY DeathsCount DESC

--Shows how many of people have infected by continent

SELECT Continent , MAX(Total_cases) AS CasesCount
FROM [Covid-deaths]
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY CasesCount DESC


--Global numbers

SELECT SUM(New_cases) AS Total_cases, SUM(CAST(New_deaths AS INT)) AS Total_deaths
FROM [Covid-deaths]
WHERE Continent IS NOT NULL
GROUP BY Date



--Shows total Population vs Vaccination

SELECT Death.Continent , Death.Location , Death.Date , Death.Population , Vaccine.New_vaccinations,
SUM(CAST(Vaccine.new_vaccinations AS BIGINT)) OVER (PARTITION BY Death.Location  ORDER BY Death.Location , Death.Date) AS CurrentVaccinated
 -- , (CurrentVaccinated/Population)*100 it didn't work so we should do it with CTE
FROM [Covid-deaths] Death
JOIN [Covid-vaccination] Vaccine
	ON Death.Location = Vaccine.Location
	AND Death.Date = Vaccine.Date
WHERE Death.Continent IS NOT NULL
ORDER BY 2,3


--Use CTE

WITH PopVSVac(Continent, Location, Date, Population, New_vaccinations, CurrentVaccinated)
AS
(
SELECT Death.Continent , Death.Location , Death.Date , Death.Population , Vaccine.New_vaccinations,
SUM(CAST(Vaccine.New_vaccinations AS BIGINT)) OVER (PARTITION BY Death.Location  ORDER BY Death.Location , Death.Date) AS CurrentVaccinated
FROM [Covid-deaths] Death
JOIN [Covid-vaccination] Vaccine
	ON Death.Location = Vaccine.Location
	AND Death.Date = Vaccine.Date
WHERE Death.Continent IS NOT NULL
--ORDER BY 2,3
)
--Some people have done the second dose some haven't
SELECT *, (CurrentVaccinated/Population)*100 AS popvsvac
FROM PopVSVac



--TEMP TABLES
CREATE TABLE #PopPERVacc
(
Continent Nvarchar(255),
Lcation Nvarchar(255),
Date Datetime,
Population Numeric,
New_vaccinations Numeric,
CurrentVaccinated Numeric,
)
INSERT INTO #PopPERVacc
SELECT Death.Continent , Death.Location , Death.Date , Death.Population , Vaccine.New_vaccinations,
SUM(CAST(Vaccine.New_vaccinations AS BIGINT)) OVER (PARTITION BY Death.Location ORDER BY Death.Location , Death.Date) AS CurrentVaccinated
FROM [Covid-deaths] Death
JOIN [Covid-vaccination] Vaccine
	ON Death.Location = Vaccine.Location
	AND Death.Date = Vaccine.Date
WHERE Death.Continent IS NOT NULL

SELECT *, (CurrentVaccinated/Population)*100
FROM #PopPERVacc



--Create view to store data for later visuallization
CREATE VIEW PopPERVacc AS 
SELECT Death.Continent , Death.Location , Death.Date , Death.Population , Vaccine.New_vaccinations,
SUM(CAST(Vaccine.New_vaccinations AS BIGINT)) OVER (PARTITION BY Death.Location  ORDER BY Death.Location , Death.Date) AS CurrentVaccinated
FROM [Covid-deaths] Death
JOIN [Covid-vaccination] Vaccine
	ON Death.Location = Vaccine.Location
	AND Death.Date = Vaccine.Date
WHERE Death.Continent IS NOT NULL


SELECT *
FROM PopPERVacc