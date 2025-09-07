#!/bin/bash

EMAIL="you@example.com" #***IMP*** REPLACE WITH YOUR MAIL-ID
HOSTNAME=$(hostname)
DB="/var/lib/power-monitor/clock.db"

NOW=$(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S IST')
BOOT_TIME=$(uptime -s | xargs -I{} date -d {} '+%Y-%m-%d %H:%M:%S IST')

LAST_CLOCK_TIME=$(sqlite3 "$DB" "SELECT timestamp FROM last_clock WHERE id=1;")

# Calculate duration (seconds + minutes)
if [ -n "$LAST_CLOCK_TIME" ]; then
    LAST_EPOCH=$(date -d "$LAST_CLOCK_TIME" +%s)
    BOOT_EPOCH=$(date -d "$BOOT_TIME" +%s)
    DURATION_SEC=$((BOOT_EPOCH - LAST_EPOCH))
    DURATION_MIN=$((DURATION_SEC / 60))
else
    DURATION_SEC=0
    DURATION_MIN=0
    LAST_CLOCK_TIME="Unknown"
fi

# Insert into outages table
sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS outages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_alive TEXT,
    boot_time TEXT,
    report_time TEXT,
    duration_sec INTEGER
);"

sqlite3 "$DB" "INSERT INTO outages (last_alive, boot_time, report_time, duration_sec)
VALUES ('$LAST_CLOCK_TIME', '$BOOT_TIME', '$NOW', $DURATION_SEC);"

# Build HTML email
SUBJECT="⚡ Power/Unexpected Reboot Detected on $HOSTNAME"

read -r -d '' MESSAGE <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
</head>
<body style="margin:0; padding:20px; background-color:#f6f8fa; font-family:Arial, sans-serif;">

  <div style="max-width:600px; margin:auto; background:#ffffff; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1); padding:20px;">
    <h2 style="text-align:center; color:#e63946; margin-top:0;">⚡ Power Outage Report</h2>

    <table role="presentation" style="width:100%; border-collapse:collapse; margin-top:15px;">
      <tr><td style="padding:10px; font-weight:bold; color:#555;">🖥️ Host</td><td style="padding:10px; color:#333;">$HOSTNAME</td></tr>
      <tr><td style="padding:10px; font-weight:bold; color:#555;">📅 Reported At</td><td style="padding:10px; color:#333;">$NOW</td></tr>
      <tr><td style="padding:10px; font-weight:bold; color:#555;">⏳ Last Known Alive</td><td style="padding:10px; color:#333;">$LAST_CLOCK_TIME</td></tr>
      <tr><td style="padding:10px; font-weight:bold; color:#555;">🔄 System Boot Time</td><td style="padding:10px; color:#333;">$BOOT_TIME</td></tr>
      <tr><td style="padding:10px; font-weight:bold; color:#555;">⏱️ Estimated Downtime</td><td style="padding:10px; color:#333;">~${DURATION_MIN} min (${DURATION_SEC} sec)</td></tr>
    </table>

    <h3 style="color:#333; margin-top:25px;">⚠️ Possible Causes</h3>
    <ul style="padding-left:20px; color:#444; line-height:1.5;">
      <li>Sudden power loss / blackout</li>
      <li>Forced reboot or kernel panic</li>
      <li>Unexpected shutdown</li>
    </ul>

    <div style="margin-top:25px; font-size:14px; color:#777; text-align:center;">
      <p style="margin:5px 0;"><span style="background:#e63946; color:#fff; padding:5px 10px; border-radius:5px; font-size:12px;">Power Monitor</span></p>
      <p style="margin:5px 0;">SQLite DB: <code style="background:#f0f0f0; padding:2px 4px; border-radius:4px;">$DB</code></p>
      <p style="margin:5px 0;">View history:<br>
        <code style="background:#f0f0f0; padding:2px 4px; border-radius:4px;">sqlite3 $DB "SELECT * FROM outages ORDER BY id DESC LIMIT 5;"</code>
      </p>
    </div>
  </div>

</body>
</html>
EOF

echo "$MESSAGE" | mail -a "Content-Type: text/html" -s "$SUBJECT" "$EMAIL"
