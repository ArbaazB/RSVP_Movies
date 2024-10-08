USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 
		table_name,
		table_rows
FROM 
	information_schema.tables		-- Infomation Schema is used to derive all the results from the table schema.
WHERE
	table_schema = 'imdb';

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT 
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_nulls,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls,
    SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS langues_nulls,
    SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls
FROM
	movie;

-- country, worlwide_gross_income, languages, production_company these columns have null values in movie table.

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- First Part
-- Movies released each year
SELECT 
		year,
        COUNT(id) AS number_of_movies
FROM 
	movie
GROUP BY
		year
ORDER BY 
		year;
	
-- Maximum number of movies were released in 2017 and after that the number reduced slowly.
        
-- Second Part
-- Month wise
SELECT 
		MONTH(date_published) AS month_num,
        COUNT(id) AS number_of_movies
FROM 
	movie
GROUP BY
		MONTH(date_published)
ORDER BY 
		MONTH(date_published);

-- Maximum number of movies were released in month of March.

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
		COUNT(DISTINCT(id)) AS number_of_movies
FROM
	imdb.movie
WHERE 
	year(date_published) = 2019 AND (country LIKE '%India%' OR country LIKE '%USA%'); -- movies produced in USA or India

-- In 2019, USA and India released 1059 movies.

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT 
		DISTINCT genre -- unique list of genres
FROM
	genre;    
    

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
		g.genre, 
        m.year, 
        COUNT(g.movie_id) AS movies_produced
FROM
	genre AS g -- using alises on genre
INNER JOIN 
			movie AS m -- using alises on movie
ON 
	m.id = g.movie_id  -- joining both the tables using JOIN operation
GROUP BY
		genre,
        year
ORDER BY 
		movies_produced DESC
LIMIT 1; 

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH total_genre AS -- using a WITH clause for a temporary result
(
SELECT 
		movie_id,
        COUNT(DISTINCT (genre)) AS genre_count
FROM
	genre
GROUP BY
		movie_id
HAVING 
	genre_count = 1
)
SELECT 
		COUNT(movie_id) AS number_of_movies
FROM 
	total_genre;
    
-- There are 3298 movies belongs to one genre.

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
		g.genre,
        ROUND(AVG(m.duration),2) AS avg_duration 
FROM 
	genre AS g 
INNER JOIN
		movie AS m 
ON 
	m.id = g.movie_id 
GROUP BY
		genre
ORDER BY 
		avg_duration DESC;

-- Action movie has the highest avg_duration of about 112.88 mins.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_rank AS
(
SELECT 
		genre,
        COUNT(movie_id) AS movie_count,
        -- Ranking
        RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM
	genre 
GROUP BY 
	genre
)
SELECT *
FROM 
	genre_rank
WHERE 
	genre = 'Thriller';
    
-- Thriller movies is in top 3 as per count of movies.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT 
		MIN(avg_rating) AS min_avg_rating,
        MAX(avg_rating) AS max_avg_rating,
        MIN(total_votes) AS min_total_votes,
        MAX(total_votes) AS max_total_votes,
        MIN(median_rating) AS min_median_rating,
        MAX(median_rating) AS min_median_rating
FROM
	ratings;
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH rank_rating AS
(
SELECT 
		m.title,
        r.avg_rating AS avg_rating,
        -- Ranking
        RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM 
	ratings AS r
INNER JOIN
	movie AS m
ON
	m.id = r.movie_id
)
SELECT *
FROM
	rank_rating
WHERE
	movie_rank <= 10;

-- The movie having highest avg_rating is Kirket of 10.0.
    

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
	median_rating,
    COUNT(movie_id) AS movie_count
FROM 
	ratings 
GROUP BY 
	median_rating
ORDER BY 
	median_rating;

-- The Maximum movies have median rating of 7, 6 and 8.
-- Median rating with 1,2,3,4,5,9 and 10 have low ratings.

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	production_company,
    COUNT(id) AS movie_count,
    -- Ranking
    RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM
	movie AS m
INNER JOIN 
	ratings AS r
ON 
	r.movie_id = m.id
WHERE 
	avg_rating > 8 AND production_company IS NOT NULL
GROUP BY
	production_company
ORDER BY
	movie_count DESC;

-- The popular movies was produced by the production house which has avg_rating > 8 are Dream Warrior Pictures and National Theatre Live.

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
	g.genre,
    COUNT(g.movie_id) AS movie_count
FROM
	genre AS g
INNER JOIN
	ratings AS r
USING (movie_id)
INNER JOIN
	movie as m
ON
	m.id = r.movie_id
WHERE
	m.country = 'USA' 
	AND r.total_votes > 1000 
	AND MONTH(date_published) = 3 
	AND year = 2017
GROUP BY 
	genre
ORDER BY 
	movie_count DESC;

-- The greatest number of drama-themed films with the year 2017; the month of March; the country of the USA; and more than a thousand votes.

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	title,
    avg_rating,
    genre
FROM
	genre AS g
INNER JOIN
	ratings AS r
ON 
	g.movie_id = r.movie_id
INNER JOIN
	movie AS m
ON
	g.movie_id = m.id
WHERE 
	title like 'The%' AND avg_rating > 8
ORDER BY 
	avg_rating DESC;
    
-- The movies starting with 'The' and also having avg_rating > 8 are more then 30.

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    COUNT(id) as movie_count,
    median_rating as median_rating
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON 
	r.movie_id = m.id
WHERE  date_published BETWEEN '2018-04-01' AND '2019-04-01' AND median_rating = 8
GROUP BY 
	median_rating;

-- There are 361 movies released with 8 median rating between 1 April 2018 and 1 April 2019.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT
	SUM(total_votes) AS total_votes,
	country	
FROM 
	movie AS m
INNER JOIN
	ratings AS r
ON 
	m.id = r.movie_id
WHERE
	country in ('Germany', 'Italy')
GROUP BY 
	country;

-- Germany has the highest votes.

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
	SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM
	names;
    
-- height, date_of_birth, known_for_movies these columns have null values.

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top_genres AS 		-- We will first find the top genres by count of movies with avg_rating > 8
(
SELECT 
	g.genre,
    COUNT(g.movie_id) AS movie_count
FROM 
	genre AS g
INNER JOIN 
	ratings AS r
ON
	g.movie_id = r.movie_id
WHERE 
	r.avg_rating > 8
GROUP BY
	genre
ORDER BY
	movie_count DESC
LIMIT 3
),
top_directors AS		-- we will find the top directors from top genre movies.
(
SELECT 
	n.name AS director_name,
    COUNT(dm.movie_id) AS movie_count,
    -- Using RANK 
    RANK() OVER(ORDER BY COUNT(dm.movie_id) DESC) AS director_rank
FROM 
	names AS n
INNER JOIN
	director_mapping AS dm
ON
	dm.name_id = n.id
INNER JOIN
	genre AS g
ON 
	g.movie_id = dm.movie_id
INNER JOIN
	ratings AS r
ON 
	r.movie_id = g.movie_id, top_genres
WHERE
	g.genre IN (top_genres.genre) AND r.avg_rating > 8
GROUP BY 
	director_name
ORDER BY 
	movie_count DESC
)
SELECT * 				-- then we will select top 3 directors.
FROM 
	top_directors
WHERE
	director_rank <= 3;
    
-- James Mangold has the highest count of ratings.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
DISTINCT
	name AS actor_name,
	COUNT(r.movie_id) AS movie_count
FROM 
	ratings AS r
INNER JOIN
	role_mapping AS rm
ON
	rm.movie_id = r.movie_id
INNER JOIN
	names AS n
ON
	n.id = rm.name_id
WHERE
	median_rating >= 8 AND category = 'actor'
GROUP BY
	name			-- To find number of movies with greater than 8 rating by actor.
ORDER BY 
	movie_count DESC
LIMIT 2;

-- We observe that Mammootty and Mohanlal has the highest number of movie count with 8 above rating.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	m.production_company,
	SUM(total_votes) AS vote_count,
    -- Using Ranking
    RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON 
	r.movie_id = m.id
GROUP BY 
	m.production_company
ORDER BY 
	vote_count DESC
LIMIT 3;

-- The highest production houses are Marvel Studious followed by Twentieth Century Fox and Warner Bros. by there number votes of the movies.

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 
	n.name AS actor_name,
	SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating,		-- To find the weigthed average
    -- Using Ranking
    RANK() OVER(ORDER BY ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actor_rank
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON 
	r.movie_id = m.id
INNER JOIN
	role_mapping AS rm
ON 
	rm.movie_id = m.id
INNER JOIN
	names AS n
ON
	n.id = rm.name_id
WHERE
	rm.category = 'actor' AND m.country = 'India'		-- To consider only Indian actors
GROUP BY 
	actor_name
HAVING
	COUNT(m.id)>=5;		-- To indentify actors who have done atleast 5 movies   
  
-- Vijay Sethupathi, Fahadh Faasil and Yogi Babu are top 3 actors with avg_rating highest than 7.8.
-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 
	n.name AS actress_name,
	SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actress_avg_rating,		-- To find the weigthed average
    -- Using Ranking
    RANK() OVER(ORDER BY ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actress_rank
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON 
	r.movie_id = m.id
INNER JOIN
	role_mapping AS rm
ON 
	rm.movie_id = m.id
INNER JOIN
	names AS n
ON
	n.id = rm.name_id
WHERE
	rm.category = 'actress' AND m.country = 'India' AND m.languages = 'Hindi'		-- To consider only Indian actors with Hindi languages 
GROUP BY 
	actress_name
HAVING
	COUNT(m.id)>=3		-- To indentify actress who have done atleast 3 Indian movies
LIMIT 5; 

-- Taapsee Pannu is the top actress with average rating 7.74.

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
	m.title,
    r.avg_rating,
		CASE
			WHEN avg_rating > 8 THEN 'Superhit Movies'
            WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit Movies'
            WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-Time-Watch Movies'
		ELSE
			'Flop Movies'
		END AS avg_rating_category
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON
	r.movie_id = m.id
INNER JOIN 
	genre AS g
ON
	m.id = g.movie_id
WHERE 
	g.genre = 'Thriller';

-- The top movie in hit movie is  Der müde Tod with average rating 7.7.

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
	g.genre,
    ROUND(AVG(m.duration),2) AS avg_duration,
    ROUND(SUM(AVG(m.duration)) OVER(ORDER BY genre),2) AS running_total_duration,		-- To find total running duration
    ROUND(AVG(AVG(m.duration)) OVER(ORDER BY genre),2) AS moving_avg_duration		-- To find avg moving duration
FROM 
	movie AS m
INNER JOIN
	genre AS g
ON
	g.movie_id = m.id
GROUP BY 
	genre;
    
-- Genre-wise Action genre has the highest avg_duration followed by running_total_duration and moving_avg_duration.

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
-- Top 3 Genres based on most number of movies

WITH top_3_genre AS		-- First find Top 3 genres
(
SELECT 
	genre,
    COUNT(movie_id) AS movie_count
FROM
	genre
GROUP BY 
	genre
ORDER BY 
	movie_count DESC
LIMIT 3
),
-- Now we will write a queary for Top 5 movies
top_5_movies AS
(
SELECT 
	genre,
    year,
    title AS movie_name,
    worlwide_gross_income,
    RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
FROM 
	movie AS m
INNER JOIN
	genre AS g
ON 
	g.movie_id = m.id
WHERE
	genre IN (SELECT genre FROM top_3_genre)		-- Select top 3 genres
)
SELECT * 
FROM
	top_5_movies
WHERE
	movie_rank <= 5		-- Top 5 movies from the list
ORDER BY 
	movie_rank;
    
-- Drama and Thriller belongs to the top 5 highest-grossing movies from each year.

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT
	production_company,
    COUNT(id) AS movie_count,
    ROW_NUMBER() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank		-- Find rank by number of movies
FROM
	movie AS m
INNER JOIN
	ratings AS r
ON
	r.movie_id = m.id
WHERE
	median_rating >= 8 AND production_company IS NOT NULL AND POSITION(',' IN languages) > 0 -- It is to indentify if there is any comma then there are more 1 languages 
GROUP BY
	production_company
LIMIT 2;

-- Top 2 production company is Star Cinema and Twentieth Century Fox have produced highest number of rating among multilingual movies.

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 
	n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(r.movie_id) AS movie_count,
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actress_avg_rating,
    RANK() OVER(ORDER BY ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actress_rank
FROM 
	names AS n
INNER JOIN
	role_mapping AS rm		-- to find the category
ON
	rm.name_id = n.id
INNER JOIN
	ratings AS r
ON
	r.movie_id = rm.movie_id		-- to find avg rating
INNER JOIN
	genre AS g
ON
	g.movie_id = r.movie_id
WHERE	
	g.genre = 'Drama' AND rm.category = 'actress' AND r.avg_rating > 8
GROUP BY
	actress_name
ORDER BY
	movie_count DESC
LIMIT 3;

-- Susan Brown, Amanda Lawrence and Denise Gough are top 3 actresses which have rating above 8 in drama genre.

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH num_movies AS
(
SELECT 
	dm.name_id,
    name,
    dm.movie_id,
    m.duration,
    r.avg_rating,
    r.total_votes,
    m.date_published,
    -- To find next date of publish for the movies by directors
    LEAD(date_published,1) OVER(PARTITION BY dm.name_id ORDER BY date_published, movie_id) AS next_date_published
FROM
	director_mapping AS dm
INNER JOIN
	names AS n
ON
	n.id = dm.name_id
INNER JOIN
	movie AS m
ON
	m.id = dm.movie_id
INNER JOIN
	ratings AS r
ON
	r.movie_id = m.id
),
top_directors AS
(
SELECT * ,
	Datediff(next_date_published, date_published) AS date_diff		-- to find the difference between the current and next dates
FROM 
	num_movies
)
SELECT
	name_id AS director_id,
    name AS director_name,
    COUNT(movie_id) AS number_of_movies,
    ROUND(AVG(date_diff)) AS avg_inter_movie_days,
    ROUND(SUM(avg_rating),2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM
	top_directors
GROUP BY 
	director_id
ORDER BY 
	COUNT(movie_id) DESC
LIMIT 9;

-- From the top 9 directors we see Andrew Jones is the highest in the list.