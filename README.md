# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/Saqibahamed/Netflix_SQL_Project/blob/main/Netflix%20logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using Microsoft SQL Server. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

This is done directly by importing the data from the .CSV file using import data wizard

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      NVARCHAR(MAX),
    type         NVARCHAR(MAX),
    title        NVARCHAR(MAX),
    director     NVARCHAR(MAX),
    casts        NVARCHAR(MAX),
    country      NVARCHAR(MAX),
    date_added   date,
    release_year smallint,
    rating       NVARCHAR(MAX),
    duration     NVARCHAR(MAX),
    listed_in    NVARCHAR(MAX),
    description  NVARCHAR(MAX)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type,count(type)
FROM netflix
group by type

SELECT count(type) as moice_count,(
                                   SELECT count(type) as TV_show_count
                                   FROM netflix
                                   WHERE type = 'TV show'
			           )
FROM netflix
WHERE type = 'Movie';
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT type,rating
FROM (

		SELECT type,rating, count(*) AS total,
		DENSE_RANK() OVER (PARTITION BY type ORDER BY count(*) DESC ) as ranks
		FROM netflix
		GROUP BY type,rating
		) AS grp
WHERE ranks = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT type,release_year
FROM netflix
WHERE type = 'Movie' AND release_year = '2020';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 RTRIM(LTRIM(value)) AS country, count(value) as total_content
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY count(value) DESC;

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT title,type, CAST(value AS INT) AS duration
FROM netflix
CROSS APPLY STRING_SPLIT(duration,' ')
WHERE type = 'Movie' AND value NOT LIKE '%min%'
ORDER BY duration DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT type,title,YEAR(date_added) as years
FROM netflix
WHERE YEAR(date_added) BETWEEN  (YEAR(GETDATE()) - 10) AND 2021
ORDER BY years;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT type,title,director
FROM netflix
WHERE director like '%Rajiv chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT type, title,CONCAT_WS(' ',CAST(value AS INT), 'Seasons') AS duration
FROM netflix
CROSS APPLY STRING_SPLIT(duration,' ')
WHERE type = 'TV Show' AND value NOT LIKE '%Season%' AND value > 5
ORDER BY CAST(value AS INT) DESC;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT RTRIM(LTRIM(value)) AS genre, count(*) as total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY total_content DESC
```

**Objective:** Count the number of content items in each genre.

### 10.Find the average release year for content produced in a specific country:

```sql
SELECT RTRIM(LTRIM(value)) as country, release_year,
AVG(release_year) OVER (PARTITION BY RTRIM(LTRIM(value))) as avg_year
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
ORDER BY avg_year;
LIMIT 5;

-- OR

SELECT RTRIM(LTRIM(value)) as country, AVG(release_year) as avg_release_year
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
GROUP BY RTRIM(LTRIM(value))
ORDER BY avg_release_year ASC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT type,title,LTRIM(RTRIM(value)) as genre
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in,',')
WHERE type = 'Movie' AND LTRIM(RTRIM(value))  like 'Documentaries';

-- OR

SELECT count(listed_in) as genre
FROM netflix
WHERE type = 'Movie' AND listed_in like '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT type,title,director
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 15 Years

```sql
SELECT title, cast, release_year
FROM netflix
WHERE cast like '%salman khan%' AND  release_year BETWEEN (YEAR(GETDATE()) - 15) AND 2021
ORDER BY release_year;

-- OR

SELECT title,LTRIM(RTRIM(value)) as cast,release_year
FROM netflix
CROSS APPLY STRING_SPLIT(cast,',')
WHERE LTRIM(RTRIM(value)) LIKE '%salman khan%' AND release_year BETWEEN (YEAR(GETDATE()) - 15) AND 2021
ORDER BY release_year;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
CROSS APPLY STRING_SPLIT(country,',') as v1
CROSS APPLY STRING_SPLIT(cast,',') as v2
WHERE type = 'Movie' AND RTRIM(LTRIM(v1.value)) like '%india%'
GROUP BY RTRIM(LTRIM(v2.value))
ORDER BY total_movies DESC;

-- OR

SELECT RTRIM(LTRIM(v1.value)) as cast, count(*) as total_count
FROM netflix
CROSS APPLY STRING_SPLIT(cast,',') as v1
WHERE country like '%india%'
GROUP BY RTRIM(LTRIM(v1.value))
ORDER BY total_count DESC;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sqlSELECT *, CASE
			WHEN description LIKE '%kill%'  OR description like '%violence%' THEN 'Bad'
			ELSE 'Good'
			END AS content_type
FROM netflix;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Find each year and the average numbers of content release in India on netflix and return top 5 year with highest avg content releases:


```sql
SELECT TOP 5 release_year,count(*) as total_release, ROUND(CAST((count(*) / 365.0) * 100 AS float),2) as avg_releases
FROM netflix
WHERE country like '%india%' AND release_year is NOT NULL
GROUP BY release_year
ORDER BY avg_releases DESC;
```
