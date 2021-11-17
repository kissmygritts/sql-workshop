# SQL Statements, GROUP BY

The mammals database has a several thousand rows of data. But how much data does it actually have? A quick way to find out is to run our first aggregate function.

```sql
SELECT count(*)
FROM surveys;

/* result
count
-------
 35549
(1 row)
*/
```

This is a special case of aggregate functions. If we are interested in answering the simple question of how many rows are in a table we don't even need to specify a `GROUP BY` statement. But what if we want to know how many animals were capture every year?

```sql
SELECT
	year,
	count(*)
FROM surveys
GROUP BY year
ORDER BY year;

/* result:
 year | count
------+-------
 1977 |   503
 1978 |  1048
 1979 |   719
 1980 |  1415
 1981 |  1472
 ...  | ...
 (26 rows)
*/
```

`GROUP BY` follows the `FROM` statement (and any `JOIN`) and includes the column name(s) to group by. In this case we only used the year column to group the results. We can use as many columns as we need to.

```sql
SELECT
	species.taxa,
	surveys.year,
	count(*)
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species.taxa
ORDER BY surveys.year;

/* result:
ERROR:  column "surveys.year" must appear in the GROUP BY clause or be used in an aggregate function
LINE 3:  surveys.year,
*/
```

Postgres is pretty good about pinpointing and recommending fixes for errors as they occur. In this case, we are told that the `surveys.year` column must appear in the `GROUP BY` statement (or be used in an aggregate function). This is because postgres doesn't know what to do with this column? Should are we trying to summarize information from it? Are we grouping by it? We want to use it in the `GROUP BY` statement.

```sql
SELECT
	species.taxa,
	surveys.year,
	count(*)
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species.taxa, surveys.year
ORDER BY surveys.year;

/* result:
  taxa   | year | count
---------+------+-------
 Rodent  | 1977 |   487
 Rabbit  | 1978 |     2
 Rodent  | 1978 |   990
 Rodent  | 1979 |   658
 Rodent  | 1980 |  1355
 (70 rows)
 */
```

What if we wanted to know the number of species grouped by year? 

```sql
SELECT
	species.genus,
	species.species,
	surveys.year,
	count(*)
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species.genus, species.species, surveys.year
ORDER BY surveys.year, species.genus, species.species;

/* result:
      genus       |     species     | year | count
------------------+-----------------+------+-------
 Chaetodipus      | penicillatus    | 1977 |     7
 Dipodomys        | merriami        | 1977 |   264
 Dipodomys        | ordii           | 1977 |    12
 Dipodomys        | spectabilis     | 1977 |    98
 Neotoma          | albigula        | 1977 |    31
 (509 rows)
 */
 ```
 
 Or, we can use some of the handy operators we learned to combine the species into a single column.
 
 ```sql
 SELECT
	format('%s %s', species.genus, species.species) AS species_name,
	surveys.year,
	count(*)
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species_name, surveys.year
ORDER BY surveys.year, species_name;

/* result:
         species_name           | year | count
---------------------------------+------+-------
 Chaetodipus penicillatus        | 1977 |     7
 Dipodomys merriami              | 1977 |   264
 Dipodomys ordii                 | 1977 |    12
 Dipodomys spectabilis           | 1977 |    98
 Neotoma albigula                | 1977 |    31
 (Rows 509)
*/
```

Pretty much the same thing as the previous query.

*Note: in some SQL engines or clients the query above might not work. Aliases aren't always available in the `WHERE` statement. If you receive an error about a column not missing: first check the spelling, then use the formula or operators that create the alias in the `GROUP BY` statement.*

Finally, what if we are interested in all the years we caught more than 100 of any particular species? We can't do this in the `WHERE` statement because the `WHERE` statement is evaluated and executed before the `GROUP BY` statement. In this case we need to use `HAVING`.

```sql
 SELECT
	format('%s %s', species.genus, species.species) AS species_name,
	surveys.year,
	count(*)
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species_name, surveys.year
HAVING count(*) >= 100
ORDER BY surveys.year, species_name;

/* result:
       species_name        | year | count
---------------------------+------+-------
 Dipodomys merriami        | 1977 |   264
 Dipodomys merriami        | 1978 |   389
 Dipodomys spectabilis     | 1978 |   320
 Dipodomys merriami        | 1979 |   209
 Dipodomys spectabilis     | 1979 |   204
 (98 rows)
 */
```

What is the difference between `HAVING` and `WHERE`? `WHERE` is applied to rows and `HAVING` is applied to groups of rows (aggregate functions). Now our result dataset should only contain groups that have 100 or more captures.

## More than counts

We can do much more than counting results with `GROUP BY`. What if we want to know the first and last year a species was caught?

```sql
 SELECT
	format('%s %s', species.genus, species.species) AS species_name,
	min(surveys.year) AS first_year,
	max(surveys.year) AS max_year
FROM species
JOIN surveys ON species.species_id = surveys.species_id
GROUP BY species_name
ORDER BY species_name;

/* result:
          species_name           | first_year | max_year
---------------------------------+------------+----------
 Ammodramus savannarum           |       1991 |     1993
 Ammospermophilus harrisi        |       1978 |     2002
 Amphispiza bilineata            |       1980 |     2002
 Baiomys taylori                 |       1989 |     1992
 Calamospiza melanocorys         |       1980 |     1987
 (48 rows)
*/
```

Or the mean of the number of species caught during the study? This becomes a little more complicated because we need to first determine how many of each species are captured per year. Then average that for each species to get the mean. We'll do this with a subquery.

```sql
SELECT
	sq.species_name,
	trunc(avg(sq.n)) AS mean
FROM (
	SELECT
		format('%s %s', species.genus, species.species) AS species_name,
		surveys.year,
		count(*) AS n
	FROM species
	JOIN surveys ON species.species_id = surveys.species_id
	GROUP BY species_name, surveys.year
) AS sq
GROUP BY sq.species_name
ORDER BY sq.species_name;

/* result:
          species_name           | mean
---------------------------------+------
 Ammodramus savannarum           |    1
 Ammospermophilus harrisi        |   19
 Amphispiza bilineata            |   15
 Baiomys taylori                 |   11
 Calamospiza melanocorys         |    6
(48 rows)
*/
```

Let's think for a moment how we might solve this problem in another programming language like Python. First, we would need to loop over all of our data to generate the first subquery result. Then we would need to loop again for each species in that result to average over all the years. Or, use a library to solve this problem.

Our SQL code is very concise. There isn't any arbitrary looping, or iterators, or variables to keep track of. As long as we understand how to use a subquery this code is easy to read. And it is fast. This operation only took ~35 milliseconds to complete.

If you're writing an API another thing to think about is the amount of data that is going to be sent over the internet. If we were to write this in Python we would get an entire 35,000 row dataset to filter. If we do it in SQL we are only transmitting 48 rows! (Of course, I'm choosing to ignore some of the downsides of doing it in the database. But I think they are minor compared to doing it in the application code.)

## Pivot tables

Pivot tables are useful for displaying data in more easily understood format for reporting. Instead of trying to remember summaries across years as we look down a table we can simply look across the row for the information. However, this isn't always an easy task. R, for instance, has the `pivot_wider` function from the `tidyr` package. Python has the `pivot_table` method from the `pandas` package. 

Pivot tables might be one of the few times SQL is a substantially more difficult than a programming to implement a solution. I don't know of an easy solution to this problem right now. And it really depends on the database engine that is used. It seems that the more advance a topic the more database engines differentiate how to solve the problem. Postgres has an extension that can be installed to make this easier. But let's look at a naive solution for now.

First, lets grab a small subset of the data. All the captures between 1991-1995 and summarize the number of each species caught each year.

```sql
SELECT
	format('%s %s', species.genus, species.species) AS species_name,
	surveys.year,
	count(*) AS n
FROM species
JOIN surveys ON species.species_id = surveys.species_id
WHERE surveys.year BETWEEN 1991 AND 1995
GROUP BY species_name, surveys.year;
```

Let's use this as a subquery to create a pivot table that uses `year` as the column names and `n` as the value of each cell. *I'm not including the alias table name for the following query for brevity. I recommend always including it when writing production queries.*

```sql
SELECT
species_name,
	-- the pivot
  max(CASE WHEN year = 1991 THEN n ELSE 0 END) AS "1991",
	max(CASE WHEN year = 1992 THEN n ELSE 0 END) AS "1992",
	max(CASE WHEN year = 1993 THEN n ELSE 0 END) AS "1993",
	max(CASE WHEN year = 1994 THEN n ELSE 0 END) AS "1994",
	max(CASE WHEN year = 1995 THEN n ELSE 0 END) AS "1995"
FROM (
	SELECT
		format('%s %s', species.genus, species.species) AS species_name,
		surveys.year,
		count(*) AS n
	FROM species
	JOIN surveys ON species.species_id = surveys.species_id
	WHERE surveys.year BETWEEN 1991 AND 1995
	GROUP BY species_name, surveys.year
) AS pivot
GROUP BY pivot.species_name
ORDER BY pivot.species_name;

/* result:
          species_name           | 1991 | 1992 | 1993 | 1994 | 1995
---------------------------------+------+------+------+------+------
 Ammodramus savannarum           |    1 |    0 |    1 |    0 |    0
 Ammospermophilus harrisi        |   21 |   16 |   15 |   19 |   36
 Amphispiza bilineata            |   15 |   10 |    9 |    7 |    4
 Baiomys taylori                 |   26 |    6 |    0 |    0 |    0
 Campylorhynchus brunneicapillus |    2 |    7 |    5 |    1 |    2
 ...                             |  ... |  ... |  ... |  ... |  ...
(36 rows)
*/
```

Step, but step:

1. The subquery in the `FROM` statement is the same as the previous SQL example. Here we are aliasing this table to `pivot`.
2. The `SELECT` statement uses several `CASE` statements to control the data to be displayed in each column. In this example we are using it to "filter" the subquery result based on the year. So, `CASE WHEN pivot.year = 1991 THEN pivot.n ELSE 0 END` can be read as. "If year is equal to 1991 use the value of n or else use 0". 
3. We need to use `GROUP BY` to collapse our final result into a table with only one row for each species. Since we are using `GROUP BY` each column not included in the `GROUP BY` statement must be used in an aggregate function. That is why we are using the `max()` function to return n from the `pivot` subquery.

Practice writing queries like this for other date ranges.

*Note: I mostly include this example because I've needed to use it several times when writing queries against a MySQL 5.0 database that doesn't support better ways of doing pivots. In a later section we'll review another way to create pivot tables.*