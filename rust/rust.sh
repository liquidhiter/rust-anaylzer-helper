#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    echo "You can install it with: sudo apt-get install jq"
    exit 1
fi

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

# Function to update settings.json
update_settings_json() {
    local settings_file="$1"
    local new_project="$2"
    
    # Create .vscode directory if it doesn't exist
    mkdir -p "$(dirname "$settings_file")"
    
    # Create settings.json if it doesn't exist or is empty
    if [[ ! -f "$settings_file" ]] || [[ ! -s "$settings_file" ]]; then
        echo '{
    "rust-analyzer.linkedProjects": []
}' > "$settings_file"
    fi
    
    # Read the current settings and ensure it's valid JSON
    if ! jq empty "$settings_file" 2>/dev/null; then
        echo "Error: Invalid JSON in settings.json"
        exit 1
    fi
    
    # Debug: Print current JSON structure
    echo "Current JSON structure:"
    jq '.' "$settings_file"
    
    # Ensure rust-analyzer.linkedProjects array exists
    if ! jq -e '."rust-analyzer.linkedProjects"' "$settings_file" > /dev/null; then
        echo "Adding rust-analyzer.linkedProjects array..."
        jq '. + {"rust-analyzer.linkedProjects": []}' "$settings_file" > "${settings_file}.tmp"
        mv "${settings_file}.tmp" "$settings_file"
    fi
    
    # Check if the project is already in the list
    if ! jq -e --arg proj "$new_project" '."rust-analyzer.linkedProjects"[] | select(. == $proj)' "$settings_file" > /dev/null; then
        # Add the new project to the list
        echo "Adding new project to linkedProjects..."
        jq --arg proj "$new_project" '."rust-analyzer.linkedProjects" += [$proj]' "$settings_file" > "${settings_file}.tmp"
        mv "${settings_file}.tmp" "$settings_file"
        echo "Added $new_project to rust-analyzer.linkedProjects"
    else
        echo "Project $new_project already in rust-analyzer.linkedProjects"
    fi
    
    # Debug: Print final JSON structure
    echo "Final JSON structure:"
    jq '.' "$settings_file"
}

# Get the absolute path of the current directory
current_dir=$(pwd)

# Find the .vscode/settings.json file
settings_file=$(find_vscode_settings "$current_dir")

if [[ -z "$settings_file" ]]; then
    echo "No .vscode/settings.json found in parent directories"
    exit 1
fi

# Get the project name from the arguments
project_name=""
cargo_args=()
for arg in "$@"; do
    if [[ "$arg" != "--bin" && "$arg" != "--lib" && "$arg" != "new" ]]; then
        project_name="$arg"
    else
        cargo_args+=("$arg")
    fi
done

if [[ -z "$project_name" ]]; then
    echo "No project name provided"
    exit 1
fi

# Run the original cargo new command first
cargo "${cargo_args[@]}" "$project_name"

# Get the relative path from the settings.json directory to the new project
settings_dir=$(dirname "$settings_file")
relative_path=$(realpath --relative-to="$settings_dir" "$current_dir")

# Construct the project path and remove any ../ from the beginning
project_path="$relative_path/$project_name/Cargo.toml"
project_path=$(echo "$project_path" | sed 's|^\.\./||')

# Update the settings.json file
update_settings_json "$settings_file" "$project_path"
