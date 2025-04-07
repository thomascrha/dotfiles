#!/usr/bin/env bash

set -eo pipefail

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age encryption tool is not installed"
    echo "Please install it from https://github.com/FiloSottile/age"
    exit 1
fi

# Check if argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

# Get the input folder and convert to absolute path if needed
INPUT_FOLDER=$(readlink -f "$1")

# Check if the folder exists
if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: '$INPUT_FOLDER' is not a valid directory"
    exit 1
fi

# Get hostname and create target directory structure
HOSTNAME=$(hostname)
FOLDER_BASENAME=$(basename "$INPUT_FOLDER")
TARGET_DIR="${HOSTNAME}${INPUT_FOLDER}"

# Create the target directory
mkdir -p "$TARGET_DIR"

# Create temporary tar file
TAR_FILE="/tmp/${FOLDER_BASENAME}.tar.gz"
ENCRYPTED_FILE="${TARGET_DIR}/${FOLDER_BASENAME}.tar.gz.age"

echo "Creating tar archive of '$INPUT_FOLDER'..."
tar -czpf "$TAR_FILE" -C "$(dirname "$INPUT_FOLDER")" "$(basename "$INPUT_FOLDER")"

echo "Enter password for encryption: "
age --encrypt --passphrase -o "$ENCRYPTED_FILE" "$TAR_FILE"

# Clean up
rm "$TAR_FILE"

echo "Successfully encrypted '$INPUT_FOLDER' to '$ENCRYPTED_FILE'"
echo "Encryption complete!"

