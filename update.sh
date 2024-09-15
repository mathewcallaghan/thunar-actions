#!/bin/bash

# Set the top directory (current directory by default)
TOP_DIR=$(pwd)

# Traverse all subdirectories in the top directory
for dir in */; do
    # Check if it is a directory
    if [[ -d "$dir" ]]; then
        # Traverse each file within the subdirectory
        for file in "$dir"*; do
            # Check if it's a regular file
            if [[ -f "$file" ]]; then
                # Get the filename without the path
                FILE_NAME=$(basename "$file")
                
                # Define the path for the zip file (in the same directory as the original file)
                ZIP_FILE="${dir}${FILE_NAME}.zip"
                
                # Move into the directory to zip the file without the path
                (
                    cd "$dir" || exit
                    zip "$FILE_NAME.zip" "$FILE_NAME"
                )

                # Check if zip was successful
                if [[ $? -eq 0 ]]; then
                    echo "Successfully zipped $file into ${ZIP_FILE}"
                else
                    echo "Error zipping $file"
                fi
            fi
        done
    fi
done

