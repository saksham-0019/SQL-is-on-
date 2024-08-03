--- MUSIC STORE DATA ANYALISIS 
---12 TABLES 


-- who is the senior most employe based on job title ?

SELECT * 
FROM employee
ORDER BY levels DESC 
LIMIT 1;

-- which countries have the most invoices ?

SELECT COUNT(*) AS c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

--- what are the top 3value from invoice ?

SELECT *
FROM invoice
ORDER BY total DESC
LIMIT 3;

---which city has the best coustomer ?
'we would like to throw a prometional music festival in city we made the most
	money write a query that returen one city that hase the highest sum of invoice
	total returen both the city name & sum of all invoices  '

SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

---whois the best coustmer ?
'that coustomer who has spent most money will be declaird the best coustomer 
	write a query that returen the person who has spent the most money '
	
SELECT customer.customer_id, customer.first_name, customer.last_name, 
	SUM(invoice.total) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total DESC
LIMIT 1;

--- write a query to returen the email , first name , last name ,
---& gern of all rock music listners . returen ypur list order alphabeticaly 
--by email starting with A

SELECT DISTINCT customer.email, customer.first_name, customer.last_name, genre.name AS genre
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'rock'
ORDER BY customer.email;

'returen all track names that have a song length loger than everage song length .
	returen the name and millseconds for each treack .order by the song length the
	longest song listed first ?'
	
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;

--- lets invite the artist who have returen the most rock music in over dataset 
---write a query that returen artist name and total track count of the top 10 rock bands 

SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

---returen all the track name that have song length longer than average song length 
--returen the name and milliseconds for each track orderd by the song length 
--with the logest song listed first


	

WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id,
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_series
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON track.album_id = album.album_id
    JOIN 
        artist ON album.artist_id = artist.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_series DESC
    LIMIT 1
)

SELECT
    customer.first_name || ' ' || customer.last_name AS customer_name,
    best_selling_artist.artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM
    invoice_line
JOIN
    track ON track.track_id = invoice_line.track_id
JOIN
    album ON track.album_id = album.album_id
JOIN
    artist ON album.artist_id = artist.artist_id
JOIN
    invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN
    customer ON customer.customer_id = invoice.customer_id
JOIN
    best_selling_artist ON artist.artist_id = best_selling_artist.artist_id
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
ORDER BY
    total_spent DESC;


---we want to find out the most populer music genre for each countrey 
--we determine the most popular genre as the genre with the highest amount of purchase 

WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchase,
        customer.country,
        genre.name AS genre_name,
        genre.genre_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer.country 
            ORDER BY COUNT(invoice_line.quantity) DESC
        ) AS row_num
    FROM 
        invoice_line
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
    ORDER BY 
        customer.country ASC, purchase DESC
)
SELECT * 
FROM popular_genre 
WHERE row_num <= 1;
