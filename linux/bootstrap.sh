#!/usr/bin/bash

# Check if 'just' is installed
if ! command -v just &> /dev/null
then
    # Fetch the latest version of arkade from the GitHub API
    LATEST_VERSION_URL="https://api.github.com/repos/alexellis/arkade/releases/latest"
    DOWNLOAD_URL="https://github.com/alexellis/arkade/releases/download"
    LATEST_VERSION=$(curl -s $LATEST_VERSION_URL | grep 'tag_name' | cut -d\" -f4)
    curl -sLO "${DOWNLOAD_URL}"/"${LATEST_VERSION}"/arkade
    chmod +x arkade && mkdir -p $HOME/.local/bin
    mv arkade $HOME/.local/bin/
    export PATH=$PATH:$HOME/.local/bin/

    # Use arkade to install 'just' and add it to the path
    arkade get just --quiet && export PATH=$PATH:$HOME/.arkade/bin/
fi

# Run the 'all' command with 'just'
just all
