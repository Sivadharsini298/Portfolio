--Exploration Queries
--1. Gender distribution
SELECT gender, COUNT(*) AS count
FROM career_aspirations
GROUP BY gender;

--2. Preferred company type by gender
SELECT gender, preferred_company_type, COUNT(*) AS count
FROM career_aspirations
GROUP BY gender, preferred_company_type
ORDER BY gender, count DESC;

--3. Expected starting salary distribution
SELECT min_starting_salary, COUNT(*) AS count
FROM career_aspirations
GROUP BY min_starting_salary
ORDER BY count DESC;

--4. Willingness to work for a company with no clear mission
SELECT likelihood_no_clear_mission, COUNT(*) AS count
FROM career_aspirations
GROUP BY likelihood_no_clear_mission;

--Career Preference & Work Culture Insights
--5. Remote work policy vs preferred company type
SELECT working_no_remote_policy, preferred_company_type, COUNT(*) AS count
FROM career_aspirations
GROUP BY working_no_remote_policy, preferred_company_type
ORDER BY count DESC;

--6. Break frequency by gender
SELECT gender, work_life_break_frequency, COUNT(*) AS count
FROM career_aspirations
GROUP BY gender, work_life_break_frequency
ORDER BY gender,count DESC;

--Salary Trends Over Career Span
--7. Compare expected salaries over time
SELECT min_salary_first_3_years, min_salary_after_5_years, COUNT(*) AS count
FROM career_aspirations
GROUP BY min_salary_first_3_years, min_salary_after_5_years
ORDER BY count DESC;

--8. Users open to working under abusive managers
SELECT abusive_manager_acceptance, COUNT(*) AS count
FROM career_aspirations
GROUP BY abusive_manager_acceptance;

--9. Correlation between misaligned mission and expected salary
SELECT likelihood_misaligned_mission, min_salary_first_3_years, COUNT(*) AS count
FROM career_aspirations
GROUP BY likelihood_misaligned_mission, min_salary_first_3_years
ORDER BY count DESC;




