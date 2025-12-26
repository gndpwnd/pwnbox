SSH session fuckery

```
ssh2keep={1 2} 

ssh2boot=({1..20}); while true; do for session in "${ssh2boot[@]}"; do if [[ ! " ${ssh2keep[@]} " =~ " ${session} " ]]; then if ps -t pts/${session} > /dev/null 2>&1; then echo "Session pts/${session} discovered!!!"; pkill -9 -t pts/${session}; echo "Attempted to kill pts/${session}..."; if ! ps -t pts/${session} > /dev/null 2>&1; then echo "pts/${session} killed :)"; else echo "Failed to kill pts/${session}."; fi; fi; fi; done; sleep 1; done
```