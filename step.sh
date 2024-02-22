#!/bin/bash

# Function to check if a variable is empty
check_empty() {
  if [[ -z "$1" ]]; then
    echo "Error: $2 is required but not provided."
    exit 1
  fi
}

# Check mandatory inputs
check_empty "$from_branch" "From Branch"
check_empty "$to_branch" "To Branch"
check_empty "$pr_title" "Pull Request Title"
check_empty "$pr_body" "Pull Request Body"
check_empty "$github_token" "GitHub Token"
check_empty "$repo_name" "Repository Name"

# Construct JSON payload
PAYLOAD=$(cat <<EOF
{
  "title": "$pr_title",
  "body": "$pr_body",
  "head": "$from_branch",
  "base": "$to_branch"
}
EOF
)

# Send the request to create pull request
RESPONSE=$(curl -X POST \
    -H "Authorization: token $github_token" \
    -d "$PAYLOAD" \
    "https://api.github.com/repos/$repo_name/pulls")

# Check if the request was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create pull request."
    exit 1
fi

# Extract pull request URL from the response
PR_HTML_URL=$(echo "$RESPONSE" | jq -r '.html_url')

# Define color codes for terminal output
red=$'\e[31m'
green=$'\e[32m'
reset=$'\e[0m'

# Check if PR_HTML_URL is null or empty
if [[ -z "$PR_HTML_URL" || "$PR_HTML_URL" == "null" ]]; then
    echo "${red}Error:${reset} Pull request creation failed: $RESPONSE"
    exit 1
fi

# If PR_HTML_URL is not null or empty, consider it as success
envman add --key PR_HTML_URL --value "$PR_HTML_URL"
echo "${green}Pull request created:${reset} $PR_HTML_URL"
exit 0
