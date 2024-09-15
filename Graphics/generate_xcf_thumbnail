#!/bin/bash
#
# Requires gimp, imagemagick.
#
# Example usage: bash ~/bin/generate_xcf_thumbnail file.xcf
#
# Thunar Action Setup
#
# Name: Create XCF Thumbnail
# Description: Generate a thumbnail for XCF files
# Command: bash ~/bin/generate_xcf_thumbnail %F
# Appearance Conditions
# File Pattern: *.xcf
# Appears if selection contains: Image Files 

# Process each file passed as argument
for xcf_file in "$@"; do
  # Ensure the file has a .xcf extension
  if [[ "$xcf_file" == *.xcf ]]; then
    # Use GIMP to export the XCF to JPG in non-interactive mode
    gimp -i -b "(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE \"$xcf_file\" \"$xcf_file\"))) \
                       (drawable (car (gimp-image-get-active-layer image)))) \
                      (gimp-file-save RUN-NONINTERACTIVE image drawable \"${xcf_file%.xcf}.jpg\" \"${xcf_file%.xcf}.jpg\") \
                      (gimp-image-delete image))" -b "(gimp-quit 0)"
    
    # Resize the exported image to 256x256 using ImageMagick
    if convert "${xcf_file%.xcf}.jpg" -resize 256x256 "${xcf_file%.xcf}.jpg"; then
      notify-send "Thumbnail created for $xcf_file"
    else
      notify-send "Failed to create thumbnail for $xcf_file"
    fi
  else
    echo "Skipping invalid XCF file: $xcf_file"
  fi
done
