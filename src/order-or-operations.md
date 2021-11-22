Refer to this article for now: https://www.eversql.com/sql-order-of-operations-sql-query-order-of-execution/

This has implications for when things like aliases are available for use. For example, the following query returns an error:

``` sql
SELECT
  record_id,
  (hindfoot_length + weight) / weight AS hfw_alias
FROM surveys
WHERE hfw_alias IS NOT NULL;

/* error:
ERROR:  column "hfw_alias" does not exist
LINE 5: WHERE hfw_alias IS NOT NULL;
*/
```

The correct way to write this query is:

```sql
SELECT
  record_id,
  (hindfoot_length + weight) / weight AS hfw_alias
FROM surveys
WHERE (hindfoot_length + weight) IS NOT NULL;

/* result:
 record_id | hfw_alias 
-----------+-----------
        63 |     1.875
        64 | 1.7708334
        65 | 2.1724138
        66 | 1.7608696
        67 | 1.9722222
...        | ...
*/
```

<!-- TODO: some discussion on scope and when things are available? -->

<!-- (TODO: link to CTEs from here too) -->
If we have many aliases that we want to use as filters, and don't want to constantly rewrite the operations we can use subqueries. The alias `hfw_alias` is available in the where clause because the `FROM` statement is evaluated first. The result should be the same as above. 

```sql
SELECT *
FROM (
  SELECT
    record_id,
    (hindfoot_length + weight) / weight AS hfw_alias
  FROM surveys ) AS sq
WHERE hfw_alias IS NOT NULL;
```