use sakila;

/*
1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
*/


SELECT DISTINCT title
FROM film;


/*
2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
*/


SELECT title, 
rating AS classification
FROM film
WHERE rating = 'PG-13';


/*
3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
*/


SELECT title,
description
FROM film
WHERE description IN ('amazing');


/*
4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
*/


SELECT title, 
length
FROM film
WHERE length > 120;


/*
5. Recupera los nombres de todos los actores.
*/

SELECT first_name, 
last_name
FROM actor;



/*
6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
*/


SELECT first_name,
last_name
FROM actor
WHERE last_name IN ('Gibson');


/*
7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.
*/


SELECT first_name,
last_name,
actor_id
FROM actor
WHERE actor_id BETWEEN 10 AND 20;


/*
8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.
*/


SELECT title,
rating
FROM film
WHERE NOT rating = 'R' AND NOT rating = 'PG-13';


/*
9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.
*/


SELECT rating, 
COUNT(rating) AS TOTAL
FROM film
GROUP BY rating;


/*
10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.
*/


SELECT customer.customer_id,
customer.first_name,
customer.last_name,
COUNT(rental.customer_id) AS Total_films_rented
FROM customer
JOIN rental
ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id;


/*
11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
*/


SELECT
category.name AS name,
COUNT(rental.rental_id) AS total_rented
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY category.name; 


/*
12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
*/


SELECT rating AS classification,
AVG(length) AS Average_length
FROM film
GROUP BY rating;


/*
13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".
*/


SELECT
actor.first_name,
actor.last_name,
film.title 
FROM actor
JOIN film_actor
ON actor.actor_id = film_actor.actor_id
JOIN film
ON film.film_id = film_actor.film_id
WHERE film.title = 'Indian Love';


/*
14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
*/


SELECT title,
description
FROM film
WHERE description LIKE '%dog%' or description LIKE '%cat%';


/*
15. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.
*/

-- left join porque quiero conservar todas las columnas de la tabla actor y solamente unir con las que coinciden de film_actor(actor_id)


SELECT 
actor.actor_id,
actor.first_name, 
actor.last_name
FROM actor
LEFT JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
WHERE film_actor.actor_id IS NULL;


/*
16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
*/


SELECT title,
release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;


/*
17. Encuentra el título de todas las películas que son de la misma categoría que "Family".
*/

-- unir las tablas para luego buscar la palabra family in category

WITH union_table AS(
	SELECT film.title,
    film.film_id,
    category.name AS category
    FROM film
    JOIN film_category
    ON film.film_id = film_category.film_id
    JOIN category
    ON film_category.category_id = category.category_id
)

SELECT *
FROM union_table
WHERE category in ('Family');



/*
18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
*/

-- juntar en una tabla nombres, con film_id, luego filtrar por mas de 10 peliculas

WITH nombre_apellido AS(
	SELECT DISTINCT(actor.first_name),
	actor.last_name,
	film_actor.film_id
    FROM actor
    JOIN film_actor
    ON actor.actor_id = film_actor.actor_id
    JOIN film
    ON film_actor.film_id = film.film_id
)


-- filtrar los que estuvieron en mas de 10 peliculas

SELECT *
FROM nombre_apellido
WHERE film_id > 10;



/*
19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.
*/

SELECT title,
rating AS classification,
length AS duration
FROM film
WHERE length > 120 AND
rating IN ('R');



/*
20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.
*/


-- unir columnas nombre de categoria con la duracion

WITH name_length AS (
	SELECT category.name,
    AVG(film.length) as average
    FROM category
    JOIN film_category
    ON category.category_id = film_category.category_id
    JOIN film
    ON film_category.film_id = film.film_id
    GROUP BY category.name
)


-- filtrar por la duracion

SELECT *
from name_length
WHERE average > 120;



/*
21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.
*/

SELECT film_actor.actor_id,
actor.first_name,
actor.last_name,
-- contar la cantidad de peliculas
COUNT(film_actor.film_id) AS quantity_films
FROM film_actor
JOIN actor
ON film_actor.actor_id = actor.actor_id
-- filtrar por los que esten en 5 o mas peliculas
WHERE film_actor.film_id >= 5
-- agrupar por id
GROUP BY film_actor.actor_id 
-- ordenar de menor a mayor cantidad
ORDER BY quantity_films ASC;



/*
22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. 
Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
*/

-- union de tablas

SELECT DISTINCT film.title, 
subquery.quantity_days
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id

-- filtrar cantidad de dias
JOIN (
    SELECT rental_id, DATEDIFF(return_date, rental_date) AS quantity_days
    FROM rental
    WHERE DATEDIFF(return_date, rental_date) > 5
) subquery ON rental.rental_id = subquery.rental_id;



/*
23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". 
Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.
*/

-- nombres de actores y de las categorias


WITH nombre_categoria AS (
	SELECT actor.first_name,
    actor.last_name,
    category.name
    FROM category
    JOIN film_category
    ON category.category_id = film_category.category_id
    JOIN film_actor
    ON film_category.film_id = film_actor.film_id
    JOIN actor
    ON film_actor.actor_id = actor.actor_id
)

-- quitar los que esten en categoria horror

SELECT *
FROM nombre_categoria
WHERE name NOT IN ('Horror');


/*
24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor
a 180 minutos en la tabla film.
*/


-- filtrar por titulo y la duracion

WITH union_table AS (
	SELECT film.title,
    category.name,
	film.length
    FROM category
    JOIN film_category
    ON category.category_id = film_category.category_id
    JOIN film
    ON film_category.film_id = film.film_id
    WHERE film.length > 180
)

-- filtrar por la categoria comedia

SELECT *
FROM union_table
WHERE name IN ('Comedy');



/*
25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. 
La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.
*/

-- seleccionar los nombres de los actores
-- primer actor
SELECT a1.first_name AS first_name_1, 
a1.last_name AS last_name_1,
-- segundo actor
a2.first_name AS first_name_2, 
a2.last_name AS last_name_2,
-- contar las peliculas que tienen en comun
COUNT(fa1.film_id) AS films_together
FROM actor a1
-- unir las tablas de actor 1 con el actor 2
-- fa1 y fa2 son alias de la tabla film_actor
JOIN film_actor fa1 
ON a1.actor_id = fa1.actor_id
-- fa1.actor_id <> fa2.actor_id asegura que no sean los mismos actores los que se emparejen
JOIN film_actor fa2 
ON fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id
JOIN actor a2 
ON fa2.actor_id = a2.actor_id
-- agupar por los id de los actores
GROUP BY a1.actor_id, a2.actor_id
-- ordenar de menor cantidad a mayor
ORDER BY films_together ASC;


