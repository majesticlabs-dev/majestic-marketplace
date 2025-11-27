#!/bin/bash
# Celebration hook for Claude Code
# Triggers Raycast confetti when Claude completes a task
#
# Requirements:
#   - macOS
#   - Raycast (https://raycast.com)
#
# Fails silently if Raycast is not installed

open "raycast://extensions/raycast/raycast/confetti" 2>/dev/null || true
