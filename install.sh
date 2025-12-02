#!/bin/bash
# Majestic Marketplace Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/install.sh | bash

set -e

REPO_RAW="https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master"
CLAUDE_DIR="$HOME/.claude"

# Colors (safe for both light and dark terminals)
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║   Majestic Marketplace Installer       ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
  echo ""
}

print_menu() {
  echo "What would you like to install?"
  echo ""
  echo "  1) Add marketplace (enables plugin installation)"
  echo "  2) Add output styles (formatting guides)"
  echo "  3) Add MCP servers (Sequential Thinking)"
  echo "  4) Configure shell settings (env vars + alias)"
  echo "  5) Install Beads (AI agent memory)"
  echo "  6) Install all"
  echo "  0) Exit"
  echo ""
}

install_marketplace() {
  echo -e "${CYAN}Adding marketplace...${NC}"

  if ! command -v claude &> /dev/null; then
    echo -e "${RED}✗ Error: claude command not found${NC}"
    echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    return 1
  fi

  echo -e "${GREEN}✓ Claude Code detected${NC}"
  echo ""
  echo -e "${BOLD}To add the marketplace, follow these steps:${NC}"
  echo ""
  echo "  1. Start Claude Code:"
  echo -e "     ${CYAN}claude${NC}"
  echo ""
  echo "  2. Once inside the Claude prompt, run:"
  echo -e "     ${CYAN}/plugin marketplace add https://github.com/majesticlabs-dev/majestic-marketplace.git${NC}"
  echo ""
  echo "  3. Install plugins with:"
  echo -e "     ${CYAN}/plugin install <plugin-name>${NC}"
  echo ""
  echo "Available plugins:"
  echo "  - majestic-engineer: Language-agnostic engineering workflows"
  echo "  - majestic-rails: Ruby on Rails development tools"
  echo "  - majestic-python: Python development tools"
  echo "  - majestic-marketing: Marketing and SEO tools"
  echo "  - majestic-sales: Sales acceleration tools"
  echo "  - majestic-company: Business operations tools"
  echo "  - majestic-tools: Claude Code customization tools"
}

install_beads() {
  echo -e "${CYAN}Installing Beads (AI agent memory)...${NC}"

  # Check for Homebrew
  if ! command -v brew &> /dev/null; then
    echo -e "${RED}✗ Error: Homebrew is required to install Beads${NC}"
    echo "Install Homebrew: https://brew.sh"
    return 1
  fi

  echo -e "${GREEN}✓ Homebrew detected${NC}"

  # Install via Homebrew
  echo "  Tapping steveyegge/beads..."
  brew tap steveyegge/beads

  echo "  Installing bd..."
  brew install bd

  echo -e "${GREEN}✓ Beads CLI installed${NC}"
  echo ""
  echo -e "${BOLD}To add the Beads plugin to Claude Code:${NC}"
  echo ""
  echo "  1. Start Claude Code:"
  echo -e "     ${CYAN}claude${NC}"
  echo ""
  echo "  2. Add the marketplace and install plugin:"
  echo -e "     ${CYAN}/plugin marketplace add steveyegge/beads${NC}"
  echo -e "     ${CYAN}/plugin install beads${NC}"
  echo ""
  echo "  3. Restart Claude Code to load the plugin"
  echo ""
  echo "Beads provides persistent memory for AI agents with:"
  echo "  - Dependency tracking (blocks, related, parent-child)"
  echo "  - Ready work detection (bd ready)"
  echo "  - Git-native distribution"
}

install_output_styles() {
  echo -e "${CYAN}Installing output styles...${NC}"

  local styles_dir="$CLAUDE_DIR/output-styles"
  mkdir -p "$styles_dir"

  local styles=(
    "bullet-points"
    "genui"
    "htlm-structured"
    "markdown-focused"
    "table-based"
    "tts-summary"
    "ultra-concise"
    "yaml-structured"
  )

  for style in "${styles[@]}"; do
    echo "  Downloading: $style.md"
    curl -fsSL "$REPO_RAW/output-styles/$style.md" -o "$styles_dir/$style.md"
  done

  echo -e "${GREEN}✓ Output styles installed to $styles_dir${NC}"
  echo ""
  echo "Usage:"
  echo "  cat ~/.claude/output-styles/ultra-concise.md >> ~/.claude/CLAUDE.md"
}

install_mcp_servers() {
  echo -e "${CYAN}Configuring MCP servers...${NC}"

  local settings_file="$CLAUDE_DIR/settings.json"

  # Check if jq is available
  if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ Error: jq is required for MCP configuration${NC}"
    echo "Install jq: brew install jq (macOS) or apt install jq (Linux)"
    return 1
  fi

  # Fetch available MCPs
  echo "  Fetching available MCP servers..."
  local mcps_json
  mcps_json=$(curl -fsSL "$REPO_RAW/mcps.json")

  if [ -z "$mcps_json" ]; then
    echo -e "${RED}✗ Error: Could not fetch MCP list${NC}"
    return 1
  fi

  # Display available MCPs
  echo ""
  echo "Available MCP servers:"
  echo ""

  local i=1
  local mcp_names=()
  while IFS= read -r name; do
    mcp_names+=("$name")
    local desc
    desc=$(echo "$mcps_json" | jq -r --arg n "$name" '.[$n].description')
    echo "  $i) $name - $desc"
    ((i++))
  done < <(echo "$mcps_json" | jq -r 'keys[]')

  echo "  a) Install all"
  echo "  0) Cancel"
  echo ""

  read -p "Select MCP to install [0-$((i-1))/a]: " mcp_choice

  if [ "$mcp_choice" = "0" ]; then
    echo "Cancelled."
    return 0
  fi

  # Create settings file if it doesn't exist
  mkdir -p "$CLAUDE_DIR"
  if [ ! -f "$settings_file" ]; then
    echo '{}' > "$settings_file"
  fi

  local installed=()

  if [ "$mcp_choice" = "a" ] || [ "$mcp_choice" = "A" ]; then
    # Install all MCPs
    for name in "${mcp_names[@]}"; do
      install_single_mcp "$name" "$mcps_json" "$settings_file"
      installed+=("$name")
    done
  elif [[ "$mcp_choice" =~ ^[0-9]+$ ]] && [ "$mcp_choice" -ge 1 ] && [ "$mcp_choice" -lt "$i" ]; then
    # Install selected MCP
    local selected_name="${mcp_names[$((mcp_choice-1))]}"
    install_single_mcp "$selected_name" "$mcps_json" "$settings_file"
    installed+=("$selected_name")
  else
    echo -e "${RED}✗ Invalid choice${NC}"
    return 1
  fi

  echo ""
  echo -e "${GREEN}✓ MCP servers configured!${NC}"
  echo ""
  echo "Installed:"
  for name in "${installed[@]}"; do
    local desc
    desc=$(echo "$mcps_json" | jq -r --arg n "$name" '.[$n].description')
    echo "  - $name: $desc"
  done
  echo ""
  echo "Restart Claude Code to load the MCP server(s)."
}

install_single_mcp() {
  local name="$1"
  local mcps_json="$2"
  local settings_file="$3"

  echo "  Installing: $name"

  local mcp_config
  mcp_config=$(echo "$mcps_json" | jq --arg n "$name" '.[$n] | {command, args}')

  local temp_file
  temp_file=$(mktemp)
  jq --arg n "$name" --argjson config "$mcp_config" '.mcpServers[$n] = $config' "$settings_file" > "$temp_file" && mv "$temp_file" "$settings_file"
}

install_shell_settings() {
  echo -e "${CYAN}Configuring shell settings...${NC}"

  # Detect shell profile
  local profile_file
  if [ -f "$HOME/.zshrc" ]; then
    profile_file="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    profile_file="$HOME/.bashrc"
  else
    profile_file="$HOME/.bashrc"
    touch "$profile_file"
  fi

  local marker="# Majestic Marketplace - Claude Code Settings"

  # Check if already installed (idempotent)
  if grep -q "$marker" "$profile_file" 2>/dev/null; then
    echo -e "${GREEN}✓ Shell settings already configured in $profile_file${NC}"
    return 0
  fi

  # Fetch and append settings from repo
  echo "  Downloading shell settings..."
  local settings
  settings=$(curl -fsSL "$REPO_RAW/instructions/shell-settings.sh")

  if [ -z "$settings" ]; then
    echo -e "${RED}✗ Error: Could not fetch shell settings${NC}"
    return 1
  fi

  echo "" >> "$profile_file"
  echo "$settings" >> "$profile_file"

  echo -e "${GREEN}✓ Shell settings added to $profile_file${NC}"
  echo ""
  echo "Settings added:"
  echo "$settings" | grep -E "^export|^alias" | sed 's/^/  /'
  echo ""
  echo "Run 'source $profile_file' or restart your terminal to apply."
}

main() {
  print_header

  # Check if running interactively or with argument
  if [ -n "$1" ]; then
    choice="$1"
  else
    print_menu
    read -p "Enter choice [0-6]: " choice
  fi

  echo ""

  case $choice in
    1)
      install_marketplace
      ;;
    2)
      install_output_styles
      ;;
    3)
      install_mcp_servers
      ;;
    4)
      install_shell_settings
      ;;
    5)
      install_beads
      ;;
    6)
      install_marketplace
      echo ""
      install_output_styles
      echo ""
      install_mcp_servers
      echo ""
      install_shell_settings
      echo ""
      install_beads
      ;;
    0)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo -e "${RED}✗ Invalid choice${NC}"
      exit 1
      ;;
  esac

  echo ""
  echo -e "${GREEN}Done!${NC}"
}

main "$@"
