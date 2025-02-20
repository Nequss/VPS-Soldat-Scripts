#!/bin/bash

# Path to the highscore file
FILE_PATH="/home/nequs/soldatserver/soldatserver2.8.2_1.7.1/highscore.json"

# API endpoint
API_URL="https://your_url.com/api/upload"

# Function to upload the file using form-data
upload_file() {
    if [ -f "$FILE_PATH" ]; then
        echo "$(date): Uploading $FILE_PATH..."
        response=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$API_URL" \
            -F "file=@$FILE_PATH")

        if [ "$response" = "200" ]; then
            echo "$(date):  Upload successful!"
        else
            echo "$(date):  Upload failed with response code $response"
        fi
    else
        echo "$(date):  File not found!"
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