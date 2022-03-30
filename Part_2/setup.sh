#!/bin/bash

#Create project database
psql -U postgres -c "DROP DATABASE IF EXISTS "AdazalDatabase";"

#Set the value of variable
database="AdazalDatabase"
 
#Create database
createdb -U postgres AdazalDatabase

# Import .sql files into database
psql -d $database -U postgres -f schema.sql -f data.sql -f triggers.sql -f procedures.sql -f functions.sql

echo ##########################
echo ###displaying tables...###
echo ######################### #

#Check tables created
psql -d $database -U postgres -c "\d+"
 
#Print done
echo finished setting up, exiting.
echo 	use ' run.sh ' to run the database!
$SHELL