# ct - Clipboard Tee

A Python implementation of tee-like tool with clipboard integration for X11 systems.

## Features
- Copy output to clipboard 
- Markdown formatting of the copied output 
- X11 clipboard support via xclip

## Planned Features
- Capture parent command (WIP, I have no idea how to do this atm, feel free to open a PR if you think you might have a solution)
- Syntax highlighting for md code blocks 
- If able to capture parent command label (add a line above each code block) md codeblocks e.g  input/output or command/stdout (option for user defined labels ofc) 

## Installation
For debian based distros (apt)
```bash
sudo make install
```
If you are using a diffent packet manager install xclip with that packet manager then run the makefile 
