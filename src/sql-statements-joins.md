# SQL Statements, JOINS

The real power of relational databases is the support for storing data across multiple, related tables that can then be joined together. In the relational model each table holds a single entity (type of data). For example, tables of species, plots, and surveys (like our sample database). Each row is a single occurrence of an entity. In the species table each row describes a single species. 

The syntax looks a bit like the following:

```sql
SELECT *
FROM table_a
JOIN table_b ON table_a.key_column = table_b.foreign_key_column
```

The relationship described in the SQL above will return all the columns from both `table_a` and `table_b` where `table_a.key_column` is equal to `table_b.foreign_key_column`. 

These tables are joined on columns that can be related to each other. These columns are often referred to as *keys*. A key is generally used to uniquely identify a column (*primary key*), or reference a row in another table (*foreign key*). 

In our mammals database the species and surveys table each have a `species_id` column. The `species.species_id` column is the primary key for the species table. `surveys.species_id` is a foreign key in the surveys table. We can use these keys to find out which species were observed on each survey. 

Let's change how `psql` displays the results to make them a little easier to read. Type `\x` to turn on the extended display. (To turn off extended display us `\x` again).

```sql
SELECT 
	*
FROM species
JOIN surveys ON species.species_id = surveys.species_id
LIMIT 5;

/* result:
-[ RECORD 1 ]---+----------
species_id      | NL
genus           | Neotoma
species         | albigula
taxa            | Rodent
record_id       | 1
month           | 7
day             | 16
year            | 1977
plot_id         | 2
species_id      | NL
sex             | M
hindfoot_length | 32
weight          |
-[ RECORD 2 ]---+----------
species_id      | NL
genus           | Neotoma
species         | albigula
taxa            | Rodent
record_id       | 2
month           | 7
day             | 16
year            | 1977
plot_id         | 3
species_id      | NL
sex             | M
hindfoot_length | 33
weight          |
*/
```

Each row returned by the query has data from the species table and the data from the surveys table based on the join. 
 
More often than not the `join_constraint` (the part of the `JOIN` statement that describes how to join the tables) is described in the table schema. For instance, run `\d surveys` in `psql`:
 
 ``` text
                    Table "public.surveys"
     Column      |  Type   | Collation | Nullable | Default
-----------------+---------+-----------+----------+---------
 record_id       | integer |           | not null |
 month           | integer |           |          |
 day             | integer |           |          |
 year            | integer |           |          |
 plot_id         | integer |           |          |
 species_id      | text    |           |          |
 sex             | text    |           |          |
 hindfoot_length | real    |           |          |
 weight          | real    |           |          |
Indexes:
    "surveys_pkey" PRIMARY KEY, btree (record_id)
Foreign-key constraints:
    "surveys_plot_id_fkey" FOREIGN KEY (plot_id) REFERENCES plots(plot_id)
    "surveys_species_id_fkey" FOREIGN KEY (species_id) REFERENCES species(species_id)
 ```
 
At the very bottom the relationships are listed in the "Foreign-Key constraints" section. In this case, there are two relationships. One to the species table (as shown in the SQL query above, and the other to the plots table. Read the relationship `surveys_plot_id_fkey" FOREIGN KEY (plot_id) REFERENCES plots(plot_id)` as: "Foreign key *plot_id* references *plots* on *plot_id*". 
 
The relationship between the species and surveys is a one-to-many relationship. Each row in the species table can relate to many rows in the surveys table. Two other types of relationships are one-to-one, and many-to-many. These aren't as common as one-to-many. We will review them more closely later.

## Practice writing joins

Now that we have a basic understanding of relationships we can start writing them to better understand our data set.

```sql
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id;
```

Here, we've joined all the tables together and returned only the columns we are currently interested in.

From now that we have a query that will join our tables we can begin to query it to get slices of the data.

```sql
-- only return Dipodomys merriami
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id
WHERE species.genus = 'Dipodomys'
	AND species.species = 'merriami';
	
-- only return Dipodomys merriami surveyed in a control plot
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id
WHERE species.genus = 'Dipodomys'
	AND species.species = 'merriami'
	AND plots.plot_type = 'Control';
	
-- same as above, but where we have complete records 
-- for each Dipodomys merriami
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id
WHERE species.genus = 'Dipodomys'
	AND species.species = 'merriami'
	AND plots.plot_type = 'Control'
	AND surveys.sex IS NOT NULL
	AND surveys.hindfoot_length IS NOT NULL
	AND surveys.weight IS NOT NULL;
```

Remember, we can use `OR`, or `IN` to return other matches as well.

```sql
-- return Dipodomys merriami or Dipodomys ordii 
-- captured in a control plot
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id
WHERE (
(species.genus = 'Dipodomys' AND species.species = 'merriami')
OR (species.genus = 'Dipodomys' AND species.species = 'ordii'))
	AND plots.plot_type = 'Control';
	
-- return all Dipodomys from krat exclosures
SELECT
	species.taxa,
	species.genus,
	species.species,
	surveys.sex,
	surveys.hindfoot_length,
	surveys.weight,
	plots.plot_type
FROM species
JOIN surveys ON species.species_id = surveys.species_id
JOIN plots ON surveys.plot_id = plots.plot_id
WHERE species.genus = 'Dipodomys'
	AND plots.plot_type IN ('Long-term Krat Exclosure', 'Short-term Krat Exclosure');
```