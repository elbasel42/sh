#!/bin/bash
# Define the list of packages to check
# Check if command line arguments are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 package1 package2 package3 ..."
    echo "Example: $0 base-devel openssl zlib xz tk"
    exit 1
fi

# Use command line arguments as packages
packages=("$@")

# Print the header of the ASCII table
printf "+--------------+----------------+-----------+----------------+------------+\n"
printf "| Package Name | Package Version| Installed | Latest Version | Is Latest  |\n"
printf "+--------------+----------------+-----------+----------------+------------+\n"

# Loop through each package and check if it is installed and query the online repository for the latest version
for pkg in "${packages[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
        version=$(pacman -Q "$pkg" | awk '{print $2}')
        installed="y"
    else
        version="N/A"
        installed="n"
    fi
    latest_version=$(pacman -Si "$pkg" 2>/dev/null | grep '^Version' | awk -F': ' '{print $2}')
    if [ -z "$latest_version" ]; then
        latest_version="N/A"
    fi

    if [ "$installed" = "y" ] && [ "$version" = "$latest_version" ]; then
        is_latest="y ✅"
    else
        is_latest="n ❌"
    fi

    # Print the package information in table format
    printf "| %-12s | %-14s | %-9s | %-14s | %-10s |\n" "$pkg" "$version" "$installed" "$latest_version" "$is_latest"
done

# Print the table footer
printf "+--------------+----------------+-----------+----------------+------------+\n"
