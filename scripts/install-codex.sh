#!/bin/bash
# Install Majestic Marketplace skills and commands into Codex CLI (~/.codex)
#
# Usage:
#   ./scripts/install-codex.sh              # Interactive plugin selection
#   ./scripts/install-codex.sh --all        # Install all plugins
#   ./scripts/install-codex.sh engineer     # Install specific plugin(s)
#
# What gets installed:
#   - Skills:   plugins/*/skills/*   → ~/.codex/skills/{plugin-name}/
#   - Commands: plugins/*/commands/* → ~/.codex/prompts/{plugin-name}/
#
# Limitations:
#   - Codex doesn't support Claude Code's Task tool (subagents won't run)
#   - Hooks are not supported
#   - MCP server integrations won't work
#
# The core skills and commands still work well for guidance and workflows.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="$HOME/.codex"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Available plugins
PLUGINS=(
    "majestic-engineer:Language-agnostic engineering workflows"
    "majestic-rails:Ruby on Rails development tools"
    "majestic-react:Modern React development with TypeScript"
    "majestic-python:Python development tools"
    "majestic-devops:Infrastructure-as-Code and DevOps"
    "majestic-marketing:Marketing and SEO tools"
    "majestic-sales:Sales acceleration tools"
    "majestic-company:Business operations tools"
    "majestic-tools:Claude Code customization tools"
    "majestic-llm:External LLM integration"
    "majestic-experts:Expert panel discussion system"
    "majestic-agent-sdk:Agent SDK guides"
)

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         Majestic Marketplace → Codex CLI Installer          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_codex() {
    if [ ! -d "$CODEX_DIR" ]; then
        echo -e "${RED}Error: ~/.codex not found.${NC}"
        echo
        echo "Is Codex CLI installed? Install it with:"
        echo -e "  ${CYAN}npm install -g @openai/codex${NC}"
        echo
        exit 1
    fi
}

list_plugins() {
    echo -e "${BLUE}Available plugins:${NC}"
    echo
    local i=1
    for plugin_info in "${PLUGINS[@]}"; do
        local name="${plugin_info%%:*}"
        local desc="${plugin_info#*:}"
        local short_name="${name#majestic-}"

        # Check if plugin directory exists
        if [ -d "$REPO_ROOT/plugins/$name" ]; then
            echo -e "  ${GREEN}$i)${NC} $short_name - $desc"
        else
            echo -e "  ${YELLOW}$i)${NC} $short_name - $desc ${YELLOW}(not found)${NC}"
        fi
        ((i++))
    done
    echo
}

install_plugin() {
    local plugin_name="$1"
    local plugin_dir="$REPO_ROOT/plugins/$plugin_name"
    local short_name="${plugin_name#majestic-}"

    if [ ! -d "$plugin_dir" ]; then
        echo -e "  ${YELLOW}⚠${NC} Plugin $plugin_name not found, skipping"
        return
    fi

    echo -e "${BLUE}Installing $short_name...${NC}"

    # Create namespaced directories
    mkdir -p "$CODEX_DIR/skills/$short_name"
    mkdir -p "$CODEX_DIR/prompts/$short_name"

    # Install skills
    local skill_count=0
    if [ -d "$plugin_dir/skills" ]; then
        for skill_dir in "$plugin_dir/skills"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                # Copy skill directory
                rm -rf "$CODEX_DIR/skills/$short_name/$skill_name"
                cp -r "$skill_dir" "$CODEX_DIR/skills/$short_name/"
                ((skill_count++))
            fi
        done
    fi

    # Install commands (as prompts)
    local cmd_count=0
    if [ -d "$plugin_dir/commands" ]; then
        # Find all .md files recursively in commands
        while IFS= read -r -d '' cmd_file; do
            local rel_path="${cmd_file#$plugin_dir/commands/}"
            local cmd_name=$(basename "$cmd_file" .md)
            local cmd_subdir=$(dirname "$rel_path")

            # Create subdirectory structure
            if [ "$cmd_subdir" != "." ]; then
                mkdir -p "$CODEX_DIR/prompts/$short_name/$cmd_subdir"
                cp "$cmd_file" "$CODEX_DIR/prompts/$short_name/$cmd_subdir/"
            else
                cp "$cmd_file" "$CODEX_DIR/prompts/$short_name/"
            fi
            ((cmd_count++))
        done < <(find "$plugin_dir/commands" -name "*.md" -type f -print0 2>/dev/null)
    fi

    echo -e "  ${GREEN}✓${NC} $skill_count skills, $cmd_count commands"
}

select_plugins() {
    list_plugins

    echo -e "${BLUE}Select plugins to install:${NC}"
    echo "  Enter numbers separated by spaces (e.g., '1 2 5')"
    echo "  Or 'all' for everything, 'q' to quit"
    echo
    read -p "> " selection

    if [ "$selection" = "q" ]; then
        echo "Cancelled."
        exit 0
    fi

    if [ "$selection" = "all" ]; then
        for plugin_info in "${PLUGINS[@]}"; do
            local name="${plugin_info%%:*}"
            install_plugin "$name"
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#PLUGINS[@]}" ]; then
                local idx=$((num - 1))
                local plugin_info="${PLUGINS[$idx]}"
                local name="${plugin_info%%:*}"
                install_plugin "$name"
            else
                echo -e "${YELLOW}Invalid selection: $num${NC}"
            fi
        done
    fi
}

install_from_args() {
    for arg in "$@"; do
        # Handle short names (without majestic- prefix)
        if [[ ! "$arg" =~ ^majestic- ]]; then
            arg="majestic-$arg"
        fi
        install_plugin "$arg"
    done
}

print_limitations() {
    echo
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                        Limitations                           ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo "  Codex CLI doesn't support these Claude Code features:"
    echo -e "  ${RED}✗${NC} Task tool (subagents) - parallel research won't run"
    echo -e "  ${RED}✗${NC} Hooks - automation triggers won't fire"
    echo -e "  ${RED}✗${NC} MCP servers - external tool integrations"
    echo -e "  ${RED}✗${NC} Skill tool invocations - cross-skill references"
    echo
    echo "  Skills and commands still provide valuable guidance for:"
    echo -e "  ${GREEN}✓${NC} Coding patterns and conventions"
    echo -e "  ${GREEN}✓${NC} Workflow structures and checklists"
    echo -e "  ${GREEN}✓${NC} Domain-specific knowledge"
    echo
}

print_usage() {
    echo
    echo -e "${GREEN}Installation complete!${NC}"
    echo
    echo "Skills installed to: ~/.codex/skills/"
    echo "Prompts installed to: ~/.codex/prompts/"
    echo
    echo "Usage in Codex CLI:"
    echo -e "  ${CYAN}codex \"Use the engineer/plan-builder skill to plan this feature\"${NC}"
    echo -e "  ${CYAN}codex --prompt engineer/blueprint.md \"Add user authentication\"${NC}"
    echo
}

# Main
print_header
check_codex

if [ "$1" = "--all" ]; then
    echo "Installing all plugins..."
    echo
    for plugin_info in "${PLUGINS[@]}"; do
        local name="${plugin_info%%:*}"
        install_plugin "$name"
    done
elif [ $# -gt 0 ]; then
    install_from_args "$@"
else
    select_plugins
fi

print_limitations
print_usage
