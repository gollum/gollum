#!/bin/bash

# Initialize the wiki
if [ ! -d .git ]; then
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
[[ "$@" != *--mathjax* ]] && echo "WARNING: Mathjax will soon be disabled by default. To explicitly enable it, use --mathjax" >&2
exec gollum $@ --mathjax
