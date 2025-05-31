#!/bin/bash

# Function to wrap cargo commands
cargo() {
    if [[ "$1" == "new" ]]; then
        # Get the directory of this script
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        # Call our custom script with all arguments
        "$SCRIPT_DIR/rust.sh" "$@"
    elif [[ "$1" == "delete" ]]; then
        # Get the directory of this script
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        # Call our delete script with all arguments
        "$SCRIPT_DIR/cargo_delete.sh" "$@"
    else
        # Call the original cargo command for all other subcommands
        command cargo "$@"
    fi
}