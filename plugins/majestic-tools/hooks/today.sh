#!/usr/bin/env bash
set -euo pipefail

# Set your timezone (optional, e.g., UTC for consistency)
TZ=${TZ:-UTC}  # Or America/New_York, etc.

HUMAN=$(date +"%A, %Y-%m-%d %H:%M:%S %Z (%z)")
ISO=$(date -Iseconds)

printf "[CONTEXT] Current date/time: %s | ISO: %s\n" "$HUMAN" "$ISO"

