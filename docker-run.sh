#!/bin/bash

# Check if /wiki directory exists and is writable
if [ ! -d "/wiki" ] || [ ! -w "/wiki" ]; then
  echo "Error: /wiki directory does not exist or is not writable. Adjust permissions to mapped host volume. Exiting ..."
  exit 1
else
  echo "The /wiki directory exists and is writable. Continuing ..."
fi

# Initialize the wiki
if [ ! -d .git ] && [ "$(git rev-parse  --is-bare-repository 2>/dev/null)" != "true" ]; then
    git init
fi

# Set git user.name and user.email
if [ ${GOLLUM_AUTHOR_USERNAME:+1} ]; then
	git config user.name "${GOLLUM_AUTHOR_USERNAME}"
fi
if [ ${GOLLUM_AUTHOR_EMAIL:+1} ]; then
	git config user.email "${GOLLUM_AUTHOR_EMAIL}"
fi

# Start gollum service
exec gollum $@
