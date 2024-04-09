---------------------------------------------------------------------------
-- Checked for duplicates on excel before importing the data to mysql

select *
from indiasuicide;

select state, count(state) as StatesCount
from indiasuicide
group by state
order by state ASC;

-- Cleaning 
-- Cleaning typographical errors and combining two similar state into one (error in typing) 

Update indiasuicide
SET state =
CASE 
	WHEN state = 'A & N Islands' THEN 'Andaman and Nicobar Islands'
    WHEN state = 'D & N Haveli' THEN 'Dadra & Nagar Haveli and Daman & Diu'
    WHEN state = 'Delhi (Ut)' THEN 'Delhi'
    WHEN state = 'Chandigarh' THEN 'Chhattisgarh'
    WHEN state = 'Daman & Diu' THEN 'Dadra & Nagar Haveli and Daman & Diu'
    else state
    END;
    
-- Adding Union Territory column to the Table

ALTER TABLE indiasuicide
ADD UnionTerritory VARCHAR(255);

SELECT state, UnionTerritory, Count(UnionTerritory)
FROM indiasuicide
GROUP BY state, UnionTerritory;

SELECT
CASE
	WHEN state IN ('Delhi', 'Puducherry','Chandigarph','Dadra & Nagar Haveli and Daman & Diu','Lakshadweep',
    'Andaman and Nicobar Islands','Ladakh','Lakshadweep', 'Jammu & Kashmir')
    THEN 'Union Territory'
    ELSE 'State'
    END as region_type,
    state
    FROM indiasuicide;
    
UPDATE indiasuicide
SET UnionTerritory =
					CASE 
						WHEN state IN ('Delhi', 'Puducherry','Chandigarph','Dadra & Nagar Haveli and Daman & Diu',
                        'Lakshadweep','Andaman and Nicobar Islands','Ladakh','Lakshadweep','Jammu & Kashmir')
					THEN 'Yes'
					ELSE 'No'
                    END;
                    
-- Getting all the data for the Union Territory only         
SELECT *
FROM indiasuicide
WHERE UnionTerritory = 'Yes';

-- Getting all the data for the states only      
SELECT *
FROM indiasuicide
WHERE UnionTerritory = 'NO';

-- Age group contains 0-100+ which seems like an error //  

SELECT Age_group, count(Age_group) as AgeGroupCount
FROM indiasuicide
WHERE age_group <> '0-100+'
GROUP BY Age_group;

-- WORKING ON SPECIFIC DATA

-- Total Number of Suicides committed each year from 2001 - 2012

select year, sum(total) as TotalSuicide
from indiasuicide
group by year;

-- What Gender committed the most suicide?

select gender, sum(total) as TotalSuicide
from indiasuicide
group by gender
order by TotalSuicide DESC;

-- What age group committed the most sucide?

select age_group, sum(total) as TotalSuicide
from indiasuicide
where age_group <> '0-100+'
group by age_group;

-- Causes of Suicide in India

select type, sum(total) as TotalSuicide
from indiasuicide
where type_code = 'causes'
group by type
order by TotalSuicide DESC;

-- with the Age_group by the side
select type, sum(total) as TotalSuicide, Age_group
from indiasuicide
where type_code = 'causes'
group by type, age_group
order by TotalSuicide DESC;

-- Means of Suicide

select type, sum(total) as TotalSuicide
from indiasuicide
where type_code = 'Means_adopted'
group by type
order by TotalSuicide DESC;

-- Educational Status of the Suicide Victims

select type, sum(total) as TotalSuicide
from indiasuicide
where type_code = 'Education_Status'
group by type
order by TotalSuicide DESC;

-- Social Status of the suicide victims

select type, sum(total) as TotalSuicide
from indiasuicide
where type_code = 'Social_Status'
group by type
order by TotalSuicide DESC;

-- Occupation of Suicide victims

select type, sum(total) as TotalSuicide
from indiasuicide
where type_code = 'Professional_Profile'
group by type
order by TotalSuicide DESC;

-- States Vs Suicide

select state, sum(total) as TotalSuicide
from indiasuicide
Where state NOT IN ('Total (Uts)', 'Total (States)', 'Total (All India)') AND UnionTerritory = 'No'
group by state, UnionTerritory
order by TotalSuicide DESC;

-- Union Territory Vs Suicide

select state, sum(total) as TotalSuicide
from indiasuicide
Where state NOT IN ('Total (Uts)', 'Total (States)', 'Total (All India)') AND UnionTerritory = 'Yes'
group by state, UnionTerritory
order by TotalSuicide DESC;