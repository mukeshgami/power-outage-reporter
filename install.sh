#!/bin/bash
set -e

echo "⚡ Installing Power Outage Reporter..."

# Variables
INSTALL_DIR="/usr/local/bin/power-monitor"
DB_DIR="/var/lib/power-monitor"
DB_FILE="$DB_DIR/clock.db"

# Ensure dependencies
echo "📦 Installing dependencies (sqlite3, mailutils)..."
sudo apt-get update -y
sudo apt-get install -y sqlite3 mailutils msmtp

# Create directories
echo "📂 Creating directories..."
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$DB_DIR"

# Copy scripts (assuming scripts are in ./scripts)
echo "📄 Copying scripts..."
sudo cp scripts/freeze_clock.sh "$INSTALL_DIR/freeze_clock.sh"
sudo cp scripts/report_power_outage_sqlite.sh "$INSTALL_DIR/report_power_outage_sqlite.sh"
sudo chmod +x "$INSTALL_DIR"/*.sh

# Setup SQLite DB if missing
if [ ! -f "$DB_FILE" ]; then
    echo "🗄 Initializing SQLite database..."
    sudo sqlite3 "$DB_FILE" "CREATE TABLE outages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_alive TEXT,
        boot_time TEXT,
        report_time TEXT,
        duration_sec INTEGER
    );"
else
    echo "✅ SQLite DB already exists: $DB_FILE"
fi

# Copy systemd services
echo "⚙️ Installing systemd services..."
sudo cp systemd/freeze-clock.service /etc/systemd/system/
sudo cp systemd/report-power-outage.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable + start services
echo "🚀 Enabling services..."
sudo systemctl enable --now freeze-clock.service
sudo systemctl enable --now report-power-outage.service

echo "✅ Installation complete!"
echo
echo "Next steps:"
echo "1. Configure your SMTP in ~/.msmtprc (see README)."
echo "2. Test email: echo 'Test mail' | mail -s 'Test' you@example.com"
echo "3. Check logs: journalctl -u report-power-outage.service -b"
