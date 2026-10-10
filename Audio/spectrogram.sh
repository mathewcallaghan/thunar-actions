#!/bin/bash
#
# Requires ffmpeg, imagemagick.
#
# Example usage: bash ~/bin/spectrogram.sh track1.flac track2.mp3
#
# Thunar Action Setup
#
# Name: View Spectrogram
# Description: Generate and view audio spectrogram with technical details
# Command: bash ~/bin/spectrogram.sh %F
# Appearance Conditions
# File Pattern: *
# Appears if selection contains: Audio Files

# --- Visual Preferences ---
COLOR="rainbow"  # Spek rainbow heat-map palette
DRANGE="90"      # Dynamic range in dBFS (Spek standard: 80-90 dB)
GAIN="1.5"       # Gain boost to illuminate high-frequency peaks
# --------------------------

# Check dependencies
if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
    command -v notify-send &> /dev/null && notify-send -u critical "Spectrogram Error" "ffmpeg/ffprobe is not installed."
    echo "Error: ffmpeg/ffprobe is not installed." >&2
    exit 1
fi

if ! command -v convert &> /dev/null; then
    command -v notify-send &> /dev/null && notify-send -u critical "Spectrogram Error" "imagemagick is not installed."
    echo "Error: imagemagick is not installed." >&2
    exit 1
fi

# Pick the best available image viewer
VIEWER=""
for app in ristretto viewnior feh loupe eog xdg-open; do
    if command -v "$app" &> /dev/null; then
        VIEWER="$app"
        break
    fi
done

# Process each file passed as argument
for filepath in "$@"; do
    [[ -f "$filepath" ]] || continue

    filename=$(basename -- "$filepath")

    # Isolated temp directory per file to prevent collisions
    path_hash=$(printf '%s' "$filepath" | md5sum | cut -c1-6)
    temp_dir="/tmp/spec_${path_hash}"
    mkdir -p "$temp_dir"
    output_img="${temp_dir}/${filename}.png"

    # 1. Extract audio metadata via ffprobe
    codec="" rate="" channels="" bits="" duration="" bitrate=""
    tag_artist="" tag_title=""

    while IFS='=' read -r key val; do
        case "$key" in
            codec_name)            codec="${val^^}" ;;
            sample_rate)           rate="${val} Hz" ;;
            channels)              channels="${val} ch" ;;
            bits_per_raw_sample)   [[ -n "$val" && "$val" != "0" && "$val" != "N/A" ]] && bits="${val} bit, " ;;
            tag:artist|tag:ARTIST) tag_artist="$val" ;;
            tag:title|tag:TITLE)   tag_title="$val" ;;
            duration)
                if [[ -n "$val" && "$val" != "N/A" ]]; then
                    secs="${val%.*}"
                    printf -v duration "%02d:%02d" "$((secs / 60))" "$((secs % 60))"
                fi
                ;;
            bit_rate)
                if [[ -n "$val" && "$val" != "N/A" ]]; then
                    bitrate="$((val / 1000)) kbps"
                fi
                ;;
        esac
    done < <(ffprobe -v error -select_streams a:0 \
        -show_entries stream=codec_name,sample_rate,channels,bits_per_raw_sample \
        -show_entries format=duration,bit_rate \
        -show_entries format_tags=artist,title \
        -of default=noprint_wrappers=1 "$filepath" 2>/dev/null)

    # 2. Format title and technical details
    display_name="$filename"
    if [[ -n "$tag_artist" && -n "$tag_title" ]]; then
        display_name="${filename}  [${tag_artist} - ${tag_title}]"
    fi
    if (( ${#display_name} > 85 )); then
        display_name="${display_name:0:82}..."
    fi

    tech_info="${duration:-00:00}  |  ${codec:-Audio}  |  ${rate:-}  |  ${bits}${channels:-}  |  ${bitrate:-}"

    # 3. Generate spectrogram with logarithmic amplitude (dBFS) and linear frequency
    FILTER="showspectrumpic=s=1280x640:legend=1:scale=log:fscale=lin:color=${COLOR}:drange=${DRANGE}:gain=${GAIN}"

    if ffmpeg -y -v error -i "$filepath" -lavfi "$FILTER" "$output_img"; then
        # 4. Add Spek-style black header banner across the top using ImageMagick
        convert "$output_img" -gravity North -background black -splice 0x55 \
            -gravity NorthWest -fill white -pointsize 15 \
            -annotate +20+10 "$display_name" \
            -fill '#aaaaaa' -pointsize 13 \
            -annotate +20+32 "$tech_info" \
            "$output_img"

        # 5. Launch viewer and auto-delete temp directory on window close
        (
            "$VIEWER" "$output_img" >/dev/null 2>&1
            rm -rf "$temp_dir"
        ) &
    else
        rm -rf "$temp_dir"
        command -v notify-send &> /dev/null && notify-send -u critical "Spectrogram Failed" "Could not parse: $filename"
    fi
done

exit 0
