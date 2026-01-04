#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati
# Check if TikTok usernames are taken or untaken

# Colors
nc="\e[0m"
green="\e[1;32m"
red="\e[1;31m"
yellow="\e[1;33m"
bold="\e[1m"
underline="\e[4m"

TAKEN_FILE="taken.txt"
UNTAKEN_FILE="untaken.txt"

# ASCII art banner
print_banner() {
    clear
    echo -e "${bold}"
    echo "         _       _           "
    echo " _ _ ___| |_ ___| |_ ___ ___ "
    echo "| | |   |  _| .'| '_| -_|   |"
    echo "|___|_|_|_| |__,|_,_|___|_|_|"
    echo -e "${nc}"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underline}@haithamaouati${nc}\n"
}

# Help
usage() {
    cat <<EOF
Usage:
  untaken -u <username>
  untaken -u <file.txt>

Options:
  -u, --username    Single username or file containing usernames
  -h, --help        Show this help message

EOF
    exit 0
}

# Dependency check
for cmd in curl grep; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${red}Error:${nc} $cmd is required but not installed."
        exit 1
    fi
done

print_banner

# Reset output files
> "$TAKEN_FILE"
> "$UNTAKEN_FILE"

# Argument parsing
if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--username)
            target="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${yellow}Unknown option:${nc} $1"
            usage
            ;;
    esac
done

if [[ -z "$target" ]]; then
    usage
fi

# Check for username
check_username() {
    local username="${1/@/}"
    local url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"

    source_code=$(curl -sL -A "Mozilla/5.0" "$url")

    if echo "$source_code" | grep -q '"uniqueId":"'"$username"'"'; then
        echo -e "@$username : ${red}TAKEN${nc}"
        echo "$username" >> "$TAKEN_FILE"
    else
        echo -e "@$username : ${green}UNTAKEN${nc}"
        echo "$username" >> "$UNTAKEN_FILE"
    fi
}

# Execution
if [[ -f "$target" ]]; then
    total=$(grep -cv '^\s*$' "$target")
    echo -e "${bold}Loaded $total usernames for checking${nc}\n"

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        check_username "$line"
    done < "$target"
else
    username="${target/@/}"
    echo -e "${bold}Checking username: @$username${nc}\n"
    check_username "$username"
fi

# Final counts
taken_count=$(wc -l < "$TAKEN_FILE")
untaken_count=$(wc -l < "$UNTAKEN_FILE")

echo
echo "Results saved:"
echo "  Taken   (${taken_count}) -> $TAKEN_FILE"
echo "  Untaken (${untaken_count}) -> $UNTAKEN_FILE"
echo
