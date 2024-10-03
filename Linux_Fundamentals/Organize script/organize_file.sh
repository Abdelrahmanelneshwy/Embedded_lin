#!/bin/bash

# Check if directory path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Directory to organize
DIR="$1"

# Check if the provided path is a valid directory
if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a valid directory."
    exit 1
fi

# Organize files
for file in "$DIR"/*; do
    # Skip directories, hidden files, and special files (like symlinks)
    if [ -d "$file" ] || [ "${file##*/}" == ".*" ] || [ ! -f "$file" ]; then
        continue
    fi

    # Get the file extension
    ext="${file##*.}"

    # Handle files with no extension
    if [ "$ext" == "$file" ]; then
        ext="misc"
    fi

    # Convert extension to lowercase to avoid case-sensitive directory creation
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # Create directory if it doesn't exist
    mkdir -p "$DIR/$ext"

    # Move file to the respective subdirectory
    mv "$file" "$DIR/$ext/"
done

echo "Files organized successfully in $DIR."

