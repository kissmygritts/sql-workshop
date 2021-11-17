# SQL Functions and Operators

Postgres has a [shit load of built in functions and operators](https://www.postgresql.org/docs/14/functions.html) that will make working with data much more fun. To highlight a few:

* Basic math operators work as expected
* There are string functions that work similarly to those in Excel, Python, or R.
* Date and time functions.
* JSON functions for working efficiently with JSON data types.
* Aggregate functions for returning summary statistics from grouped data.
* And many other functions provided by extensions like PostGIS.

Like almost everything in programming there are many different ways to use functions on a set of data. We can use our favorite programming languages to pull data and manipulate them as needed in whichever language we choose. So why learn yet another way to manipulate data? First, running these functions in SQL will operate on the entire dataset without the need to loop over each row manually. Second, these functions are usually written in a very low level language like C, which means they will likely be more efficient than what ever programming language you choose.

## String and text formatting functions

So far, we've returned raw column data with the SQL queries we've written. We can do some fancy manipulation to these columns in the `SELECT` statement. Every query we've run so far returns genus and species as separate columns. A good data management practice, but maybe we want to concatenate them for output?

```sql
SELECT
	taxa,
	format('%s %s', genus, species)
FROM species;

/* result:
  taxa   |             format
---------+---------------------------------
 Bird    | Amphispiza bilineata
 Rodent  | Ammospermophilus harrisi
 Bird    | Ammodramus savannarum
 Rodent  | Baiomys taylori
 ...     | ...
 (54 rows)
 */
```

[`format`](https://www.postgresql.org/docs/14/functions-string.html#FUNCTIONS-STRING-FORMAT) will return a formatted string similar to that in Python. Alternatively, we can use `||`[^infix] to concatenate strings.

```sql
SELECT
	taxa,
	genus || species
FROM species
LIMIT 4;

/* result:
  taxa  |        ?column?
--------+-------------------------
 Bird   | Amphispizabilineata
 Rodent | Ammospermophilusharrisi
 Bird   | Ammodramussavannarum
 Rodent | Baiomystaylori
 (4 rows)
 */
```

Well, that didn't work exactly as intended. The text doesn't have a space between words. And the name of the column looks strange. Let's fix that first by adding a space between the words. Then by using an *alias* for the column with `AS`.

```sql
SELECT
	taxa,
	genus || ' ' || species AS species_name
FROM species
LIMIT 4;

/* result:
LIMIT 4;
  taxa  |       species_name
--------+--------------------------
 Bird   | Amphispiza bilineata
 Rodent | Ammospermophilus harrisi
 Bird   | Ammodramus savannarum
 Rodent | Baiomys taylori
(4 rows)
*/
```

[Here is a complete list of string function provided by Postgres](https://www.postgresql.org/docs/14/functions-string.html). 

## Date and time

Dates and time data types are pretty much the bane of every programmers existence. Postgres supports three date and time data types (5 if you count the with time zone variations):

1. timestamp without time zone
2. timestamp with time zone
3. date
4. time without time zone
5. time with timezone

Best practices for timestamps and time data types are to use timezones when possible. This will at least help us know where to get started.

In our sample mammals database the date is split across 3 columns. Let's fix that and create a single date column for this information.

```sql
SELECT
	year,
	month,
	day,
	format('%s-%s-%s', year, month, day)::date AS survey_date
FROM surveys
LIMIT 5;

/* result:
 year | month | day | survey_date
------+-------+-----+-------------
 1977 |     7 |  16 | 1977-07-16
 1977 |     7 |  16 | 1977-07-16
 1977 |     7 |  16 | 1977-07-16
 1977 |     7 |  16 | 1977-07-16
 1977 |     7 |  16 | 1977-07-16
(5 rows)
*/
```

First, we formatted the three date columns into a single string with the `format` function. Then we cast the string into a date with `::date`. And finally aliased this to the name `survey_date`.

Now that we have an actual date field we can filter the results by date!

```sql
SELECT
	year,
	month,
	day,
	format('%s-%s-%s', year, month, day)::date AS survey_date
FROM surveys
WHERE survey_date >= '1990-01-01'
LIMIT 5;

/* result
ERROR:  column "survey_date" does not exist
LINE 7: WHERE survey_date >= '1990-01-01'
*/
```

Unfortunately we get an error. This is because the alias `survey_date` isn't available in the `WHERE` statement. In order to filter by date we need to repeat the format and cast operation in the where clause too.

```sql
SELECT
	year,
	month,
	day,
	format('%s-%s-%s', year, month, day)::date AS survey_date
FROM surveys
WHERE format('%s-%s-%s', year, month, day)::date >= '1990-01-01'
LIMIT 5;

/* result:
 year | month | day | survey_date
------+-------+-----+-------------
 1990 |     1 |   6 | 1990-01-06
 1990 |     1 |   6 | 1990-01-06
 1990 |     1 |   6 | 1990-01-06
 1990 |     1 |   6 | 1990-01-06
 1990 |     1 |   6 | 1990-01-06
(5 rows)
*/
```

An alternative that is worth mentioning now is using a subquery to filter this data:

```sql
SELECT *
FROM (
	SELECT
		year,
		month,
		day,
		format('%s-%s-%s', year, month, day)::date AS survey_date
	FROM surveys) AS sq
WHERE sq.survey_date >= '1990-01-01'
LIMIT 5;
```

This pattern is useful when we need to filter a complex calculation or formula of some kind without repeating code. 

[^infix]: This type of function is referred to as an [infix operator](https://en.wikipedia.org/wiki/Infix_notation).
