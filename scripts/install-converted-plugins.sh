#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DEFAULT_TARGET="codex"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

AVAILABLE_PLUGINS=()

print_header() {
  echo -e "${CYAN}"
  echo "╔═════════════════════════════════════════════════════════════╗"
  echo "║      Majestic Marketplace → Claude Format Converter         ║"
  echo "╚═════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

print_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install-converted-plugins.sh [options] [plugins...]

Options:
  --to <opencode|codex>   Target format (default: codex)
  --all                    Install all available plugins
  --help                   Show usage

Arguments:
  plugin names may be prefixed or unprefixed:
    engineer, rails, majestic-engineer

Examples:
  ./scripts/install-converted-plugins.sh --all
  ./scripts/install-converted-plugins.sh --to opencode --all
  ./scripts/install-converted-plugins.sh --to codex engineer rails
USAGE
}

collect_plugins() {
  local plugin_dir
  local discovered=()

  for plugin_dir in "$REPO_ROOT/plugins/"majestic-*; do
    [ -d "$plugin_dir" ] || continue
    discovered+=("$(basename "$plugin_dir")")
  done

  if [ ${#discovered[@]} -eq 0 ]; then
    echo -e "${RED}No plugins found in $REPO_ROOT/plugins${NC}"
    exit 1
  fi

  AVAILABLE_PLUGINS=()
  while IFS= read -r plugin_name; do
    AVAILABLE_PLUGINS+=("$plugin_name")
  done < <(printf '%s\n' "${discovered[@]}" | sort)
}

normalize_plugin_name() {
  local raw_name="$1"

  if [[ "$raw_name" == majestic-* ]]; then
    printf '%s\n' "$raw_name"
  else
    printf 'majestic-%s\n' "$raw_name"
  fi
}

is_available_plugin() {
  local candidate="$1"
  local existing

  for existing in "${AVAILABLE_PLUGINS[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return 0
    fi
  done

  return 1
}

list_plugins() {
  echo -e "${BLUE}Available plugins:${NC}"
  echo

  local idx=1
  local plugin_name
  for plugin_name in "${AVAILABLE_PLUGINS[@]}"; do
    local short_name="${plugin_name#majestic-}"
    echo -e "  ${GREEN}$idx)${NC} $short_name"
    idx=$((idx + 1))
  done
  echo
}

check_dependencies() {
  if ! command -v ruby >/dev/null 2>&1; then
    echo -e "${RED}Error: ruby is required to run conversion.${NC}"
    echo
    echo -e "  ${CYAN}Please install Ruby and rerun this command.${NC}"
    exit 1
  fi

  if [ ! -f "$SCRIPT_DIR/convert-plugin.rb" ]; then
    echo -e "${RED}Error: missing scripts/convert-plugin.rb.${NC}"
    echo
    echo -e "  ${CYAN}This repository does not include the local Ruby converter implementation.${NC}"
    exit 1
  fi
}

resolve_output_root() {
  local target="$1"

  if [ "$target" = "opencode" ]; then
    printf '%s' "$HOME/.config/opencode"
    return
  fi

  if [ "$target" = "codex" ]; then
    printf '%s' "$HOME/.codex"
    return
  fi

  printf '%s' "$HOME"
}

convert_one() {
  local plugin_name="$1"
  local target="$2"
  local plugin_dir="$REPO_ROOT/plugins/$plugin_name"
  local short_name="${plugin_name#majestic-}"

  if [ ! -d "$plugin_dir" ]; then
    echo -e "${YELLOW}⚠ ${plugin_name} not found, skipping${NC}"
    return 1
  fi

  echo -e "${BLUE}Converting $short_name to $target...${NC}"
  local output
  output="$(resolve_output_root "$target")"

  if ! ruby "$SCRIPT_DIR/convert-plugin.rb" --plugin "$plugin_dir" --target "$target" --output "$output"; then
    echo -e "${RED}Conversion failed: $plugin_name${NC}"
    return 1
  fi
}

convert_plugins() {
  local target="$1"
  shift

  local selected=()
  local failed=()
  local plugin_name

  for plugin_name in "$@"; do
    local normalized
    normalized="$(normalize_plugin_name "$plugin_name")"

    if ! is_available_plugin "$normalized"; then
      echo -e "${YELLOW}⚠ Skipping unknown plugin: $plugin_name${NC}"
      failed+=("$plugin_name")
      continue
    fi

    if convert_one "$normalized" "$target"; then
      selected+=("$plugin_name")
    else
      failed+=("$plugin_name")
    fi
  done

  echo
  echo -e "${GREEN}Complete${NC}"
  if [ ${#selected[@]} -gt 0 ]; then
    echo -e "  Installed (${#selected[@]}): ${GREEN}${selected[*]}${NC}"
  fi

  if [ ${#failed[@]} -gt 0 ]; then
    echo -e "  Failed/Skipped: ${YELLOW}${failed[*]}${NC}"
    return 1
  fi
}

build_selection() {
  local mode="$1"
  shift

  local -a args=("$@")
  local selected=()

  if [ "$mode" = "all" ]; then
    selected=("${AVAILABLE_PLUGINS[@]}")
    printf '%s\n' "${selected[@]}"
    return
  fi

  if [ ${#args[@]} -gt 0 ]; then
    printf '%s\n' "${args[@]}"
    return
  fi

  list_plugins
  echo -e "${BLUE}Select plugins to convert:${NC}"
  echo "  Enter numbers separated by spaces (for example: '1 2 4')"
  echo "  Or 'all' for everything, 'q' to quit"
  echo

  local selection
  read -rp "> " selection

  if [ "$selection" = "q" ]; then
    echo "Cancelled."
    exit 0
  fi

  if [ "$selection" = "all" ]; then
    selected=("${AVAILABLE_PLUGINS[@]}")
    printf '%s\n' "${selected[@]}"
    return
  fi

  local token
  local index
  for token in $selection; do
    if ! [[ "$token" =~ ^[0-9]+$ ]]; then
      echo -e "${YELLOW}Skipping invalid token: $token${NC}"
      continue
    fi

    index=$((token - 1))
    if [ "$index" -lt 0 ] || [ "$index" -ge "${#AVAILABLE_PLUGINS[@]}" ]; then
      echo -e "${YELLOW}Skipping out-of-range selection: $token${NC}"
      continue
    fi

    selected+=("${AVAILABLE_PLUGINS[$index]}")
  done

  printf '%s\n' "${selected[@]}"
}

main() {
  local target="$DEFAULT_TARGET"
  local all_mode=0
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to|--target)
        if [ $# -lt 2 ]; then
          echo -e "${RED}Error: --to requires a target value${NC}"
          print_usage
          exit 1
        fi
        target="$2"
        shift 2
        ;;
      --to=*)
        target="${1#*=}"
        shift
        ;;
      --target=*)
        target="${1#*=}"
        shift
        ;;
      --all)
        all_mode=1
        shift
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      --*)
        echo -e "${RED}Unknown option: $1${NC}"
        print_usage
        exit 1
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  if [ "$target" != "codex" ] && [ "$target" != "opencode" ]; then
    echo -e "${RED}Error: unsupported target '$target'${NC}"
    echo "Supported targets: opencode, codex"
    print_usage
    exit 1
  fi

  collect_plugins

  local selection_mode
  if [ "$all_mode" -eq 1 ]; then
    selection_mode="all"
  elif [ ${#args[@]} -gt 0 ]; then
    selection_mode="args"
  else
    selection_mode="interactive"
  fi

  local selected_plugins=()
  selected_plugins=()
  while IFS= read -r plugin_name; do
    selected_plugins+=("$plugin_name")
  done < <(build_selection "$selection_mode" "${args[@]}")

  if [ ${#selected_plugins[@]} -eq 0 ]; then
    echo -e "${YELLOW}No plugins selected. Nothing to do.${NC}"
    exit 0
  fi

  check_dependencies

  echo
  print_header
  echo -e "${GREEN}Target:${NC} $target"
  echo -e "${GREEN}Output:${NC} $(resolve_output_root "$target")"
  echo

  if ! convert_plugins "$target" "${selected_plugins[@]}"; then
    exit 1
  fi

  echo
  echo -e "${GREEN}Installed to: $(resolve_output_root "$target")${NC}"
  echo
  echo "Usage in target CLI:"
  if [ "$target" = "opencode" ]; then
    echo -e "  ${CYAN}opencode login${NC}"
  else
    echo -e "  ${CYAN}codex exec -p \"Hello\"${NC}"
  fi
}

main "$@"
