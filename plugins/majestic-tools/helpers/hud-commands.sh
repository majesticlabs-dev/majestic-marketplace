#!/bin/bash
# hud-commands.sh - Render all majestic-marketplace commands in a HUD format
#
# Usage: bash hud-commands.sh [--plugin PLUGIN] [--group STYLE]
#   --plugin PLUGIN  Filter to specific plugin (e.g., majestic-engineer)
#   --group STYLE    Grouping style: plugin (default), category, flat

# Get script directory and marketplace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PLUGINS_DIR="$MARKETPLACE_ROOT/plugins"

# Parse arguments
FILTER_PLUGIN=""
GROUP_STYLE="plugin"

while [[ $# -gt 0 ]]; do
    case $1 in
        --plugin)
            FILTER_PLUGIN="$2"
            shift 2
            ;;
        --group)
            GROUP_STYLE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# ANSI colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
MAGENTA='\033[35m'

# Box drawing characters
BOX_TL='┌'
BOX_TR='┐'
BOX_BL='└'
BOX_BR='┘'
BOX_H='─'
BOX_V='│'
BOX_VL='├'
BOX_VR='┤'

# Get terminal width (default 100 if not available)
TERM_WIDTH=${COLUMNS:-100}
if [[ $TERM_WIDTH -gt 120 ]]; then
    TERM_WIDTH=120
fi

# Calculate column widths
CMD_COL_WIDTH=35
DESC_COL_WIDTH=$((TERM_WIDTH - CMD_COL_WIDTH - 7))

# Function to extract value from YAML frontmatter
extract_frontmatter() {
    local file="$1"
    local key="$2"

    # Extract frontmatter between --- markers
    awk '/^---$/{if(f)exit;f=1;next}f' "$file" 2>/dev/null | \
        grep -E "^${key}:" | \
        sed "s/^${key}:[[:space:]]*//" | \
        sed 's/^["'"'"']//' | \
        sed 's/["'"'"']$//' | \
        head -1
}

# Function to get command name from file
get_command_name() {
    local file="$1"
    local plugin="$2"
    local rel_path="$3"

    # First check for explicit name in frontmatter
    local explicit_name
    explicit_name=$(extract_frontmatter "$file" "name")

    if [[ -n "$explicit_name" ]]; then
        echo "/$explicit_name"
        return
    fi

    # Derive from path: category:command (without plugin prefix)
    local cmd_name
    cmd_name=$(basename "$file" .md)

    # Get category from path (if any subdirectory)
    local category
    category=$(dirname "$rel_path" | sed 's|^commands/||' | tr '/' ':')

    if [[ "$category" == "." || "$category" == "commands" ]]; then
        echo "/$cmd_name"
    else
        echo "/$category:$cmd_name"
    fi
}

# Function to truncate string with ellipsis
truncate() {
    local str="$1"
    local max_len="$2"

    if [[ ${#str} -gt $max_len ]]; then
        echo "${str:0:$((max_len-3))}..."
    else
        echo "$str"
    fi
}

# Function to pad string to length
pad_right() {
    local str="$1"
    local len="$2"
    printf "%-${len}s" "$str"
}

# Function to draw section header
draw_header() {
    local title="$1"
    local width=$((TERM_WIDTH - 2))
    local title_len=${#title}
    local padding=$(( (width - title_len - 2) / 2 ))

    echo ""
    printf "${BOLD}${CYAN}%s" "$BOX_TL"
    printf "%0.s$BOX_H" $(seq 1 $width)
    printf "%s${RESET}\n" "$BOX_TR"

    printf "${BOLD}${CYAN}%s${RESET}" "$BOX_V"
    printf "%${padding}s" ""
    printf "${BOLD}${YELLOW} %s ${RESET}" "$title"
    printf "%$((width - padding - title_len - 2))s" ""
    printf "${BOLD}${CYAN}%s${RESET}\n" "$BOX_V"

    printf "${BOLD}${CYAN}%s" "$BOX_VL"
    printf "%0.s$BOX_H" $(seq 1 $CMD_COL_WIDTH)
    printf "┬"
    printf "%0.s$BOX_H" $(seq 1 $((width - CMD_COL_WIDTH - 1)))
    printf "%s${RESET}\n" "$BOX_VR"
}

# Function to draw row
draw_row() {
    local cmd="$1"
    local desc="$2"

    local cmd_truncated
    local desc_truncated
    cmd_truncated=$(truncate "$cmd" $((CMD_COL_WIDTH - 2)))
    desc_truncated=$(truncate "$desc" $((DESC_COL_WIDTH - 2)))

    printf "${DIM}%s${RESET}" "$BOX_V"
    printf " ${GREEN}%s${RESET}" "$(pad_right "$cmd_truncated" $((CMD_COL_WIDTH - 2)))"
    printf "${DIM}%s${RESET}" "$BOX_V"
    printf " %s" "$(pad_right "$desc_truncated" $((DESC_COL_WIDTH - 2)))"
    printf "${DIM}%s${RESET}\n" "$BOX_V"
}

# Function to draw section footer
draw_footer() {
    local width=$((TERM_WIDTH - 2))

    printf "${DIM}%s" "$BOX_BL"
    printf "%0.s$BOX_H" $(seq 1 $CMD_COL_WIDTH)
    printf "┴"
    printf "%0.s$BOX_H" $(seq 1 $((width - CMD_COL_WIDTH - 1)))
    printf "%s${RESET}\n" "$BOX_BR"
}

# Temporary files for collecting data per group
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Map plugin to friendly group name
get_group_name() {
    local plugin="$1"
    case "$plugin" in
        majestic-engineer) echo "Engineering_Workflows" ;;
        majestic-rails) echo "Rails_Development" ;;
        majestic-python) echo "Python_Development" ;;
        majestic-tools) echo "Claude_Code_Tools" ;;
        majestic-marketing) echo "Marketing_&_SEO" ;;
        majestic-sales) echo "Sales_Acceleration" ;;
        majestic-company) echo "Business_Operations" ;;
        majestic-experts) echo "Expert_Panels" ;;
        *) echo "$plugin" ;;
    esac
}

# Map category to friendly group name
get_category_name() {
    local subdir="$1"
    case "$subdir" in
        workflows) echo "Workflows" ;;
        git) echo "Git_&_PRs" ;;
        session) echo "Session_Management" ;;
        tasks) echo "Task_Management" ;;
        meta) echo "Meta_Tools" ;;
        insight) echo "Insights_&_Analysis" ;;
        external-llm) echo "External_LLM" ;;
        gemfile) echo "Gemfile_Management" ;;
        .) echo "General" ;;
        *) echo "$subdir" ;;
    esac
}

# Display friendly name (convert underscores to spaces)
display_name() {
    echo "$1" | tr '_' ' '
}

# Scan all command files
for cmd_file in $(find "$PLUGINS_DIR" -path "*/commands/*.md" -type f 2>/dev/null | sort); do
    # Get plugin name from path
    plugin=$(echo "$cmd_file" | sed "s|$PLUGINS_DIR/||" | cut -d'/' -f1)

    # Filter by plugin if specified
    if [[ -n "$FILTER_PLUGIN" && "$plugin" != "$FILTER_PLUGIN" ]]; then
        continue
    fi

    # Get relative path within plugin
    rel_path=$(echo "$cmd_file" | sed "s|$PLUGINS_DIR/$plugin/||")

    # Extract metadata
    cmd_name=$(get_command_name "$cmd_file" "$plugin" "$rel_path")
    description=$(extract_frontmatter "$cmd_file" "description")

    # Skip if no description
    if [[ -z "$description" ]]; then
        description="(no description)"
    fi

    # Determine group based on style
    case "$GROUP_STYLE" in
        plugin)
            group=$(get_group_name "$plugin")
            ;;
        category)
            subdir=$(dirname "$rel_path" | sed 's|^commands/||' | cut -d'/' -f1)
            group=$(get_category_name "$subdir")
            ;;
        flat)
            group="All_Commands"
            ;;
    esac

    # Append to group file
    echo "${cmd_name}|${description}" >> "$TMP_DIR/$group"
done

# Print header
echo ""
printf "${BOLD}${MAGENTA}  ╔═══════════════════════════════════════════════════════════════╗${RESET}\n"
printf "${BOLD}${MAGENTA}  ║          Majestic Marketplace - Available Commands            ║${RESET}\n"
printf "${BOLD}${MAGENTA}  ╚═══════════════════════════════════════════════════════════════╝${RESET}\n"

# Sort and print groups
for group_file in $(ls "$TMP_DIR" 2>/dev/null | sort); do
    group_display=$(display_name "$group_file")
    draw_header "$group_display"

    # Sort commands within group and print
    while IFS='|' read -r cmd desc; do
        [[ -z "$cmd" ]] && continue
        draw_row "$cmd" "$desc"
    done < <(sort "$TMP_DIR/$group_file")

    draw_footer
done

# Print footer
echo ""
printf "${DIM}Type any command above to run it. Use --help for details.${RESET}\n"
printf "${DIM}Filter by plugin: bash hud-commands.sh --plugin majestic-engineer${RESET}\n"
echo ""
