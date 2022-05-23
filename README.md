
## About pwnbox

> **DISCLAIMER**
> Root privileges are used for the following functions:
> 1. Appending entries to /etc/hosts
> 2. Utilization of network interfaces

### Files and Folders

***pwnbox*** generates a file system optimized for easily taking and stashing notes while pwning a box.

### Commands 2 Run

***pwnbox*** creates a *cmds2run* folder in which syntax for many common tools is customized with variables and then echoed to files for easy use.
Future versions of ***pwnbox*** might include a script that runs these commands automagically.

For now, you can use *pwnbox-gen-commands* to generate commands manually.

- only an IP or a hostname is required
- you can run with both, and additionally add a /etc/hosts entry
- pwnbox does not automatically generate commands for hostnames yet. 

**Example Usage:**

```
pwnbox-gen-commands -d eth0 -i 10.10.10.1 -o ${HOME}/Documents/box_2_pwn/

pwnbox-gen-commands -d eth0 -n name.tld -o ${HOME}/Documents/box_2_pwn/

pwnbox-gen-commands -d eth0 -i 10.10.10.1 -n name.tld -o ${HOME}/Documents/box_2_pwn/
```

### Reporting 

**Report Template**

***pwnbox*** downloads a template, written in markdown, for speeding up the reporting process. ***pwnbox*** also creates a customized script of which can in turn be used to generate a pdf version of your completed markdown report. 

Quick Reference: [noraj's repo](https://github.com/noraj/OSCP-Exam-Report-Template-Markdown)

**Cleaning Up**

For even more conveniance, the generated reporting script will delete all empty files and folders clogging up your workspace filesystem. The script will only do so using the parent directory specified in the reporting script.

**Dependencies for Reporting:**

- [Pandoc](https://pandoc.org/installing.html)
- LaTex for pdflatex or xelates
- [Eisvogel Padoc LaTex PDF Template](https://github.com/Wandmalfarbe/pandoc-latex-template/blob/master/eisvogel.tex)
- [p7zip](http://p7zip.sourceforge.net/)

**Generating A Report**


1. write your report by editing the generated *box_name_report.md* file.
2. run *report_gen.sh* in the directory specified when running ***pwnbox***.
3. Run the following:

```
./report_gen.sh
```

## Basic pwnbox Usage

```
pwnbox <attacking_network_interface> <box_name> <box_ip> <report_template> <enable_AD> <wpscan_api_token>
```

**Example Usage:**

```
pwnbox -d eth0 -o testmachine -i 192.168.0.1

pwnbox -d eth0 -o testmachine -i 192.168.0.1 -r2

pwnbox -d tun0 -o machine_on_vpn -i 10.10.10.23 -r3 -w 123456789
```

## Install

All the install script does is add aliases.
NOTE: Recommended running install script as root.

**Usage:**

```
./install.sh
```

If needed, refresh your aliases...

```
source ~/.bash_aliases
source ~/.zshrc
```
## Setting up your pwning ENV variables

> This script opens the door for you to use your favorite pwn tools with simplified variables.

1. You will need to run *box_vars.sh* in each new terminal window you open.
2. This script is meant to be edited as you move further along pwning a box
3. You will need to run this script after making any changes in order to update env variables.


**Usage:**
```
. ./box_vars.sh
```