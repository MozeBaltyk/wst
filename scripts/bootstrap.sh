#!/bin/bash
LATEST_VERSION_URL="https://api.github.com/repos/alexellis/arkade/releases/latest"
DOWNLOAD_URL="https://github.com/alexellis/arkade/releases/download"

# Check if 'just' is installed
if ! command -v just &> /dev/null
then
    # Fetch the latest version from the GitHub API
    LATEST_VERSION=$(curl -s $LATEST_VERSION_URL | grep 'tag_name' | cut -d\" -f4)

    # Download and install arkade
    curl -sLO "${DOWNLOAD_URL}"/"${LATEST_VERSION}"/arkade
    chmod +x arkade && sudo mv arkade /usr/local/bin/

    # Use arkade to install 'just' and add it to the path
    arkade get just --quiet && export PATH=$PATH:$HOME/.arkade/bin/
fi

# Run the 'all' command with 'just'
just all
