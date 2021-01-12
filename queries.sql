-- 1. Calculating amount and total value of all sold artworks for each artist. 

SELECT artists.name, artists.surname, COUNT(artworks.artwork_id) AS number_of_sold_artworks, SUM(artworks.price) AS value_of_sold_artworks
FROM artists
INNER JOIN artworks ON artists.artist_id=artworks.artist_id
INNER JOIN ordered_artworks ON artworks.artwork_id=ordered_artworks.artwork_id
WHERE ordered_artworks.artwork_id IS NOT NULL
GROUP BY artists.name, artists.surname;


-- 2. Listing all people who visited the exhibition 1 and whose surnames start from S 

SELECT surname, name, tickets.ticket_id, time_of_entrance
FROM visitors 
INNER JOIN tickets ON visitors.ticket_id=tickets.ticket_id
INNER JOIN range_of_accesses ON tickets.ticket_id=range_of_accesses.ticket_id
INNER JOIN exhibitions ON range_of_accesses.exhibition_id=exhibitions.exhibition_id
WHERE exhibitions.exhibition_id = 1 AND surname LIKE 'S%';


-- 3. Calculating monthly average of time spent in the gallery in 2020 by visitors

SELECT CONCAT( ROUND(AVG(( CAST( time_of_leaving AS DATE ) - CAST( time_of_entrance AS DATE ) ) * 1440),2), ' minutes') AS timeAtTheGallery,  EXTRACT(MONTH FROM time_of_entrance) AS monthOf2020
FROM visitors
WHERE (EXTRACT(YEAR FROM time_of_entrance)) = 2020
GROUP BY EXTRACT(MONTH FROM time_of_entrance)
ORDER BY monthOf2020;

-- 4. Displaying the number of artworks representing each artstyle in descending order

SELECT name, COUNT(artworks.artwork_id) AS number_of_artworks
FROM art_styles
INNER JOIN artworks ON art_styles.art_style_id=artworks.art_style_id
GROUP BY art_styles.name
ORDER BY COUNT(artworks.artwork_id) DESC;


-- 5. Listing all of the artworks in alphabetical order and the information about title of an exhibition that they're displayed at

SELECT artworks.title, artworks.year_of_creation, exhibitions.title AS exhibition_title
FROM artworks
LEFT JOIN exhibition_contents ON artworks.artwork_id = exhibition_contents.artwork_id
LEFT JOIN exhibitions ON exhibition_contents.exhibition_id = exhibitions.exhibition_id
ORDER BY artworks.title ASC;


-- 6. Displaying information about the artworks which were created after a year 2000 or which cost more than 100000

SELECT artworks.artwork_id, artworks.title, artists.name, artists.surname, EXTRACT (YEAR FROM artworks.year_of_creation) AS year, artworks.price FROM artworks
LEFT JOIN artists ON artworks.artist_id = artists.artist_id
WHERE (EXTRACT (YEAR FROM artworks.year_of_creation)>2000 OR artworks.price>100000);


-- 7. Calculating the number of artworks for each of the artists and listing those who created more or equal 2 artworks

SELECT artist_id, surname, number_of_artworks
FROM (
    SELECT W.artist_id, A.surname, COUNT(W.artwork_id) AS number_of_artworks
    FROM artworks W
    JOIN artists A ON W.artist_id = A.artist_id
    GROUP BY W.artist_id, A.surname
    HAVING COUNT(*) > = 2
);


-- 8. Calculating the age at which the artist died if his dates of birth and death are known

SELECT artist_id, name, surname, ROUND((( CAST( date_of_death AS DATE ) - CAST( dat_of_birth AS DATE )) /365),0) AS years_old 
FROM artists
WHERE date_of_death IS NOT NULL; 


-- 9. Listing how many children visited gallery in each month

SELECT EXTRACT(MONTH FROM time_of_entrance) AS MONTH, COUNT(visitor_id) AS kids
FROM visitors
WHERE visitors.is_underage = 1
GROUP BY EXTRACT (MONTH FROM time_of_entrance);


-- 10. Displaying the most expensive payment and the ID's and names of artworks icluded in this purchase

SELECT (SELECT MAX(total_orders.payment) FROM total_orders), ordered_artworks.artwork_id, artworks.title
FROM total_orders
INNER JOIN ordered_artworks ON total_orders.total_order_id = ordered_artworks.total_order_id
INNER JOIN artworks ON ordered_artworks.artwork_id = artworks.artwork_id
WHERE payment = (SELECT MAX(total_orders.payment) FROM total_orders);










