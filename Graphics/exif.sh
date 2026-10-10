#!/bin/bash

# Script to set EXIF date for an image file(s).
#
# Requires:
#   sudo apt install libimage-exiftool-perl libnotify-bin

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
  notify-send -u critical "EXIF Script Error" "exiftool is not installed. Please install 'libimage-exiftool-perl'."
  exit 1
fi

# Validate that files were passed
if [ "$#" -eq 0 ]; then
  notify-send -u critical "EXIF Script Error" "No files specified."
  exit 1
fi

# Prompt user for date
read -p "Enter 'today' to use today's date or enter a new date (YYYY:MM:DD): " new_date

if [ "$new_date" == "today" ]; then
    new_date=$(date +'%Y:%m:%d')
else
    if ! [[ "$new_date" =~ ^[0-9]{4}:[0-9]{2}:[0-9]{2}$ ]]; then
      notify-send -u critical "EXIF Script Error" "Invalid date format. Expected YYYY:MM:DD."
      exit 1
    fi
fi

timestamp="$new_date 00:00:00"
success_count=0
fail_count=0

for image_file in "$@"; do
  if [ ! -f "$image_file" ]; then
    ((fail_count++))
    continue
  fi

  # -m bypasses minor metadata warnings like recursive IFD0 pointers
  if exiftool -m -overwrite_original \
       -DateTimeOriginal="$timestamp" \
       -CreateDate="$timestamp" \
       -ModifyDate="$timestamp" \
       "$image_file" &> /dev/null; then
    ((success_count++))
  else
    ((fail_count++))
  fi
done

# Send system alert and exit immediately (terminal closes)
if [ "$fail_count" -eq 0 ]; then
  notify-send -i emblem-default "EXIF Tool" "Successfully updated $success_count file(s) to $new_date."
else
  # -u critical keeps the notification pinned until clicked/dismissed
  notify-send -u critical -i dialog-warning "EXIF Tool" "Done with warnings: $success_count updated, $fail_count failed."
fi

exit 0
