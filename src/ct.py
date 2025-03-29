#!/usr/bin/env python3
import sys
import subprocess
import os
import re
import argparse
from typing import Optional

def copy_to_clipboard(text: str) -> None:
    """Use xclip to copy text to X11 clipboard"""
    try:
        subprocess.run(
            ['xclip', '-selection', 'clipboard'],
            input=text.strip().encode('utf-8'),
            check=True
        )
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"Clipboard error: {e}\n")
        sys.exit(1)

def get_parent_command() -> Optional[str]:
    """Get the actual command preceding ct in the pipeline"""
    try:
        ppid = os.getppid()
        with open(f'/proc/{ppid}/cmdline', 'rb') as f:
            cmdline_parts = f.read().split(b'\x00')
        
        # Convert to strings and remove empty parts
        cmdline = [p.decode('utf-8') for p in cmdline_parts if p]
        
        # Find the -c argument that contains the pipeline command
        if '-c' in cmdline:
            cmd_index = cmdline.index('-c') + 1
            if cmd_index < len(cmdline):
                full_cmd = cmdline[cmd_index]
                # Extract everything before | ct
                clean_cmd = re.sub(r'\s*\|\s*ct.*$', '', full_cmd)
                return clean_cmd.strip()
        
        # Fallback for interactive shells without -c
        ps_output = subprocess.check_output(
            ['ps', '-p', str(ppid), '-o', 'args='],
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        # Remove shell prompt artifacts and ct references
        return re.sub(
            r'(^.*?\|\s*ct.*?$)|(^.*?└─\$[\s]*)|(^\s*\d+\s*)', 
            '', 
            ps_output
        ).strip()
        
    except Exception as e:
        sys.stderr.write(f"Command detection warning: {e}\n")
        return None

def main() -> None:
    parser = argparse.ArgumentParser(
        description='ct - Tee-like tool with clipboard integration',
        formatter_class=argparse.RawTextHelpFormatter,
        epilog="""Examples:
  echo 'test' | ct
  cat file.txt | ct -b
  seq 1 3 | ct -m"""
    )
    
    parser.add_argument('-b', '--both', action='store_true',
                       help='Copy both command and output')
    parser.add_argument('-c', '--command-only', action='store_true',
                       help='Copy only the executed command')
    parser.add_argument('-m', '--markdown-inline', action='store_true',
                       help='Format as markdown inline code (`text`)')
    parser.add_argument('-M', '--markdown-block', action='store_true',
                       help='Format as markdown code block (```text```)')
    
    args = parser.parse_args()
    
    if sys.stdin.isatty():
        parser.print_help()
        return
        
    input_text = sys.stdin.read().strip()
    
    output = ""
    
    if args.command_only:
        cmd = get_parent_command() or "[command not detected]"
        output = cmd
    elif args.both:
        cmd = get_parent_command() or "[command not detected]"
        output = f"Command:\n{cmd}\n\nOutput:\n{input_text}"
    else:
        output = input_text
        
    if args.markdown_inline:
        output = f"`{output}`"
    elif args.markdown_block:
        output = f"```\n{output}\n```"
        
    copy_to_clipboard(output)
    print(input_text)

if __name__ == "__main__":
    main()