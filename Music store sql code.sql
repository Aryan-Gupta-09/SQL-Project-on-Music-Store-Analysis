-- Title:- Music Store Analysis
-- Ceated By:- Aryan Gupta
-- Date:- 05/06/2023
-- Tool used:- MySQL

/*
DESCRIPTION:-
> This is a Music Store Analysis SQL Project
> The database has been downloaded from Kaggle and contains 11 tables in total.

DATA:-
> album2:- this table contains album details
> artist:- this table contains artist details
> customer:- this table contains customer details
> employee:- this table contains employee details
> genre:- this table contains the genre name of the music and genre id
> invoice:- this table contains the invoices of the sales made
> invoice_line:- this table contains unit price & quantity details
> media_type:- this table contains type of media details
> playlist:- this table contains playlist details
> playlist_track:- this table contains playlist details in relation with track
> track:- this table contains track details

APPROACH:-
> Understanding the dataset
> Creating business questions
> Analyzing with SQL Queries
*/


-- Q1: WHO IS THE SENIOR MOST EMPLOYEE BASED ON JOB TITLE?

SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

-- Q2: WHICH COUNTRIES HAVE THE MOST INVOICES?

SELECT COUNT(*) AS TOTAL_INVOICES ,BILLING_COUNTRY 
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY TOTAL_INVOICES DESC;

-- Q3: WHAT ARE TOP 3 VALUES OF TOTAL INVOICES?

SELECT 
    TOTAL
FROM
    INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice*/

SELECT 
    SUM(TOTAL) AS INVOICE_TOTAL, BILLING_CITY
FROM
    INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC;

/* Q5: Who is the best customer? (The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money) */

SELECT 
    C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(I.TOTAL) AS T
FROM
    CUSTOMER C
        JOIN
    INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY T DESC
LIMIT 1;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/

SELECT DISTINCT
    EMAIL, FIRST_NAME, LAST_NAME
FROM
    CUSTOMER C
        JOIN
    INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
        JOIN
    INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE
    track_id IN (SELECT 
            TRACK_ID
        FROM
            TRACK
                JOIN
            GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
        WHERE
            GENRE.NAME LIKE 'ROCK')
ORDER BY EMAIL;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands*/

SELECT A.ARTIST_ID,A.NAME,COUNT(A.ARTIST_ID) AS NUMBER_OF_SONGS
FROM TRACK T
JOIN ALBUM2 AB ON AB.ALBUM_ID= T.ALBUM_ID
JOIN ARTIST A ON A.ARTIST_ID=AB.ARTIST_ID
JOIN GENRE G ON G.GENRE_ID=T.GENRE_ID
WHERE G.NAME LIKE 'ROCK'
GROUP BY A.ARTIST_ID
ORDER BY NUMBER_OF_SONGS DESC
LIMIT 10;

/* Q8:  Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/

SELECT NAME,MILLISECONDS 
FROM TRACK 
WHERE MILLISECONDS > (SELECT AVG(MILLISECONDS) AS AVERAGE_TRACK_LENGTH FROM TRACK)
ORDER BY MILLISECONDS DESC;

/* Q9:  Find how much amount was spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

WITH BEST_SELLING_ARTIST AS 
( SELECT A.ARTIST_ID AS ARTIST_ID,A.NAME AS ARTIST_NAME,SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_SALES FROM INVOICE_LINE IL
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN ALBUM2 AL ON AL.ALBUM_ID=T.ALBUM_ID
JOIN ARTIST A ON A.ARTIST_ID=AL.ARTIST_ID
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1)

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,BSA.ARTIST_NAME,SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_AMOUNT_SPENT
FROM INVOICE I 
JOIN CUSTOMER C ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID=I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN ALBUM2 AL ON AL.ALBUM_ID=T.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID=AL.ARTIST_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;
use digital_music_store;




/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;








