#!/bin/bash
# Requires jpegoptim, imagemagick.
#
# Example usage: bash ~/bin/watermark.sh input1.png input2.jpg '~/watermark.png'
#
# Thunar Action Setup
#
# Command: bash ~/bin/watermark.sh %F '/path-to/watermark.png'
# Use Startup Notification: Checked
# Appearance Conditions
# File Pattern: *
# Appears if selection contains: Image Files

set -ex

# The last argument is the watermark image file.
WATERMARK_IMAGE="${@: -1}"

# Loop through all arguments except the last one.
for FILE in "${@:1:$#-1}"; do
    # Input filename and extension
    EXTENSION="${FILE##*.}"  # Extract extension from filename

    # Input filename without extension
    NAME="${FILE%.*}"

    # Target image size for resizing
    IMAGE_SIZE='1000x1000'

    # Construct a unique name with date and time
    NAME_DATE=$(basename "${NAME}")_$(date +"%d%m%Y%S")

    # Copy the original file to a new name with the determined extension
    cp "${FILE}" "${NAME_DATE}.${EXTENSION}"

    # Resize the copied image
    convert "${NAME_DATE}.${EXTENSION}" -resize "${IMAGE_SIZE}" -flatten "${NAME_DATE}.${EXTENSION}"

    # Apply watermark
    convert "${NAME_DATE}.${EXTENSION}" "${WATERMARK_IMAGE}" -gravity center -compose over -composite "${NAME_DATE}.jpg"

    # Optimise JPEG quality
    jpegoptim -s -m 90 "${NAME_DATE}.jpg"

    # Remove the intermediate processed file
    if [ "${EXTENSION,,}" != "jpg" ]; then
        rm "${NAME_DATE}.${EXTENSION}"
    fi
done

exit
