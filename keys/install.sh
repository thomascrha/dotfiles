#!/usr/bin/env bash

set -eo pipefail

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age encryption tool is not installed"
    echo "Please install it from https://github.com/FiloSottile/age"
    exit 1
fi

# Get hostname
HOSTNAME=$(hostname)
HOSTNAME_DIR="./$HOSTNAME"

# Check if hostname directory exists
if [ ! -d "$HOSTNAME_DIR" ]; then
    echo "Error: No directory found for hostname '$HOSTNAME'"
    echo "Expected to find: $HOSTNAME_DIR"
    exit 1
fi

echo "Found hostname directory: $HOSTNAME_DIR"
echo "Searching for encrypted files..."

# Find all .tar.gz.age files in the hostname directory
ENCRYPTED_FILES=$(find "$HOSTNAME_DIR" -type f -name "*.tar.gz.age")

if [ -z "$ENCRYPTED_FILES" ]; then
    echo "No encrypted files found in $HOSTNAME_DIR"
    exit 0
fi

# Process each encrypted file
for ENC_FILE in $ENCRYPTED_FILES; do
    echo "Processing: $ENC_FILE"
    
    # Calculate the target directory
    # The path will be from the hostname directory to the parent of the encrypted file
    REL_PATH=${ENC_FILE#"$HOSTNAME_DIR"}
    TARGET_DIR=$(dirname "$REL_PATH")
    
    # Get the filename without the .tar.gz.age extension
    FILENAME=$(basename "$ENC_FILE" .tar.gz.age)
    
    # Create a temporary file for decryption
    TEMP_TAR="/tmp/${FILENAME}.tar.gz"
    
    echo "Will extract to: $TARGET_DIR"
    
    # Decrypt the file
    echo "Decrypting $ENC_FILE..."
    age --decrypt -o "$TEMP_TAR" "$ENC_FILE"
    
    # Create target directory if it doesn't exist
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Creating directory: $TARGET_DIR"
        mkdir -p "$TARGET_DIR"
    fi
    
# Extract the tar file
    echo "Extracting to $TARGET_DIR..."
    tar -xzpf "$TEMP_TAR" -C "$TARGET_DIR" --strip-components=1
    
    # Clean up
    rm "$TEMP_TAR"
    
    echo "Successfully extracted $FILENAME to $TARGET_DIR"
    echo "----------------------------------------"
done

echo "Restoration complete!"

