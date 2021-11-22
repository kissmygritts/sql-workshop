# SQL Statements, Querying Data

In this section we'll cover how to query data from an existing database. We will use the [mammals dataset](../scripts/load-mammals.sql) data set to explore how to use a few of the most important *SQL statements*: `SELECT`, `FROM`, `WHERE`, and `ORDER BY`. These SQL statements, or *clauses*, are often used together as the first steps to help understand our data. What does it look like? How clean or dirty are the data? In programming languages like R or Python we might use tools like dplyr or Pandas to do this. Nearly every technique used in those packages is possible right here, in the database.

## `SELECT`

Nearly every data fetching SQL statement starts with `SELECT`. This will tell the database what to return. In postgres the simplest `SELECT` statement looks like the following:

```sql
SELECT 1;

/* result:
 ?column?
----------
        1
(1 row)
*/
```

We can do a lot more with a simple `SELECT` statement like this. The SQL Standard and [postgres](https://www.postgresql.org/docs/14/functions.html) have many function that can be run with only `SELECT`.

```sql
SELECT now();

/* result:
              now
-------------------------------
 2021-11-13 10:19:32.362358-08
(1 row)
*/

SELECT 1 + 1;

/* result:
 ?column?
----------
        2
(1 row)
*/

SELECT format('Hello, %s', 'Mitchell');

/* result:
     format
-----------------
 Hello, Mitchell
(1 row)
*/
```

It is probably most important to understand that the `SELECT` statement is used to specify the return values of a query. `SELECT` allow us to choose which columns to return, and transform or manipulate that data in some way with the provided functions. 

Now, the simple `SELECT` statements we ran above aren't very useful. In order to start really using SQL we need to load our first test database into postgres. Read the instructions here: [[Example Datasets#Small Mammals]].

## `FROM`

The `FROM` statement is used to identify the tables to return table from. If the mammals database is loaded into postgres we can run the following:

```sql
SELECT * FROM species;
```

If I tell you that `*` is a shorthand for "all columns" this statement can be read like a sentence: "select all columns from species." And the query does exactly that. All the columns (and rows) from the species table will be returned.

```
 species_id |      genus       |     species     |  taxa
------------+------------------+-----------------+---------
 AB         | Amphispiza       | bilineata       | Bird
 AH         | Ammospermophilus | harrisi         | Rodent
 AS         | Ammodramus       | savannarum      | Bird
 BA         | Baiomys          | taylori         | Rodent
 CB         | Campylorhynchus  | brunneicapillus | Bird
 ...				| ...							 | ...						 | ...
```

Many times, when investigating a datasets the first query might look something like just like this. I run `SELECT * FROM table_name;` queries all the time. Mostly to remind my self of the column names and data within the tables[^table]. 

We can return individual rows by specifying their name after the `SELECT`:

```sql
SELECT
	genus,
	species
FROM species;

/* result:
      genus       |     species
------------------+-----------------
 Amphispiza       | bilineata
 Ammospermophilus | harrisi
*/
```

This will return only the `genus` and `species` column, and all the rows from the `species` table.

We can explicitly reference the table we to pull the columns from. This isn't required in the example above since we are only pulling data from a single table. If we are going to join multiple tables it is best to use a reference to each table each column belongs to. This avoids ambiguity. For example, the query above can be written as:

```sql
SELECT
	species.genus,
	species.species
FROM species
```

## `WHERE`

`WHERE` is used to filter the data returned by a SQL statement. Just like `filter` in R or Python. `WHERE` always comes after the `FROM` statement:

```sql
SELECT
	species.genus,
	species.species
FROM species
WHERE taxa = 'Bird';

/* result:
      genus      |     species
-----------------+-----------------
 Amphispiza      | bilineata
 Ammodramus      | savannarum
 ...						 | ....
 (13 rows)
*/
```

Multiple conditions are allowed in the where clause, separated by `AND`: 

```sql
SELECT
	species.genus,
	species.species
FROM species
WHERE species.taxa = 'Rodent'
	AND species.genus = 'Sigmodon';
	
/* result:
  genus   |   species
----------+--------------
 Sigmodon | fulviventer
 Sigmodon | hispidus
 Sigmodon | ochrognathus
 Sigmodon | sp.
 (4 rows)
*/
```

Conditions can be separated by `OR` to return rows that match either condition:

```sql
SELECT
	species.genus,
	species.species
FROM species
WHERE species.taxa = 'Rodent'
	OR species.taxa = 'Bird';
	
/* result:
      genus       |     species
------------------+-----------------
 Amphispiza       | bilineata
 Ammospermophilus | harrisi
 Ammodramus       | savannarum
 Baiomys          | taylori
 Campylorhynchus  | brunneicapillus
 ...							| ...
 (44 rows)
*/
```

`AND` and `OR` can be combined:

```sql
SELECT
	species.genus,
	species.species,
	species.taxa
FROM species
WHERE (species.taxa = 'Rodent' OR species.taxa = 'Bird')
	AND species.species = 'sp.';

/* result:
      genus      | species |  taxa
-----------------+---------+--------
 Dipodomys       | sp.     | Rodent
 Neotoma         | sp.     | Rodent
 Onychomys       | sp.     | Rodent
 Chaetodipus     | sp.     | Rodent
 Reithrodontomys | sp.     | Rodent
 Sigmodon        | sp.     | Rodent
 Pipilo          | sp.     | Bird
 Rodent          | sp.     | Rodent
 Sparrow         | sp.     | Bird
(9 rows)
*/
```

Again, remember that SQL statements read like a sentence, "Select genus, species, taxa from species where taxa is equal to Rodent or taxa is equal to Bird and species is equal to sp.". The result is all the rows of the species table have the taxa Rodent or Bird, and a species of sp.

The `WHERE` statement is evaluated left to right. Parantheses are used to combine the different parts of the `WHERE` statement into logical groups. If we modify the query above without parantheses the result is different.

```sql
SELECT
	species.genus,
	species.species,
	species.taxa
FROM species
WHERE species.taxa = 'Rodent' OR species.taxa = 'Bird'
	AND species.species = 'sp.';

/* result:
      genus       |   species    |  taxa
------------------+--------------+--------
 Ammospermophilus | harrisi      | Rodent
 Baiomys          | taylori      | Rodent
 Dipodomys        | merriami     | Rodent
 Dipodomys        | ordii        | Rodent
 Dipodomys        | spectabilis  | Rodent
 ...              | ...          | ...
(33 rows)
```

This query returns all the row where `taxa = 'Rodent'` and all the rows where `taxa = 'Bird' AND 'species = 'sp.'`. Notice that every rodent species is returned but only the two bird species.

Instead of using `OR` we can use `IN` since the `WHERE` condition for Rodent and Bird refer to the same column. This isn't always the case for more complex queries, but it works here. As an added benefit, it makes the SQL statement easier to read (*note: `IN` will work with a single value as well. `taxa IN ('Rodent')` is a valid statement.*):

```sql
SELECT
	species.genus,
	species.species,
	species.taxa
FROM species
WHERE species.taxa IN ('Rodent', 'Bird')
	AND species.species = 'sp.';
```

We can even filter by partial string matches:

```sql
SELECT
	*
FROM species
WHERE species.genus LIKE '%us';

/* result:
 species_id |      genus       |     species     |  taxa
------------+------------------+-----------------+--------
 AH         | Ammospermophilus | harrisi         | Rodent
 AS         | Ammodramus       | savannarum      | Bird
 ...        | ...              | ...             | ...
 (21 rows)
*/
```

`LIKE` will match a string fragment. The `%` is used as a wildcard to mean any combination of characters. In the example above `%us` means, "ends with us". We can change this to match words that start with too:

```sql
SELECT
	*
FROM species
WHERE species.genus LIKE 'pero%';

/* result
 species_id | genus | species | taxa
------------+-------+---------+------
(0 rows)
*/
```

What happened? Our query returned 0 rows? That is because LIKE is case sensitive. Instead, try `ILIKE`:

```sql
SELECT
	*
FROM species
WHERE species.genus ILIKE 'pero%';

/* result:
 species_id |    genus    |   species   |  taxa
------------+-------------+-------------+--------
 PE         | Peromyscus  | eremicus    | Rodent
 PF         | Perognathus | flavus      | Rodent
 PH         | Perognathus | hispidus    | Rodent
 PL         | Peromyscus  | leucopus    | Rodent
 PM         | Peromyscus  | maniculatus | Rodent
(5 rows)
*/
```

Read all about pattern matching in postgres [here](https://www.postgresql.org/docs/14/functions-matching.html). We'll be using some of these patterns later.

[^table]: `SELECT * FROM species;` is functionally equivalent to `TABLE species;` Go ahead and try it out. 