#!/bin/bash

TOKEN_FILE="token.txt"
TS_SCRIPT="main/index.ts"

# Check if the token file exists
if [ ! -f "$TOKEN_FILE" ]; then
  echo "Token file not found. Regenerating token..."
  npx ts-node $TS_SCRIPT
fi

# Read the token and expiration from the file
TOKEN_EXPIRATION=$(cat "$TOKEN_FILE")
ACCESS_TOKEN=$(echo "$TOKEN_EXPIRATION" | cut -d',' -f1)
EXPIRATION_DATE=$(echo "$TOKEN_EXPIRATION" | cut -d',' -f2)
CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Compare expiration with the current time
if [[ "$CURRENT_DATE" > "$EXPIRATION_DATE" ]]; then
  echo "Token expired. Regenerating token..."
  npx ts-node $TS_SCRIPT
  TOKEN_EXPIRATION=$(cat "$TOKEN_FILE")
  ACCESS_TOKEN=$(echo "$TOKEN_EXPIRATION" | cut -d',' -f1)
fi

# Output the valid access token
echo "Access Token: $ACCESS_TOKEN"


# Copy the access token to the clipboard
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # For Linux, use xclip or xsel
  echo -n "$ACCESS_TOKEN" | xclip -selection clipboard
  echo "Access token copied to clipboard."
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # For macOS, use pbcopy
  echo -n "$ACCESS_TOKEN" | pbcopy
  echo "Access token copied to clipboard."
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
  # For Windows (Git Bash), use clip
  echo -n "$ACCESS_TOKEN" | clip
  echo "Access token copied to clipboard."
else
  echo "Unsupported OS. Could not copy to clipboard."
fi