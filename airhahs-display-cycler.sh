#!/bin/bash
# ~/.local/bin/display-cycler.sh
# This script launches the main display script within a login shell environment
# to ensure all necessary environment variables are loaded.

# The '-l' flag makes bash act as a login shell.
bash -l -c "$HOME/.local/bin/airhahs-display-manager.sh $1 &> /tmp/airhahs-display-manager.log"
