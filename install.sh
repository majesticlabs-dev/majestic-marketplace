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
  echo "  3) Add MCP servers"
  echo "  4) Install all"
  echo "  0) Exit"
  echo ""
}

install_marketplace() {
  echo -e "${CYAN}Adding marketplace...${NC}"

  if command -v claude &> /dev/null; then
    claude /plugin marketplace add https://github.com/majesticlabs-dev/majestic-marketplace
    echo -e "${GREEN}✓ Marketplace added successfully!${NC}"
    echo ""
    echo "Available plugins:"
    echo "  - majestic-engineer: Language-agnostic engineering workflows"
    echo "  - majestic-rails: Ruby on Rails development tools"
    echo "  - majestic-tools: Claude Code customization tools"
    echo ""
    echo "Install a plugin with:"
    echo "  claude /plugin install <plugin-name>"
  else
    echo -e "${RED}✗ Error: claude command not found${NC}"
    echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    return 1
  fi
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

main() {
  print_header

  # Check if running interactively or with argument
  if [ -n "$1" ]; then
    choice="$1"
  else
    print_menu
    read -p "Enter choice [0-4]: " choice
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
      install_marketplace
      echo ""
      install_output_styles
      echo ""
      install_mcp_servers
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
