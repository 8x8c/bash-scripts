#!/bin/bash

# This script renames all directories in the current folder sequentially,
# starting from 11 and incrementing upwards.

# Get a list of directories in the current folder
# - `find . -maxdepth 1 -type d` finds all directories in the current directory (excluding subdirectories)
# - `! -name "."` excludes the current directory itself from the list
# - `sort` ensures the folders are processed in a consistent order
folders=($(find . -maxdepth 1 -type d ! -name "." | sort))

# Set the starting number for renaming
start=11

# Loop through each folder and rename it
for folder in "${folders[@]}"; do
    # Check if the folder exists before renaming
    if [[ -d "$folder" ]]; then
        mv "$folder" "./$start"  # Rename the folder
        ((start++))  # Increment the counter for the next folder
    fi
done

# Print a confirmation message
echo "Folders have been renamed sequentially starting from 11."

# How to Use:
# 1. Save this script as rename_folders.sh
# 2. Give execution permissions: chmod +x rename_folders.sh
# 3. Run the script in the folder containing the directories: ./rename_folders.sh

