SQL databases are typed. Which means each column in a table must have a specific data type associated with it. This contrasts programming languages like R and Python that are *dynamically typed* (the compiler infers the type based on the code). We can inspect, for example, the data types of each table in our mammals database with the `\d table_name` meta command.

```sql
\d species

/*
               Table "public.species"
   Column   | Type | Collation | Nullable | Default
------------+------+-----------+----------+---------
 species_id | text |           | not null |
 genus      | text |           |          |
 species    | text |           |          |
 taxa       | text |           |          |
...
*/
```

The first column tells us the column name and the second column tells us the data type of that column. 

[Postgres recognizes many, many datatypes](https://www.postgresql.org/docs/current/datatype.html). However, only a few are commonly used. Postgres does confrom to the SQL standard for data types, but adds additional data types that aren't in the SQL standard for convenience.

## Character data types

We'll only use the `text` type to represent characters or text strings. Older databases might you may see one of the following: `varchar(n)`, `char(n)`, `character(n)`, `character varying(n)` for various reasons. However, the [Postgres documentation](https://www.postgresql.org/docs/current/datatype-character.html) note that the performance tradoffs between the types is small and `text` or `character varying` should be used. *Opt for text for simplicity*. 

## Numeric types

There are several different types to hold data like integers and decimals (arbitrary precision numbers). Each type for these categories has a few variations that determine the amount of memory used. Refer to the table from [the Postgres documentation](https://www.postgresql.org/docs/current/datatype-numeric.html) for a full overview of numeric types.

For simplicity we'll stick with `integer` (or `int`), `real` for most float or decimal types, `double percision` if we need to store higher precision decimals, and `serial` for autoincrementing IDs.

Numeric types include the special values `Infinity`, `-Infinity`, and `NaN` (not a number).

## Boolean types

Boolean types are used the store "true" or "false" states. The values: `true, yes, on, 1` all represent `true`. `false, no, off, 0` all represent false. An empty, blank, or null value represents "unknown".

## Date time types

Postgres supports a feature rich set of date/time types and functions that operate on these types. The types we'll most commonly use are: `timestamp` with and without time zone, `date`, and `time` with and without time zone. 

We'll go into more depth on date/time types and operations later (TODO: where?).

## A table of common data types

| type | usage |
| --- | --- |
| `text` | Store string and character data |
| `int` | Store negative and positive integers |
| `real` | Store decimal numbers up to 6 decimal digits |
| `double precision` | Store decimals number up to 15 decimal digits |
| `serial` | Store positive autoincrementing integers, mostly for IDs |
| `boolean` | Store true of false state |
| `timestamp with time zone` | Store a date and time with the time zone |
| `date` | Store a date |
| `time with time zone` | Store a time with the time zone |

*Note: I recommend always using the time zone when using a `timestamp`. This will prevent any ambiguity when attempting to access or transform timestamps. Same for `time`*

## Casting types

SQL will not automatically convert, or cast, data types. This must be done manually. The easiest way to do this is with the `::` (double colon): 

```sql
SELECT '1'::int;
SELECT '3.14'::real;
SELECT '2021-01-01'::date;
SELECT now()::text;
```

Postgres will offer surprisingly helpful errors when there are type mismatches. For example:

```sql
SELECT '1' + '1';

/* error:
ERROR:  operator is not unique: unknown + unknown
LINE 1: select '1' + '1';
                   ^
HINT:  Could not choose a best candidate operator. You might need to add explicit type casts.
*/
```

As we work through more examples I'll try and show you some common type errors like this, and how to interpret the error messages.