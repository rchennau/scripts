#!/bin/bash

# This script monitors the command executed in the bottom tmux pane
# and provides suggestions using the Gemini API.

echo "Gemini Command Monitor"
echo "------------------------"
echo "This pane monitors your commands in the pane below."
echo "After you execute a command, Gemini will provide a tip here."
echo ""

# Check if inotify-tools is installed, as it's required for efficient monitoring
if ! command -v inotifywait &> /dev/null; then
    echo "Error: 'inotifywait' not found."
    echo "Please install 'inotify-tools' to use this script."
    echo "On Debian/Ubuntu: sudo apt-get install inotify-tools"
    echo "On Fedora/CentOS: sudo yum install inotify-tools"
    exit 1
fi

COMMAND_LOG_FILE="/tmp/gemini_cli_last_command"
COMMAND_HISTORY_FILE="/tmp/gemini_cli_history"
HISTORY_LENGTH=10
LAST_COMMAND=""

# --- System Context ---
# Modify these variables to match your environment
OS="linux"
SHELL="bash"
DISTRO="Ubuntu"
# --------------------

# Function to get a tip from Gemini
get_gemini_tip() {
    local cmd_text="$1"
    local history_context
    if [[ -f "$COMMAND_HISTORY_FILE" ]]; then
        history_context=$(cat "$COMMAND_HISTORY_FILE")
    fi

    # Construct a prompt for the Gemini API.
    # The goal is to review for syntax accuracy and provide technical enhancements.
    local prompt="You are an expert in the $OS operating system, specifically the $DISTRO distribution, and the $SHELL shell. The user has the following command history for context:\n$history_context\n\nReview the following new shell command for syntax accuracy and suggest brief technical enhancements. Disallow generation of audio, video, or images. Ensure the output is technical, succinct, and minimal: `$cmd_text`"

    # Call the Gemini API, trying the cheapest model first.
    local tip
    tip=$(gemini --model gemini-1.5-flash-latest --prompt "$prompt")
    
    # If the free tier fails, switch to the paid tier.
    if [[ $? -ne 0 ]]; then
        tip=$(gemini --model gemini-1.5-pro-latest --prompt "$prompt")
    fi
    
    if [[ -n "$tip" ]]; then
        echo "Gemini Tip for '$cmd_text':"
        echo "$tip"
        echo "-----------------------------------------------------------------"
    fi
}

# Main monitoring loop
# inotifywait efficiently waits for the log file to be written to
while inotifywait -q -e modify "$COMMAND_LOG_FILE"; do
    # Read the last command from the log file
    current_command=$(cat "$COMMAND_LOG_FILE")

    # If the command is new and not empty, get a tip for it
    if [[ -n "$current_command" && "$current_command" != "$LAST_COMMAND" ]]; then
        get_gemini_tip "$current_command"
        LAST_COMMAND="$current_command"

        # Add command to history and trim the history file
        echo "$current_command" >> "$COMMAND_HISTORY_FILE"
        tail -n "$HISTORY_LENGTH" "$COMMAND_HISTORY_FILE" > "${COMMAND_HISTORY_FILE}.tmp" && mv "${COMMAND_HISTORY_FILE}.tmp" "$COMMAND_HISTORY_FILE"
    fi
done
