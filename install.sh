#!/bin/bash

unset GREP_OPTIONS

script_loc1=$(find / -type f -name "1-setup_pwnbox.sh" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
echo "alias pwnbox='bash ${script_loc1}'" >> ~/.bash_aliases
echo "alias pwnbox=\"bash ${script_loc1}\"" >> ~/.zshrc

script_loc2=$(find / -type f -name "2-pwnbox_gen_commands.sh" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
echo "alias pwnbox-gen-commands='bash ${script_loc2}'" >> ~/.bash_aliases
echo "alias pwnbox-gen-commands=\"bash ${script_loc2}\"" >> ~/.zshrc

echo "DONE!!!"