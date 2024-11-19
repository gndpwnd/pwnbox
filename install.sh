#!/bin/bash

unset GREP_OPTIONS

script_location=$(find / -type f -name "gen_notes.sh" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
echo "alias pwnbox='bash ${script_location}'" >> ~/.bash_aliases
echo "alias pwnbox=\"bash ${script_location}\"" >> ~/.zshrc