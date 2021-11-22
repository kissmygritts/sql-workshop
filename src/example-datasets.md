## Small Mammals

This dataset is a time-series of small mammal communities from southern Arizona. This is part of a project studying the effects of rodents and ants on the plant community that has been running for almost 40 years. The rodents are sampled on a series of 24 plots with different experimental manipulations controlling which rodents are allowed to access which plots.

This is a real dataset that has been used in over 100 publications! (*Source: Data Carpentry's SQL workshop*)

### Load the dataset

Once you are ready to use this dataset run `createdb mammals` to create a database to load the data into.

Once the database is created use the `scripts/load-mammals.sql` file to create the tables and load the data. You sequence of commands should look like the following:

```bash
# create the mammals database
createdb mammals

# connect to the mammals database
psql mammals

# now you've logged in, run this command to load the data
\i ./scripts/load-mammals.sql

# check that tables are created and data is loaded
\dt
table species;
```