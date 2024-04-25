#!/bin/bash


# Authors:
# Muriki G. Yamanaka

# Objective: 
# Bash script to full copy a PostgreSQL database to a Clickhouse cluster
# It generates a file with commands to create a clickhouse database 
# with same schema as postgres and insertion commands

# Run Command
# clickhouse-client --queries-file distributed_database.sql --allow_experimental_object_type 1

# SETTINGS ======================================

# Postgres Settings
PGHOST="localhost"
PGPORT="5432"
PGDATABASE="tpch"
PGUSER="postgres"
PGPASSWORD="***"

# Clickhouse Settings
CHHOST="localhost"
CHPORT="9000"
CHDATABASE="ch_$PGDATABASE"
CHUSER="default"
CHCLUSTER="cluster_3S_1R"

# General Settings
QUERY_FILE="./distributed_database.sql"

# CODE ==========================================

# Get all database table names
TABLENAMES=$(psql -qAtX $PSQLFLAGS -d $PGDATABASE -h $PGHOST -p $PGPORT -U $PGUSER \
              -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public'")

# Create a file with the CREATE TABLE MergeTree statements
echo "CREATE DATABASE $CHDATABASE ON CLUSTER '$CHCLUSTER';" > $QUERY_FILE
echo "" >> $QUERY_FILE
for tabname in $TABLENAMES
do
  pg_dump --schema-only -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t $tabname |
          sed -n "/CREATE TABLE/,/);/p; /PRIMARY KEY/p"                           | # Take CREATE TABLE and PRIMARY KEY
          sed -z "s/);\n.*PRIMARY KEY/)\n ENGINE MergeTree()\n ORDER BY/g"        | # Change to "ENGINE MergeTree() ORDER BY"
          sed -z "s/CREATE TABLE.*(\n/CREATE TABLE $CHDATABASE.mt_$tabname (\n/g" | # Change schema and table to ch.mt<table>
          sed -z "s/(\n/ON CLUSTER '$CHCLUSTER' (\n/g" >> $QUERY_FILE               # Add "ON CLUSTER <cluster>"
  echo "" >> $QUERY_FILE
done

# Fix the data types
sed -i "s/ without time zone//g" $QUERY_FILE
sed -i "s/uuid/UUID/g" $QUERY_FILE

# Create the distributed tables
for tabname in $TABLENAMES
do
  echo "CREATE TABLE $CHDATABASE.$tabname ON CLUSTER '$CHCLUSTER' AS $CHDATABASE.mt_$tabname
  ENGINE = Distributed($CHCLUSTER, $CHDATABASE, mt_$tabname, rand());" >> $QUERY_FILE
  echo "" >> $QUERY_FILE
done

# Create insert statements
for tabname in $TABLENAMES
do
  echo "--INSERT INTO $CHDATABASE.$tabname SELECT * FROM postgresql('$PGHOST:$PGPORT', '$PGDATABASE', '$tabname', '$PGUSER', '$PGPASSWORD');" >> $QUERY_FILE
  echo "" >> $QUERY_FILE
done

