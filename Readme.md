## Highscore Watcher Setup

This guide explains how to set up an automatic watcher that monitors changes in the Soldat server's highscore file and uploads them to the website.

### Prerequisites

- Linux server with systemd
- `curl` and `inotify-tools` installed
- Soldat server installed at `/home/nequs/soldatserver/soldatserver2.8.2_1.7.1/`

### Installation Steps

1. Create the watcher script:
```bash
sudo nano /usr/local/bin/highscore_watcher.sh
```

2. Add the following content to the script:
```bash
#!/bin/bash

# Configuration
FILE_PATH="/home/nequs/soldatserver/soldatserver2.8.2_1.7.1/highscore.json"
API_URL="https://your_url.com/api/upload"

# Upload function
upload_file() {
    if [ -f "$FILE_PATH" ]; then
        echo "$(date): Uploading $FILE_PATH..."
        response=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$API_URL" \
            -F "file=@$FILE_PATH")

        if [ "$response" = "200" ]; then
            echo "$(date): Upload successful!"
        else
            echo "$(date): Upload failed with response code $response"
        fi
    else
        echo "$(date): File not found!"
    fi
}

# Initial upload if file exists
[ -f "$FILE_PATH" ] && upload_file

# Watch for file modifications
echo "🔍 Watching $FILE_PATH for changes..."
inotifywait -m -e modify "$FILE_PATH" | while read -r directory events filename; do
    echo "$(date): 📄 Detected change in $filename"
    upload_file
done
```

3. Make the script executable:
```bash
sudo chmod +x /usr/local/bin/highscore_watcher.sh
```

4. Create a systemd service:
```bash
sudo nano /etc/systemd/system/highscore_watcher.service
```

5. Add the following service configuration:
```ini
[Unit]
Description=Watch highscore.json and upload on change
After=network.target

[Service]
ExecStart=/usr/local/bin/highscore_watcher.sh
Restart=always
RestartSec=5
User=nequs
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=/home/nequs/soldatserver/soldatserver2.8.2_1.7.1

[Install]
WantedBy=multi-user.target
```

6. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable highscore_watcher.service
sudo systemctl start highscore_watcher.service
```

### Verification

To check if the service is running properly:
```bash
sudo systemctl status highscore_watcher.service
```

To view the logs:
```bash
journalctl -u highscore_watcher.service -f
... (10 lines left)