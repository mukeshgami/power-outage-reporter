#!/bin/bash

DB="/var/lib/power-monitor/clock.db"
DB_DIR="/var/lib/power-monitor"

# Ensure directory exists
mkdir -p "$DB_DIR"
chown root:root "$DB_DIR"
chmod 700 "$DB_DIR"

# Ensure DB and table exist (safe every run)
sqlite3 "$DB" <<'SQL'
PRAGMA journal_mode = WAL;
PRAGMA synchronous = FULL;
CREATE TABLE IF NOT EXISTS last_clock (
  id INTEGER PRIMARY KEY,
  timestamp TEXT NOT NULL
);
SQL

# Writer loop
while true; do
  NOW=$(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S IST')
  sqlite3 "$DB" "INSERT OR REPLACE INTO last_clock (id, timestamp) VALUES (1, '$NOW');"
  sleep 1
done
