#!/bin/bash

# Create a new detached tmux session named "gemini"
tmux new-session -d -s gemini

# Define the path for the script and the temp file for communication
# Using an absolute path makes the script runnable from anywhere
MONITOR_SCRIPT_PATH="/home/rchennau/scripts/gemini_monitor.sh"
COMMAND_LOG_FILE="/tmp/gemini_cli_last_command"

# Ensure the command log file exists
touch "$COMMAND_LOG_FILE"

# Split the window vertically
tmux split-window -v -l 65%

# --- Top Pane (Gemini Monitor) ---
tmux select-pane -t 0
# Make sure the monitor script is executable
chmod +x "$MONITOR_SCRIPT_PATH"
# Run the monitor script in the top pane
tmux send-keys -t 0 "bash $MONITOR_SCRIPT_PATH" C-m

# --- Bottom Pane (User Input) ---
tmux select-pane -t 1
# Set a custom, simple prompt for the bottom pane
tmux send-keys -t 1 "export PS1='[\w] \$ '" C-m
# Set PROMPT_COMMAND to reliably capture the last command executed
# This writes the last command from history to our log file, ready for the monitor to read
tmux send-keys -t 1 "export PROMPT_COMMAND='history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" > \"$COMMAND_LOG_FILE\"'" C-m
tmux send-keys -t 1 'clear' C-m

# Attach to the newly created session
tmux attach-session -t gemini
