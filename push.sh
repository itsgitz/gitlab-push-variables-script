#!/usr/bin/env bash

# Config
API_URL="https://gitlab.com/api/v4"
PROJECT_ID="your_project_id"
TOKEN="your_access_token"

# Load .env variables
set -a
source .env
set +a

# Loop through each variable in the .env file
while IFS='=' read -r key value; do
  # Skip empty lines and comments
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Remove surrounding quotes from value if any
  clean_value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')

  echo "Uploading variable: $key"

  curl --silent --show-error --fail --request POST "$API_URL/projects/$PROJECT_ID/variables" \
    --header "PRIVATE-TOKEN: $TOKEN" \
    --form "key=$key" \
    --form "value=$clean_value" \
    --form "masked=false" \
    --form "protected=false"

done < <(grep -v '^#' .env | grep '=')

echo "All variables uploaded."
