#!/bin/bash

DB="/var/lib/power-monitor/clock.db"

# Ensure DB exists
if [ ! -f "$DB" ]; then
    sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS last_clock (id INTEGER PRIMARY KEY, timestamp TEXT);"
fi

# Run forever
while true; do
    NOW=$(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S IST')
    sqlite3 "$DB" "DELETE FROM last_clock;"
    sqlite3 "$DB" "INSERT INTO last_clock (id, timestamp) VALUES (1, '$NOW');"
    sleep 1
done
