#!/bin/bash
#
# Requires imagemagick.
#
# Example usage: bash ~/bin/convert-to-jpg.sh
#
# Thunar Action Setup
#
# Name: Convert to JPG
# Description: Convert PNG to JPG using ImageMagick
# Command: bash ~/bin/convert-to-jpg.sh %N
# Appearance Conditions
# File Pattern: *.png;*.PNG
# Appears if selection contains: Image Files 

# Process each file passed as argument
for the_file in "$@"; do
    output_file="${the_file%.*}.jpg"
    convert "$the_file" "$output_file"
done

