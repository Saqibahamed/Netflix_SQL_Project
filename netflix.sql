-- CREATING A NEW DATABASE:

CREATE DATABASE netflix_db

-- USING/SELECTING THE DATABASE:

USE netflix_db 


SELECT *
FROM netflix

-- cleaning the data:

-- checking each coulmn for any discrepancy

SELECT *
FROM netflix

SELECT director,count(*)
FROM netflix
GROUP BY director

sp_help netflix

-- 1.moving the dusration from rating cloumn to duration coulmn
SELECT *
FROM netflix
where rating like '%min%'

UPDATE netflix
set rating = duration
where rating like '%min%'





-- solving  business problems

--1. count number of movies VS TV shows:

SELECT type,count(type)
FROM netflix
group by type

SELECT count(type) as moice_count,(
									SELECT count(type) as TV_show_count
									FROM netflix
									WHERE type = 'TV show' )
FROM netflix
WHERE type = 'Movie'


-- 2. Find the most common rating for movies and TV shows:

SELECT type,rating
FROM (

		SELECT type,rating, count(*) AS total,
		DENSE_RANK() OVER (PARTITION BY type ORDER BY count(*) DESC ) as ranks
		FROM netflix
		GROUP BY type,rating
		) AS grp
WHERE ranks = 1


-- 3. list all movies released in a specific year (2020):


SELECT type,release_year
FROM netflix
WHERE type = 'Movie' AND release_year = '2020'

-- 4.Find top 5 countries with the most content on netflix:

SELECT TOP 5 RTRIM(LTRIM(value)) AS country, count(value) as total_content
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY count(value) DESC


-- 5. Identify the longest movie?:

SELECT title,type, CAST(value AS INT) AS duration
FROM netflix
CROSS APPLY STRING_SPLIT(duration,' ')
WHERE type = 'Movie' AND value NOT LIKE '%min%'
ORDER BY duration DESC


-- 6. Find the content added in the last 10 years:

SELECT type,title,YEAR(date_added) as years
FROM netflix
WHERE YEAR(date_added) BETWEEN  (YEAR(GETDATE()) - 10) AND 2021
ORDER BY years

-- 7. Find all te movies/TV shows by director 'Rajiv Chilaka':

SELECT type,title,director
FROM netflix
WHERE director like '%Rajiv chilaka%'

-- 8. List all TV shows with more than 5 seasons:

SELECT type, title,CONCAT_WS(' ',CAST(value AS INT), 'Seasons') AS duration
FROM netflix
CROSS APPLY STRING_SPLIT(duration,' ')
WHERE type = 'TV Show' AND value NOT LIKE '%Season%' AND value > 5
ORDER BY CAST(value AS INT) DESC


-- 9. Count the number of content items in each genre:

SELECT RTRIM(LTRIM(value)) AS genre, count(*) as total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY total_content DESC


-- 10. Find the average release year for content produced in a specific country:

SELECT RTRIM(LTRIM(value)) as country, release_year,
AVG(release_year) OVER (PARTITION BY RTRIM(LTRIM(value))) as avg_year
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
ORDER BY avg_year;

-- OR

SELECT RTRIM(LTRIM(value)) as country, AVG(release_year) as avg_release_year
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY avg_release_year ASC;

-- 11. List all movies that are documentaries:

SELECT type,title,LTRIM(RTRIM(value)) as genre
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in,',')
WHERE type = 'Movie' AND LTRIM(RTRIM(value))  like 'Documentaries'

-- OR

SELECT count(listed_in) as genre
FROM netflix
WHERE type = 'Movie' AND listed_in like '%Documentaries%'

-- 12. Find all content without a director:

SELECT type,title,director
FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 15 years:

SELECT title, cast, release_year
FROM netflix
WHERE cast like '%salman khan%' AND  release_year BETWEEN (YEAR(GETDATE()) - 15) AND 2021
ORDER BY release_year

-- OR

SELECT title,LTRIM(RTRIM(value)) as cast,release_year
FROM netflix
CROSS APPLY STRING_SPLIT(cast,',')
WHERE LTRIM(RTRIM(value)) LIKE '%salman khan%' AND release_year BETWEEN (YEAR(GETDATE()) - 15) AND 2021
ORDER BY release_year


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India:

SELECT TOP 10 RTRIM(LTRIM(v2.value)) as cast, count(show_id) total_movies
FROM netflix
CROSS APPLY STRING_SPLIT(country,',') as v1
CROSS APPLY STRING_SPLIT(cast,',') as v2
WHERE type = 'Movie' AND RTRIM(LTRIM(v1.value)) like '%india%'
GROUP BY RTRIM(LTRIM(v2.value))
ORDER BY total_movies DESC

-- OR

SELECT RTRIM(LTRIM(v1.value)) as cast, count(*) as total_count
FROM netflix
CROSS APPLY STRING_SPLIT(cast,',') as v1
WHERE country like '%india%'
GROUP BY RTRIM(LTRIM(v1.value))
ORDER BY total_count DESC




-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field
-- label contect containing these keywords as 'Bad' and all other content as 'Good', count how many items fall into each category


SELECT *, CASE
			WHEN description LIKE '%kill%'  OR description like '%violence%' THEN 'Bad'
			ELSE 'Good'
			END AS content_type
FROM netflix

-- 16. Find each year and the average numbers of content release in India on netflix and return top 5 year with highest avg content releases:

SELECT TOP 5 release_year,count(*) as total_release, ROUND(CAST((count(*) / 365.0) * 100 AS float),2) as avg_releases
FROM netflix
WHERE country like '%india%' AND release_year is NOT NULL
GROUP BY release_year
ORDER BY avg_releases DESC
