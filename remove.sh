#!/usr/bin/env bash

# Load environment variables
set -a
source .env
set +a

# Check required fields
if [[ -z "$API_URL" || -z "$PROJECT_ID" || -z "$TOKEN" ]]; then
  echo "❌ ERROR: API_URL, PROJECT_ID, or TOKEN is missing in .env"
  exit 1
fi

echo "🧹 Deleting variables from GitLab project ID: $PROJECT_ID"

# Loop through each variable in the .env file
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Skip reserved keys
  if [[ "$key" == "API_URL" || "$key" == "PROJECT_ID" || "$key" == "TOKEN" ]]; then
    continue
  fi

  echo "❌ Deleting variable: $key"

  # GitLab delete API
  curl --silent --show-error --fail --request DELETE "$API_URL/projects/$PROJECT_ID/variables/$key" \
    --header "PRIVATE-TOKEN: $TOKEN"

done < <(grep -v '^#' .env | grep '=')

echo "✅ All listed variables removed."
