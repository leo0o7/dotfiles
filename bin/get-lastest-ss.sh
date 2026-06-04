#!/bin/bash

# Check if a new name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <new_filename_without_extension>"
  exit 1
fi

# Get the latest screenshot
latest_file=$(ls -Art ~/Documents_/Images/Screenshots/ | tail -n 1)

# Check if any files were found
if [ -z "$latest_file" ]; then
  echo "No screenshots found in ~/Documents_/Images/Screenshots/"
  exit 1
fi

# Extract the file extension from the latest screenshot
extension="${latest_file##*.}"

# Create the new filename with the same extension
new_filename="$1.$extension"

# Copy and rename the latest screenshot
cp ~/Documents_/Images/Screenshots/"$latest_file" "./$new_filename"
echo "Copied and renamed '$latest_file' to '$new_filename'"
