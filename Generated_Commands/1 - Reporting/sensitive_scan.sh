#!/bin/bash

# Define patterns to search for sensitive content
PATTERNS=(
    "AccessKeyId"
    "SecretAccessKey"
    "Token"
)

# Output file to store sensitive data
PARENT_DIR="BOXLOCATION"
OUTPUT_FILE="${PARENT_DIR}/sensitive.md"

# Function to remove sensitive content from a file
remove_sensitive_content() {
    local file="$1"
    local pattern="$2"
    sed -i "/$pattern/00000-REDACTED-00000/d" "$file"
}

echo "Starting recursive scan for sensitive data..."

# Initialize output file
> "$OUTPUT_FILE"

# Search recursively for sensitive patterns
for pattern in "${PATTERNS[@]}"; do
    echo "Scanning for pattern: $pattern"

    # Use grep to find sensitive data
    matches=$(grep -rIn --color=always "$pattern" .)

    if [[ -n "$matches" ]]; then
        echo "Found sensitive content for pattern '$pattern':"
        echo "$matches"

        # Save matches to the output file
        echo -e "\nSensitive data for pattern '$pattern':" >> "$OUTPUT_FILE"
        grep -rIn "$pattern" . >> "$OUTPUT_FILE"

        # Remove sensitive content from the affected files
        while IFS= read -r match; do
            file=$(echo "$match" | cut -d: -f1)
            echo "Removing sensitive content from: $file"
            remove_sensitive_content "$file" "$pattern"
        done <<< "$(grep -rl "$pattern" .)"
    else
        echo "No sensitive content found for pattern '$pattern'."
    fi
done

echo -e "\nScan complete."
echo "Results have been saved to: $OUTPUT_FILE"
