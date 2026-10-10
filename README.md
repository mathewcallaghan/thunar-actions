# Thunar Custom Actions

A curated collection of shell scripts designed to extend the [Thunar File Manager](https://docs.xfce.org/xfce/thunar/custom-actions) via **Custom Actions**. These scripts bring fast, desktop-integrated workflows for audio inspection, image conversion, metadata editing, and batch processing.

---

## Prerequisites & Dependencies

You can install all dependencies required across all scripts using apt:

    sudo apt update && sudo apt install -y \
        ffmpeg \
        imagemagick \
        libimage-exiftool-perl \
        gimp \
        jpegoptim \
        zip

---

## Installation & Setup

1. **Clone or download the repository:**

    git clone https://github.com/<your-username>/<your-repo-name>.git
    cd <your-repo-name>

2. **Copy scripts to your local user executable path:**
   The action commands default to looking in ~/bin/. Create the directory and copy the scripts:

    mkdir -p ~/bin
    cp Audio/*.sh Graphics/*.sh ~/bin/
    chmod +x ~/bin/*.sh

3. **Configure in Thunar:**
   * Open **Thunar**.
   * Go to **Edit** -> **Configure custom actions...**
   * Click the **+** (Add) icon to create an action using the parameters listed below.

---

## Available Actions

### Audio

#### 1. View Spectrogram (Audio/spectrogram.sh)
Generates a Spek-style audio frequency spectrogram with dynamic range in dBFS, linear frequency scale, and a header displaying technical metadata (codec, duration, sample rate, bit depth, and bitrate). Automatically opens in your system's default image viewer and cleans up on close.

* **Dependencies:** ffmpeg, imagemagick
* **Name:** View Spectrogram
* **Description:** Generate and view audio spectrogram with technical details
* **Command:** bash ~/bin/spectrogram.sh %F
* **Appearance Conditions:**
  * **File Pattern:** *
  * **Appears if selection contains:** Audio Files

---

### Graphics

#### 1. Convert to JPG (Graphics/convert-to-jpg.sh)
Batch converts selected PNG images to JPG format using ImageMagick.

* **Dependencies:** imagemagick
* **Name:** Convert to JPG
* **Description:** Convert PNG to JPG using ImageMagick
* **Command:** bash ~/bin/convert-to-jpg.sh %N
* **Appearance Conditions:**
  * **File Pattern:** *.png;*.PNG
  * **Appears if selection contains:** Image Files

#### 2. Create / Set EXIF Date (Graphics/exif.sh)
Launches a terminal dialog allowing you to set or update DateTimeOriginal and ModifyDate for selected images to either today's date or a custom YYYY:MM:DD date.

* **Dependencies:** libimage-exiftool-perl, xfce4-terminal
* **Name:** Create EXIF date
* **Description:** Set / change EXIF date for images
* **Command:** xfce4-terminal --title "Set EXIF Date" --command "bash ~/bin/exif.sh %F"
* **Appearance Conditions:**
  * **File Pattern:** *
  * **Appears if selection contains:** Image Files

#### 3. Create XCF Thumbnail (Graphics/generate_xcf_thumbnail.sh)
Renders a 256x256 preview thumbnail from native GIMP .xcf project files using headless GIMP and ImageMagick.

* **Dependencies:** gimp, imagemagick
* **Name:** Create XCF Thumbnail
* **Description:** Generate a thumbnail for XCF files
* **Command:** bash ~/bin/generate_xcf_thumbnail.sh %F
* **Appearance Conditions:**
  * **File Pattern:** *.xcf
  * **Appears if selection contains:** Image Files

#### 4. Watermark Images (Graphics/watermark.sh)
Scales images to 1000x1000, centers an overlay watermark image, and optimizes output JPEG quality using jpegoptim.

* **Dependencies:** imagemagick, jpegoptim
* **Name:** Watermark Images
* **Description:** Apply watermark to images
* **Command:** bash ~/bin/watermark.sh %F '/path/to/watermark.png'
* **Appearance Conditions:**
  * **File Pattern:** *
  * **Appears if selection contains:** Image Files

---

## Repository Maintenance

The repository contains an update.sh helper script. Whenever you modify or add a new .sh script, run:

    ./update.sh

This will automatically create a standalone .zip archive for each script within its respective directory for distribution.

---

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0). See the LICENSE file for details.
