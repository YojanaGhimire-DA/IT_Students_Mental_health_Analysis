SELECT * FROM mentalhealthsurvey;

-- Feature engineering
ALTER TABLE mentalhealthsurvey
ADD COLUMN academic_pressure_score INT,
ADD COLUMN mental_health_score INT,
ADD COLUMN stress_relief_activity_count INT;

UPDATE mentalhealthsurvey
SET academic_pressure_score = (academic_workload + cgpa + academic_year);

UPDATE mentalhealthsurvey
SET mental_health_score = (depression + anxiety + isolation + future_insecurity);

UPDATE mentalhealthsurvey
SET stress_relief_activity_count = (
    SELECT COUNT(stress_relief_activities))
;
-- Exploratory Data analysis (EDA)

-- 1. What is the total number of students in the dataset?
SELECT COUNT(gender) FROM mentalhealthsurvey;

-- 2. How many students are in each academic year (e.g., freshman, sophomore)?
SELECT academic_year,COUNT(gender) AS total_students FROM mentalhealthsurvey
GROUP BY academic_year
ORDER BY 2 DESC; 

-- 3.Calculate the average CGPA of students in each degree level.
SELECT degree_level,AVG(cgpa) FROM mentalhealthsurvey
GROUP BY 1;

-- 4 Distribution of students by gender
SELECT gender, COUNT(*) FROM mentalhealthsurvey
GROUP BY gender;

-- 5 How many students live on-campus vs off-campus
SELECT residential_status, COUNT(*) FROM mentalhealthsurvey
GROUP BY residential_status;

-- 6 What percentage of students experience feelings of depression?
SELECT (COUNT(CASE WHEN depression >1 THEN 1 END)/COUNT(*))*100 AS depressed_percentage FROM mentalhealthsurvey;

-- 7 Calculate the average sleep hours for students who report frequent anxiety.
SELECT 
    anxiety,
    AVG(CASE 
            WHEN average_sleep = '2-4 hrs' THEN 3
            WHEN average_sleep = '4-6 hrs' THEN 5
            WHEN average_sleep = '7-8 hrs' THEN 7.5
            ELSE NULL
        END) AS avg_sleep
FROM 
    mentalhealthsurvey
GROUP BY 
    anxiety
HAVING 
    anxiety > 1
    ORDER BY 2 DESC;

-- 8 How many students participate in sports regularly?
SELECT sports_engagement, COUNT(gender) FROM mentalhealthsurvey
GROUP BY 1
ORDER BY 2 DESC;

-- 9 What is the average CGPA of students 
-- who report feeling high academic pressure compared to those who report lower levels?

SELECT AVG(cgpa) AS avg_cgpa, academic_pressure FROM mentalhealthsurvey
GROUP BY 2
ORDER BY 2 DESC;

-- 10 Analyze the relationship between sleep hours and academic performance (average CGPA).
SELECT average_sleep, AVG(cgpa) FROM mentalhealthsurvey
GROUP BY average_sleep
ORDER BY 2 DESC;

-- 11 What percentage of students 
-- who report frequent feelings of isolation also experience academic stress?
SELECT  academic_pressure,(COUNT(CASE WHEN isolation > 1 THEN 1 END)/ COUNT(*))* 100 AS isolation_percent 
FROM mentalhealthsurvey
GROUP BY 1
ORDER BY 2 DESC;

-- 12 Calculate the average frequency of
-- sports participation for students who report high levels of stress.
SELECT anxiety,(COUNT(CASE WHEN sports_engagement LIKE '%times' THEN 1 END)/COUNT(*))*100  AS avg_sports_participation 
FROM mentalhealthsurvey
GROUP BY anxiety
ORDER BY 1 DESC; 

-- 13 What is the average sleep duration among students 
-- who feel satisfied with their field of study versus those who do not? 
SELECT AVG(average_sleep) ,study_satisfaction FROM mentalhealthsurvey
GROUP BY 2
ORDER BY 1 DESC ;

-- 14 Find the top 3 stress-relief activities 
-- among students who experience frequent anxiety or depression.

SELECT stress_relief_activities, COUNT(*) AS activity_count FROM mentalhealthsurvey
WHERE anxiety > 2 OR depression > 2
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- 15 What is the percentage of students reporting discrimination or harassment on campus?

SELECT (COUNT(CASE WHEN campus_discrimination = 'Yes' THEN 1 END)/COUNT(*))*100 AS discrimination_percent FROM mentalhealthsurvey;

-- 16 Among students who report frequent feelings of isolation,
--  what percentage also report a poor quality of social relationships?

SELECT isolation, (COUNT(CASE WHEN social_relationships > 1 THEN 1 END)/ COUNT(*))*100 AS quality_of_social_relation_percent FROM mentalhealthsurvey
WHERE isolation > 1
GROUP BY 1
ORDER BY 2 DESC;

-- 17 How does social relationship quality correlate with 
-- students’ mental health (e.g., feelings of isolation, anxiety, depression
SELECT 
    social_relationships,
    AVG(isolation) AS avg_isolation,
    AVG(anxiety) AS avg_anxiety,
    AVG(depression) AS avg_depression
FROM 
    mentalhealthsurvey
GROUP BY 
    social_relationships
ORDER BY 
    social_relationships DESC;
    
-- 18 Compare the average CGPA and satisfaction level between different age groups and majors.

SELECT age, degree_major, MAX(cgpa), study_satisfaction FROM mentalhealthsurvey
GROUP BY degree_major,age,study_satisfaction
ORDER BY 3 DESC, 4 DESC
LIMIT 3; 

-- 19.What are the differences in mental health challenges (depression, anxiety, etc.) 
-- across different academic levels (e.g., undergraduates vs. postgraduates)?

SELECT 
    degree_level,
    COUNT(CASE WHEN depression >= 2 THEN 1 END) AS high_depression_count,
    COUNT(CASE WHEN anxiety >= 2 then 1 END) AS high_anxiety_count,
    COUNT(CASE WHEN isolation >= 2 THEN 1 END) AS high_isolation_count,
    COUNT(CASE WHEN future_insecurity >= 2 THEN 1 END) AS high_future_insecurity_count
FROM 
    mentalhealthsurvey
GROUP BY 
    degree_level
ORDER BY 
    degree_level;

-- 20 Among students experiencing high financial concerns, how does their mental health (anxiety, depression, etc.) compare across different degree levels?
SELECT degree_level, financial_concerns , 
COUNT(CASE WHEN anxiety > 1 THEN 1 END ) AS anxiety_count,
COUNT(CASE WHEN depression > 1 THEN 1 END) AS depression_count
FROM mentalhealthsurvey
GROUP BY degree_level, financial_concerns
ORDER BY degree_level, financial_concerns ;

-- 21. Which demographic factors (gender, age group, residential status) are most associated with students who feel insecure about the future?

SELECT gender, age, residential_status,COUNT(CASE WHEN future_insecurity > 1 THEN 1 END) AS future_insecurity_count FROM mentalhealthsurvey
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- 22. Determine which field of study has the highest and lowest average stress levels.
SELECT degree_major, 
AVG(depression) AS avg_depression,
AVG(anxiety) AS avg_anxiety 
FROM mentalhealthsurvey
GROUP BY degree_major
ORDER BY 2 DESC ,3 DESC;

-- 23. Among students reporting high academic pressure, what percentage also reports poor social relationships?
SELECT 
    (COUNT(CASE 
              WHEN academic_pressure > 3 AND social_relationships < 4
              THEN 1 
          END) * 100.0 / COUNT(*)) AS poor_relationship_percentage
FROM 
    mentalhealthsurvey;

-- 24. Calculate the average sleep hours and sports engagement frequency for students across different levels of reported depression or anxiety.

SELECT 
    depression,
    anxiety,
    AVG(average_sleep) AS avg_sleep_hours,
    AVG(sports_engagement) AS avg_sports_engagement
FROM 
    mentalhealthsurvey
GROUP BY 
    depression, anxiety
ORDER BY 
    depression, anxiety;
    
-- 25. Which students, based on their degree level and year, experience low field satisfaction, high academic pressure, and frequent depression?
WITH AtRiskStudents AS (
    SELECT 
        degree_level,
        academic_year,
        study_satisfaction,
        degree_major,
        academic_pressure,
        depression,
        COUNT(*) AS student_count
    FROM 
        mentalhealthsurvey
    WHERE 
        study_satisfaction <= 5
        AND academic_pressure >= 2 
        AND depression >= 2
    GROUP BY 
        degree_level, academic_year, study_satisfaction, academic_pressure,degree_major, depression
)
SELECT 
    degree_level,
    academic_year,
    degree_major,
    student_count
FROM 
    AtRiskStudents
ORDER BY 
    student_count DESC;
    
-- 26. For students who report both financial concerns and poor quality social relationships, what is the average frequency of experiencing mental health challenges?
  
WITH mentalhealthchallenges AS (
 SELECT financial_concerns,social_relationships,AVG(mental_health_score) AS avg_mental_health,
 COUNT(*) AS student_count
 FROM mentalhealthsurvey
 WHERE financial_concerns>1 AND social_relationships >=2
 GROUP BY financial_concerns, social_relationships
)
SELECT financial_concerns, social_relationships, avg_mental_health,student_count
FROM mentalhealthchallenges
ORDER BY avg_mental_health DESC;

