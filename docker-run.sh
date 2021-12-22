#!/bin/bash

# Initialize the wiki
if [ ! -d .git ]; then
    git init
fi

# Start gollum service
[[ "$@" != *--mathjax* ]] && echo "WARNING: Mathjax will soon be disabled by default. To explicitly enable it, use --mathjax" >&2
exec gollum "$@ --mathjax"
