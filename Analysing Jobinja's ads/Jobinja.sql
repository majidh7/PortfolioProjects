-- Use database 
USE jobinja

-- Adding an ID column to our table

CREATE TABLE Jobinja (
JobID int identity(1,1),
JobCategory Nvarchar(255),
JobPosition Nvarchar(255),
JobLocation Nvarchar(255),
EmploymentType Nvarchar(255),
Experience Nvarchar(255),
Salary Nvarchar(255),
CompanyName Nvarchar(255),
CompanyCategory Nvarchar(255),
CompanySize Nvarchar(255),
CompanyWebsite Nvarchar(255),
Skills Nvarchar(255),
Gender Nvarchar(255),
MilitaryService Nvarchar(255),
Education Nvarchar(255),
JobDescription Nvarchar(MAX),
JobURL Nvarchar(MAX)
);
GO

INSERT INTO dbo.Jobinja (
	JobCategory,
	JobPosition,
	JobLocation,
	EmploymentType,
	Experience,
	Salary,
	CompanyName,
	CompanyCategory,
	CompanySize,
	CompanyWebsite,
	Skills,
	Gender,
	MilitaryService,
	Education,
	JobDescription,
	JobURL)
SELECT 
	[Job Category],
	[Job Position],
	[Job Location],
	[Employment Type],
	[Experience],
	[Salary],
	[Company Name],
	[Company Category],
	[Company Size],
	[Company Website],
	[Skills],
	[Gender],
	[Military Service],
	[Education],
	[Job Description],
	[Job URL]
FROM dbo.Jobinja1;
GO


/* Delete columns we won't need */ 
ALTER TABLE dbo.jobinja DROP COLUMN [CompanySize];
GO
ALTER TABLE dbo.jobinja DROP COLUMN [CompanyWebsite];
GO
ALTER TABLE dbo.jobinja DROP COLUMN [JobDescription];
GO
ALTER TABLE dbo.jobinja DROP COLUMN [JobUrl];
GO


-- How many of ads need millitary services
SELECT COUNT(JobID) AS JobCount,JobCategory
FROM dbo.jobinja
WHERE MilitaryService IN (N'معافیت دائم', N'معافیت تحصیلی', N'پایان خدمت')
GROUP BY JobCategory;
GO


-- Distribution of part time ads per location

SELECT Joblocation, Count(JobID) AS JobCount
FROM Jobinja
WHERE EmploymentType = N'پاره وقت'
GROUP BY joblocation;
GO


-- Distribution of ads per location and Gender

SELECT Joblocation, Gender, Count(JobID) AS JobCount
FROM Jobinja
GROUP BY Joblocation, Gender;
GO


-- Distribution of ads per Category of Job
SELECT JobCategory, COUNT(JobID) AS JobCount
FROM Jobinja
GROUP BY JobCategory;
GO


-- Distribution of ads per Salary
SELECT Distinct Jobcategory, Salary, COUNT(JobID) AS JobCount
FROM Jobinja
GROUP BY Salary, Jobcategory;
GO


-- How many of companies wants academic degrees
SELECT COUNT(JobID) AS JobCount, Education
FROM Jobinja
WHERE Education IN (N'کاردانی', N'کارشناسی', N'دکترا', N'کارشناسی ارشد')
GROUP BY Education;
GO

