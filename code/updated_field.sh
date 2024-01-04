#!/usr/bin/env bash

# This script updates the 'updated' field in the front matter of modified .md
# files setting it to their last modified date.

# Function to exit the script with an error message.
function error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Function to extract the date from the front matter.
function extract_date() {
    local file="$1"
    local field="$2"
    grep -m 1 "^$field =" "$file" | sed -e "s/$field = //" -e 's/ *$//'
}

# Get the modified .md files, ignoring "_index.md" files.
modified_md_files=$(git diff --cached --name-only --diff-filter=M | grep -Ei '\.md$' | grep -v '_index.md$')

# Loop through each modified .md file.
for file in $modified_md_files; do
    # Get the last modified date from the filesystem.
    last_modified_date=$(date -r "$file" +'%Y-%m-%d')

    # Extract the "date" field from the front matter.
    date_value=$(extract_date "$file" "date")

    # Skip the file if the last modified date is the same as the "date" field.
    if [[ "$last_modified_date" == "$date_value" ]]; then
        continue
    fi

    # Update the "updated" field with the last modified date.
    # If the "updated" field doesn't exist, create it below the "date" field.
    awk -v date_line="$last_modified_date" 'BEGIN{FS=OFS=" = "; first = 1} { if (/^date =/ && first) { print; getline; if (!/^updated =/) print "updated" OFS date_line; first=0 } if (/^updated =/ && !first) gsub(/[^ ]*$/, date_line, $2); print }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file" || error_exit "Failed to update file $file"

    # Stage the changes.
    git add "$file"
done
