#!/bin/zsh

# Define colors and text attributes
autoload -U colors && colors
bold=$(tput bold)
normal=$(tput sgr0)
green=$fg[green]
red=$fg[red]
yellow=$fg[yellow]
blue=$fg[blue]

# Function to truncate long strings
truncate() {
  local str=$1
  local maxlen=$2
  if [[ ${#str} -gt $maxlen ]]; then
    echo "${str:0:$((maxlen-3))}..."
  else
    echo "$str"
  fi
}

# Function to parse URL and append descriptive pattern
format_url() {
  local url=$1
  local formatted_url pattern
  
  if [[ $url == git@ssh.dev.azure.com:* ]]; then
    # Extract the organization/project/repo details for Azure
    local details=${url#git@ssh.dev.azure.com:v3/}
    pattern="(azure: ${details})"
    formatted_url="${url} $pattern"
  elif [[ $url == git@github.com:* ]]; then
    # Extract the username/repo details for GitHub
    local details=${url#git@github.com:}
    pattern="(github: ${details})"
    formatted_url="${url} $pattern"
  else
    # Default case, no additional pattern
    pattern=""
    formatted_url="${url}"
  fi
  
  echo "$formatted_url|$pattern"  # Return formatted URL and pattern separately
}

# Get terminal width and add a margin for error
terminal_width=$(tput cols)
margin=10  # Reserve some margin for error (10 characters)
adjusted_width=$((terminal_width - margin))

# Set table column widths dynamically
# Reserve 20 characters for the "Push Result" column
push_result_width=20
remote_url_width=$((adjusted_width - push_result_width - 2))  # Adjust for spacing

# Get a list of all remotes
remotes=($(git remote))

# Check if remotes exist
if [[ -z $remotes ]]; then
  echo "${red}No remotes configured for this repository.${normal}"
  exit 1
fi

# Initialize a set to track unique URLs
typeset -A unique_urls

# Define table header
header="${bold}${blue}Remote URL${normal}$(printf ' %.0s' {1..$((remote_url_width - 8))})${bold}${blue}Push Result${normal}"
separator="${blue}$(printf '=%.0s' {1..$remote_url_width})  $(printf '=%.0s' {1..$push_result_width})${normal}"

# Print table header
echo -e "$header"
echo -e "$separator"

# Iterate over each remote
for remote in $remotes; do
  # Get the remote URL
  remote_url=$(git remote get-url "$remote")
  
  # Check if this URL has already been processed
  if [[ -n ${unique_urls[$remote_url]} ]]; then
    continue
  fi
  
  # Mark this URL as processed
  unique_urls[$remote_url]=1
  
  # Parse and format the URL
  formatted_result=$(format_url "$remote_url")
  full_url="${formatted_result%|*}"  # Extract the full formatted URL
  pattern="${formatted_result#*|}"   # Extract the descriptive pattern
  
  # Calculate truncation length
  max_url_length=$((remote_url_width - ${#pattern} - 1))  # Leave room for the pattern and a space
  
  # Truncate the URL if necessary
  truncated_url=$(truncate "$remote_url" "$max_url_length")
  display_url="$truncated_url $pattern"  # Combine truncated URL and pattern
  
  # Check if the branch exists locally
  if ! git show-ref --verify --quiet "refs/heads/main"; then
    result="${yellow}Branch 'main' does not exist locally${normal}"
  else
    # Attempt to push to the remote and capture the result
    push_output=$(git push --dry-run "$remote" main 2>&1)
    
    # Determine the result message
    if [[ $push_output == *"Everything up-to-date"* ]]; then
      result="${green}Everything up-to-date${normal}"
    elif [[ $push_output == *"new branch"* || $push_output == *"new tag"* ]]; then
      result="${yellow}New branch or tag pushed${normal}"
    elif [[ $push_output == *"rejected"* ]]; then
      result="${red}Push rejected${normal}"
    else
      result="${red}Unknown result${normal}"
    fi
  fi
  
  # Print the formatted output
  printf "%-${remote_url_width}s  %-${push_result_width}s\n" "$display_url" "$result"
done

