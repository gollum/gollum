#!/bin/bash

# Initialize the wiki
if [ ! -d .git ]; then
    git init
fi

# Start gollum service
exec gollum --mathjax $@
