## Even more `JOIN`s

So far we've been using `JOIN` to join our tables. This is a really an alias for `INNER JOIN` which will join two table where each have a value in the respective table. The easiest way to do this is with some made up examples. Go ahead and create these tables in the mammals database. We will delete them later.

```sql
CREATE TABLE teachers (
	id int,
	teacher_name text
);

CREATE TABLE subjects (
	teacher_id int,
	subject text
);

INSERT INTO teachers
VALUES
	(1, 'Milton Mohren'),
	(2, 'Kimmie Bonnay'),
	(3, 'Yasir Ebrahim'),
	(4, 'Shigeru Levitt');
	
INSERT INTO subjects
VALUES
	(1, 'Chemistry'),
	(1, 'Physics'),
	(2, 'Physics'),
	(2, 'Geometry'),
	(3, 'Biology'),
	(3, 'Chemistry'),
	(5, 'English');
```

This example dataset doesn't necessary follow good database design principles, but it will work for understanding the different types of joins. As you can see from this dataset, teacher Shigeru Levitt doesn't have any classes (their ID isn't in the subjects table). And English has a `teacher_id` that doesn't exist in the teachers table. Let see what happens when we use `INNER JOIN` (remember, that is the same as `JOIN`).

```sql
SELECT *
FROM teachers
INNER JOIN subjects ON teachers.id = subjects.teacher_id;

/* result:
 id | teacher_name  | teacher_id |  subject
----+---------------+------------+-----------
  1 | Milton Mohren |          1 | Chemistry
  1 | Milton Mohren |          1 | Physics
  2 | Kimmie Bonnay |          2 | Physics
  2 | Kimmie Bonnay |          2 | Geometry
  3 | Yasir Ebrahim |          3 | Biology
  3 | Yasir Ebrahim |          3 | Chemistry
(6 rows)
*/
```

Shigeru Levitt and English aren't in this result table. This is because there isn't a match for these two rows when joined on `teachers.id = subjects.teacher_id`. This is how `INNER JOIN` works. It only returns the rows in each table where a match is found. 

The next most common join is called `LEFT JOIN`. This will return all the data from the left hand table and only rows that match from the right hand table.

```sql
SELECT *
FROM teachers
LEFT JOIN subjects ON teachers.id = subjects.teacher_id;

/* result:
 id |  teacher_name  | teacher_id |  subject
----+----------------+------------+-----------
  1 | Milton Mohren  |          1 | Chemistry
  1 | Milton Mohren  |          1 | Physics
  2 | Kimmie Bonnay  |          2 | Physics
  2 | Kimmie Bonnay  |          2 | Geometry
  3 | Yasir Ebrahim  |          3 | Biology
  3 | Yasir Ebrahim  |          3 | Chemistry
  4 | Shigeru Levitt |            |
(7 rows)
*/
```

Now Shigeru Levitt shows up in the result table, but the values for `teacher_id` and `subject` are null because there isn't a matching value in the subjects table. How do we know they are nul? We can change how `psql` displays null values in the result table.

```sql
\pset null '❌'
```

`psql` will now use the ❌ emoji to display null values. Try running the query above again, and the result should look like the following:

```text
 id |  teacher_name  | teacher_id |  subject
----+----------------+------------+-----------
  1 | Milton Mohren  |          1 | Chemistry
  1 | Milton Mohren  |          1 | Physics
  2 | Kimmie Bonnay  |          2 | Physics
  2 | Kimmie Bonnay  |          2 | Geometry
  3 | Yasir Ebrahim  |          3 | Biology
  3 | Yasir Ebrahim  |          3 | Chemistry
  4 | Shigeru Levitt |          ❌ | ❌
(7 rows)
```

If we switch the order of the *join constraint* in the query what happens?

```sql
SELECT *
FROM teachers
LEFT JOIN subjects ON subjects.teacher_id = teachers.id;
```

Nothing. The actual *left* in a `LEFT JOIN` is the table name on the left side of the join. For clarity's sake, it is best to put the join constraint in the same order. The syntax should look like this, `left_table LEFT JOIN right_table ON left_table.id = right_table.id`.

So if we change the order of the tables we will have an entirely different query.

```sql
SELECT *
FROM subjects
LEFT JOIN teachers ON subjects.teacher_id = teachers.id;

/* result:
 teacher_id |  subject  | id | teacher_name
------------+-----------+----+---------------
          1 | Chemistry |  1 | Milton Mohren
          1 | Physics   |  1 | Milton Mohren
          2 | Physics   |  2 | Kimmie Bonnay
          2 | Geometry  |  2 | Kimmie Bonnay
          3 | Biology   |  3 | Yasir Ebrahim
          3 | Chemistry |  3 | Yasir Ebrahim
          5 | English   |  ❌ | ❌
(7 rows)
*/
```

The order of the columns have changed. The more important thing to notice is that English now appears in the result table while Shigeru Levitt does not. 

This query is functionally equivalent to a `RIGHT JOIN`. A `RIGHT JOIN` will return all the rows in the right table and only those matching in the left table.

```sql
SELECT *
FROM teachers
RIGHT JOIN subjects ON teachers.id = subjects.teacher_id;

/* result:
 id | teacher_name  | teacher_id |  subject
----+---------------+------------+-----------
  1 | Milton Mohren |          1 | Chemistry
  1 | Milton Mohren |          1 | Physics
  2 | Kimmie Bonnay |          2 | Physics
  2 | Kimmie Bonnay |          2 | Geometry
  3 | Yasir Ebrahim |          3 | Biology
  3 | Yasir Ebrahim |          3 | Chemistry
  ❌ | ❌             |          5 | English
(7 rows)
*/
```

Same result as the previous query, but different order of columns. 

Whether to use `RIGHT JOIN` or `LEFT JOIN` is a decision for each developer. Regardless of the decision, it is important to be consistent. There are rarely instances where a query must us both of these joins.

## And even more `JOIN`s

```sql
SELECT *
FROM teachers
FULL OUTER JOIN subjects ON teachers.id = subjects.teacher_id;

SELECT *
FROM teachers
CROSS JOIN subjects;
```