#!/bin/bash

# GitHub API token
TOKEN=""

# Repository owner
OWNER="MikaelWeiss"

# Repository name
REPO="Strive"

# Initialize estimates
LOW=0
MID=0
HIGH=0

# Get list of issues
ISSUES=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$OWNER/$REPO/issues")
    
regex="\\[([0-9]+), ([0-9]+), ([0-9]+)\\]$"

extract_numbers() {
    if [[ $1 =~ $regex ]]; then
        LOW=$((LOW + ${BASH_REMATCH[1]}))
        MID=$((MID + ${BASH_REMATCH[2]}))
        HIGH=$((HIGH + ${BASH_REMATCH[3]}))
    fi
}

# Loop over each issue
for ISSUE in $(echo "$ISSUES" | jq -r '.[] | @base64'); do
    # Decode issue
    ISSUE=$(echo "$ISSUE" | base64 --decode)

    # Get issue title
    TITLE=$(echo "$ISSUE" | jq -r '.title')
    
    # Check if title contains estimates
    extract_numbers "$TITLE"
done

# Print overall estimates
echo "Low estimate: $LOW"
echo "Mid estimate: $MID"
echo "High estimate: $HIGH"
