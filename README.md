# cs2102-project-adazal

## Set up passwordless authentication for psql

1. Open `Program Files\PostgreSQL\14\data` (Windows, idk the Linux/MacOS equivalence)
2. Open `pg_hba.conf` file
3. Change all `METHOD` fields in the table to `trust`
4. Restart PSQL server by Services (Windows) -> postgresql... -> Right click and restart server

## Getting started

1. Go to `./Part_2` directory
2. Run `setup.sh` to setup the database
3. Run `run.sh` to connect to the database and run it
