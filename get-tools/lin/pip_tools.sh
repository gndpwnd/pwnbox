#!/bin/bash
python3 -m pip install --upgrade
pip_tools=(
"bloodhound"
"pipx"
"pyinstaller" 
"pynput==1.6.8"
)
pipx_tools=(
"Tib3rius/AutoRecon"
)
for tool in "${pip_tools[@]}"; do
	pip3 install ${tool}
done
source ~/.bashrc
for tool in "${pipx_tools[@]}"; do
        pipx install git+https://github.com/${tool}.git
done
