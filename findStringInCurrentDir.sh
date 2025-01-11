#!/bin/zsh

# Ask the user for the search string
read "search_string?Enter the search string: "

# Use fd to find only text files and execute rg on them. The --type f ensures files are matched, and we skip binary files.
fd --type f --exec zsh -c '
  # For each file, check if it is a text file
  file_type=$(file --mime "$1" | awk "{print \$2}")
  
  if [[ "$file_type" == text/* ]]; then
    rg --fixed-strings -i "$2" "$1" 2>/dev/null
  fi
' -- {} "$search_string" | \
fzf --preview 'echo {} | cut -d: -f1 | xargs -I % rg --color=always --line-number --fixed-strings -i -C 3 "%"' \
    --preview-window=up:40%:wrap --delimiter=':' --with-nth 1.. \
    --bind 'enter:execute(echo {} | cut -d: -f1 | xargs -I % rg --color=always --line-number --fixed-strings -i "%")'
