#!/bin/bash

# Function to find .vscode/settings.json
find_vscode_settings() {
    local current_dir="$1"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/.vscode/settings.json" ]]; then
            echo "$current_dir/.vscode/settings.json"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    return 1
}

# Function to remove project from settings.json
remove_from_settings() {
    local settings_file="$1"
    local project_path="$2"
    
    if [[ ! -f "$settings_file" ]]; then
        echo "Error: settings.json not found"
        return 1
    fi
    
    # Remove the project from the list
    jq --arg proj "$project_path" '."rust-analyzer.linkedProjects" -= [$proj]' "$settings_file" > "${settings_file}.tmp"
    mv "${settings_file}.tmp" "$settings_file"
    echo "Removed $project_path from rust-analyzer.linkedProjects"
}

# Get the project name
if [[ -z "$2" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: cargo delete <project_name>"
    exit 1
fi

project_name="$2"
current_dir=$(pwd)

# Find settings.json
settings_file=$(find_vscode_settings "$current_dir")
if [[ -z "$settings_file" ]]; then
    echo "Error: No .vscode/settings.json found in parent directories"
    exit 1
fi

# Get the relative path
settings_dir=$(dirname "$settings_file")
relative_path=$(realpath --relative-to="$settings_dir" "$current_dir")
project_path="$relative_path/$project_name/Cargo.toml"
project_path=$(echo "$project_path" | sed 's|^\.\./||')

# Remove from settings.json
remove_from_settings "$settings_file" "$project_path"

# Remove the project directory
if [[ -d "$project_name" ]]; then
    rm -rf "$project_name"
    echo "Removed project directory: $project_name"
else
    echo "Warning: Project directory not found: $project_name"
fi 