#!/usr/bin/env bash

# Load environment variables
set -a
source .env
set +a

# Check required fields
if [[ -z "$GITLAB_API_URL" || -z "$GITLAB_PROJECT_ID" || -z "$GITLAB_TOKEN" ]]; then
  echo "❌ ERROR: GITLAB_API_URL, GITLAB_PROJECT_ID, or GITLAB_TOKEN is missing in .env"
  exit 1
fi

echo "🧹 Deleting variables from GitLab project ID: $GITLAB_PROJECT_ID"

# Loop through each variable in the .env file
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Skip reserved keys
  if [[ "$key" == "GITLAB_API_URL" || "$key" == "GITLAB_PROJECT_ID" || "$key" == "GITLAB_TOKEN" ]]; then
    continue
  fi

  echo "❌ Deleting variable: $key"

  # GitLab delete API
  curl --silent --show-error --fail --request DELETE "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables/$key" \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN"

done < <(grep -v '^#' .env | grep '=')

echo "✅ All listed variables removed."
