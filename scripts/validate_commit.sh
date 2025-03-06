#!/bin/bash

# Get the commit message from the first argument
COMMIT_MSG="$1"

# Output commit message for debugging
echo "Commit message: '$COMMIT_MSG'"

# Define regex pattern for validation
PATTERN='^[A-Z]+-[0-9]+ .+$'

# Validate commit message format
if [[ $COMMIT_MSG =~ $PATTERN ]]; then
  echo "Commit message format is valid!"
else
  echo "Commit message format is incorrect!"
  echo "Expected format: {PROJECTCODE}-{WORKITEM} Your comment"
  exit 1  # Fails the pipeline
fi
