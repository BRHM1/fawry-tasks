#!/bin/bash

# mygrep.sh - A simplified version of grep without using grep

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE and print matching lines."
    echo
    echo "Options:"
    echo "  -n      Show line numbers for each match"
    echo "  -v      Invert the match (print lines that do not match)"
    echo "  --help  Display this help message and exit"
    exit 1
}

# Initialize option flags
show_line_numbers=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        --help)
            show_usage
            ;;
        -*)
            # Handle combined options (e.g., -nv, -vn)
            option="${1#-}"  # Remove the leading dash
            for ((i=0; i<${#option}; i++)); do
                case "${option:$i:1}" in
                    n)
                        show_line_numbers=true
                        ;;
                    v)
                        invert_match=true
                        ;;
                    *)
                        echo "Error: Invalid option: -${option:$i:1}"
                        show_usage
                        ;;
                esac
            done
            shift
            ;;
    esac
done

# Check if we have enough arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments"
    show_usage
fi

pattern="$1"
file="$2"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found"
    exit 1
fi

# Convert pattern to lowercase for case-insensitive matching
pattern_lower=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')

# Process the file
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Convert line to lowercase for case-insensitive comparison
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    # Check if the pattern is in the line (case-insensitive)
    if [[ "$line_lower" == *"$pattern_lower"* ]]; then
        match_found=true
    else
        match_found=false
    fi
    
    # Apply invert match if needed
    if [ "$invert_match" = true ]; then
        match_found=$([ "$match_found" = true ] && echo false || echo true)
    fi
    
    # Output the line if it matches our criteria
    if [ "$match_found" = true ]; then
        if [ "$show_line_numbers" = true ]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"
