#!/bin/bash

#Config
DB_NAME="RDBMS"
DB_USER="postgres"
JSON_FILE="task1_d.json"
CLEAN_FILE="clean.jsonl"
SQL_SCRIPT="transform.sql"

#Cleans Ruby Hash format and converts to valid JSON Lines using Python
echo "Cleaning invalid JSON data..."
python3 data_clean.py "$JSON_FILE" "$CLEAN_FILE"

#Create database
echo "Creating datase $DB_NAME..."
sudo -u "$DB_USER" createdb "$DB_NAME" || true

#Ingesting into database
echo "Ingesting JSON data..."
sudo -u "$DB_USER" psql -d "$DB_NAME" -c "DROP TABLE IF EXISTS raw_data CASCADE;"
sudo -u "$DB_USER" psql -d "$DB_NAME" -c "CREATE TABLE raw_data (data JSONB);"
sudo -u "$DB_USER" psql -d "$DB_NAME" -c "\copy raw_data FROM '$CLEAN_FILE';"

#Execute transformation script
echo "Running transformation script..."
sudo -u "$DB_USER" psql -d "$DB_NAME" -f "$SQL_SCRIPT"

echo "Task 1 completed. Summary table created."