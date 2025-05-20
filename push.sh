#!/usr/bin/env bash

# Load environment variables from .env
set -a
source .env
set +a

# Validate required variables
if [[ -z "$API_URL" || -z "$PROJECT_ID" || -z "$TOKEN" ]]; then
  echo "❌ ERROR: API_URL, PROJECT_ID, or TOKEN is missing in .env"
  exit 1
fi

echo "📤 Uploading variables to GitLab project ID: $PROJECT_ID"

# Loop through each variable except the control ones
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Skip reserved keys
  if [[ "$key" == "API_URL" || "$key" == "PROJECT_ID" || "$key" == "TOKEN" ]]; then
    continue
  fi

  # Remove surrounding quotes from value
  clean_value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')

  echo "🔧 Setting variable: $key"

  curl --silent --show-error --fail --request POST "$API_URL/projects/$PROJECT_ID/variables" \
    --header "PRIVATE-TOKEN: $TOKEN" \
    --form "key=$key" \
    --form "value=$clean_value" \
    --form "masked=false" \
    --form "protected=false"

done < <(grep -v '^#' .env | grep '=')

echo "✅ All variables uploaded."
