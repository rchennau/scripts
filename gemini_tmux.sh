#!/bin/bash

# Create a new detached tmux session named "gemini"
tmux new-session -d -s gemini

# Split the window vertically, creating a new pane below the current one.
# The new (bottom) pane will take 65% of the space, leaving the top pane with 35%.
tmux split-window -v -p 65

# Select the top pane (the original pane, which is now on top)
tmux select-pane -t 0

# Run the monitor script in the top pane.
# Make sure gemini_monitor.sh is executable.
tmux send-keys -t 0 'bash "/Users/rchennault/My Drive/gemini_monitor.sh"' C-m

# Focus on the bottom pane for the user to start working.
tmux select-pane -t 1

# Attach to the newly created session.
tmux attach-session -t gemini
