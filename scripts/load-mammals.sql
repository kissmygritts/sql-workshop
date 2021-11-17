BEGIN;

CREATE TABLE species (
  species_id text PRIMARY KEY,
  genus text,
  species text,
  taxa text
);

CREATE TABLE plots (
  plot_id int PRIMARY KEY,
  plot_type text
);

CREATE TABLE surveys (
  record_id int PRIMARY KEY,
  month int,
  day int,
  year int,
  plot_id int references plots(plot_id),
  species_id text references species(species_id),
  sex text,
  hindfoot_length real,
  weight real
);

\copy species from 'data/mammals/species.csv' with (format csv, header);
\copy plots from 'data/mammals/plots.csv' with (format csv, header);
\copy surveys from 'data/mammals/surveys.csv' with (format csv, header);

COMMIT;