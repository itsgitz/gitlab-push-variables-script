#!/usr/bin/env bash

# Load environment variables from .env
set -a
source .env
set +a

# Validate required variables
if [[ -z "$GITLAB_API_URL" || -z "$GITLAB_PROJECT_ID" || -z "$GITLAB_TOKEN" ]]; then
  echo "❌ ERROR: GITLAB_API_URL, GITLAB_PROJECT_ID, or GITLAB_TOKEN is missing in .env"
  exit 1
fi

echo "📤 Uploading variables to GitLab project ID: $GITLAB_PROJECT_ID"

# Loop through each variable except the control ones
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Skip reserved keys
  if [[ "$key" == "GITLAB_API_URL" || "$key" == "GITLAB_PROJECT_ID" || "$key" == "GITLAB_TOKEN" ]]; then
    continue
  fi

  # Remove surrounding quotes from value
  clean_value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')

  echo "🔧 Setting variable: $key"

  curl --silent --show-error --fail --request POST "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables" \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --form "key=$key" \
    --form "value=$clean_value" \
    --form "masked=false" \
    --form "protected=false"

done < <(grep -v '^#' .env | grep '=')

echo "✅ All variables uploaded."
