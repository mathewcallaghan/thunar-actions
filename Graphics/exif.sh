#!/bin/bash

# Script to set EXIF date for an image file(s).
#
# Requires 'exiftool'.  Install with: sudo apt install libimage-exiftool-perl
#
# Name: Create EXIF date
# Description: Set / change EXIF date for images
# Command: xfce4-terminal --title "Set EXIF Date" --command "bash exif.sh %F"
# Appearance Conditions
# File Pattern: *
# Appears if selection contains: Image Files 


# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
  echo "Error: exiftool is not installed."
  echo "Please install it using: sudo apt install libimage-exiftool-perl"
  exit 1
fi

# Validate that at least one file exists and is a regular file.
if [ "$#" -eq 0 ]; then
  echo "Error: No files specified."
  exit 1
fi

# Prompt the user to input a new date or use today's date
read -p "Enter 'today' to use today's date or enter a new date (YYYY:MM:DD): " new_date

if [ "$new_date" == "today" ]; then
    # Get today's date in YYYY:MM:DD format
    new_date=$(date +'%Y:%m:%d')
else
    # Validate the date format using regex.
    if ! [[ "$new_date" =~ ^[0-9]{4}:[0-9]{2}:[0-9]{2}$ ]]; then
      echo "Error: Invalid date format. Please use YYYY:MM:DD."
      exit 1
    fi
fi

for image_file in "$@"; do
  # Check if the file exists and is a regular file.
  if [ ! -f "$image_file" ]; then
    echo "Warning: File '$image_file' does not exist or is not a regular file. Skipping..."
    continue
  fi

  # Construct the exiftool command. Add time to match exiftool's expected format.
  exiftool_command="exiftool -overwrite_original -DateTimeOriginal=\"$new_date 00:00:00\" -ModifyDate=\"$new_date 00:00:00\" \"$image_file\""

  # Execute the exiftool command and display the output.
  echo "Setting EXIF date for '$image_file' to $new_date..."
  eval "$exiftool_command"  # Use eval cautiously, but necessary here due to variable expansion.

  # Check the exit code of exiftool.
  if [ $? -eq 0 ]; then
    echo "EXIF date successfully updated for '$image_file'."
  else
    echo "Error: EXIF date update failed for '$image_file'."
  fi
done

exit 0
