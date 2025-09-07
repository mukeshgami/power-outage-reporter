# ⚡ Power Outage Reporter for DietPi / Linux Servers

A lightweight monitoring system for **DietPi / Debian-based servers** that detects unexpected shutdowns (power outages, crashes, forced reboots), logs them in **SQLite**, and sends a **beautiful HTML email report** when the system comes back online.

---

## 🚀 Features
- ⏱ Tracks **last alive timestamp** before shutdown  
- 📊 Stores outage history in **SQLite database**  
- 📧 Sends modern, **mobile-friendly HTML email reports** via Gmail SMTP (or any SMTP server)  
- 🕒 Calculates estimated downtime duration  
- 📝 Includes possible causes + outage history  
- 🔧 Easy to install, lightweight, no heavy dependencies  

---

## 📦 Requirements
- DietPi / Debian / Ubuntu (systemd-based)  
- `sqlite3` (lightweight embedded database)  
- `mailutils` (for sending email)  
- A valid SMTP account (Gmail recommended)  

---

## 🔧 Installation

Clone this repository:

```bash
git clone https://github.com/YOUR_USERNAME/power-outage-reporter.git
cd power-outage-reporter
Update your email-id (Receiver mail-id) in scripts/report_power_outage_sqlite.sh file
```

Run the installer script:

```bash
chmod +x install.sh
sudo ./install.sh
```

The installer will:
1. Create required directories (`/var/lib/power-monitor/`)  
2. Set up the SQLite database (`clock.db`)  
3. Install systemd services:  
   - `freeze-clock.service` → logs current time every second  
   - `report-power-outage.service` → runs at boot to detect/report outage  
4. Configure email reporting  

---

## 📧 Email Setup (Gmail SMTP)

1. Install required packages:

   ```bash
   sudo apt install -y mailutils msmtp
   ```

2. Configure SMTP in `~/.msmtprc`:

   ```ini
   defaults
   auth on
   tls on
   tls_trust_file /etc/ssl/certs/ca-certificates.crt
   logfile ~/.msmtp.log

   account gmail
   host smtp.gmail.com
   port 587
   from YOUR_EMAIL@gmail.com
   user YOUR_EMAIL@gmail.com
   password YOUR_APP_PASSWORD

   account default : gmail
   ```

   ⚠️ Use a **Gmail App Password** (not your main password).  

---

## 📊 Usage

Check service status:

```bash
systemctl status freeze-clock.service
systemctl status report-power-outage.service
```

View logs:

```bash
journalctl -u freeze-clock.service -b
journalctl -u report-power-outage.service -b
```

Check recorded outages:

```bash
sqlite3 /var/lib/power-monitor/clock.db "SELECT * FROM outages ORDER BY id DESC LIMIT 5;"
```

---

## 📧 Example Email

![Example Email](https://dummyimage.com/600x400/f6f8fa/333&text=Power+Outage+Report+Template)

---

## 🛠 Troubleshooting

- **Email not sending?**  
  Run `echo "test" | mail -s "Test Email" you@example.com` to verify SMTP config.  

- **Services not starting?**  
  Run `sudo systemctl daemon-reload && sudo systemctl enable --now freeze-clock.service report-power-outage.service`.  

- **Last known alive empty?**  
  Ensure `freeze-clock.service` is running continuously.  

---

## 📅 Roadmap
- Add outage history table directly in email reports  
- Support for multiple recipients  
- Integration with monitoring dashboards (Grafana, Prometheus)  

---

## 📜 License
MIT License © 2025 Mukesh Gami
