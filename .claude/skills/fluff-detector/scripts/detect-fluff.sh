#!/usr/bin/env bash
set -euo pipefail

# Fluff Detector - Validates LLM artifacts for human-oriented content
# Usage: ./detect-fluff.sh <file.md>

FILE="${1:-}"
WARNINGS=0
ERRORS=0

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  echo "Usage: $0 <file.md>"
  echo "Detect human-oriented fluff in LLM artifacts"
  exit 1
}

warn() {
  local line="$1"
  local category="$2"
  local content="$3"
  local suggestion="$4"
  echo -e "${YELLOW}[WARN]${NC} Line $line: $category"
  echo -e "  > ${BLUE}$content${NC}"
  echo -e "  Suggestion: $suggestion"
  echo ""
  ((WARNINGS++)) || true
}

error() {
  local line="$1"
  local category="$2"
  local content="$3"
  local suggestion="$4"
  echo -e "${RED}[ERROR]${NC} Line $line: $category"
  echo -e "  > ${BLUE}$content${NC}"
  echo -e "  Suggestion: $suggestion"
  echo ""
  ((ERRORS++)) || true
}

[[ -z "$FILE" ]] && usage
[[ ! -f "$FILE" ]] && { echo "Error: File not found: $FILE"; exit 1; }

echo -e "\nAnalyzing: ${BLUE}$FILE${NC}\n"

# Read file content
CONTENT=$(cat "$FILE")
LINE_NUM=0

while IFS= read -r line || [[ -n "$line" ]]; do
  ((LINE_NUM++)) || true

  # Skip frontmatter
  if [[ $LINE_NUM -eq 1 && "$line" == "---" ]]; then
    in_frontmatter=true
    continue
  fi
  if [[ "${in_frontmatter:-false}" == "true" ]]; then
    [[ "$line" == "---" ]] && in_frontmatter=false
    continue
  fi

  # Skip code blocks
  if [[ "$line" =~ ^\`\`\` ]]; then
    in_code_block="${in_code_block:-false}"
    [[ "$in_code_block" == "false" ]] && in_code_block=true || in_code_block=false
    continue
  fi
  [[ "${in_code_block:-false}" == "true" ]] && continue

  # Lowercase for pattern matching
  lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

  # 1. Attribution signals (ERROR)
  if echo "$line" | grep -qiE '(inspired by|based on .+'"'"'s|as recommended by) [A-Z]'; then
    # Exclude "based on user input", "based on config", etc.
    if ! echo "$lower_line" | grep -qE 'based on (user|config|input|the|this|that|your)'; then
      error "$LINE_NUM" "Attribution signal" "$line" "Remove attribution or rephrase as pattern name"
    fi
  fi
  # "according to" only for person names (Firstname Lastname pattern)
  if echo "$line" | grep -qE '[Aa]ccording to [A-Z][a-z]+ [A-Z][a-z]+'; then
    error "$LINE_NUM" "Attribution signal" "$line" "Remove attribution or rephrase as pattern name"
  fi

  # 2. Decorative quotes (WARN)
  if echo "$line" | grep -qE '^>\s*[""].*[-—]\s*[A-Z]'; then
    warn "$LINE_NUM" "Decorative quote" "$line" "Remove - no execution value"
  fi

  # 3. Persona fluff (ERROR)
  if echo "$line" | grep -qiE '^(You are|As an?|I am|Acting as) (a |an |the )?[a-z]+ (expert|assistant|engineer|developer|specialist|professional)'; then
    error "$LINE_NUM" "Persona statement" "$line" "Delete - LLM doesn't need identity"
  fi

  if echo "$line" | grep -qiE 'you have (deep|extensive|broad) (expertise|knowledge|experience)'; then
    error "$LINE_NUM" "Capability claim" "$line" "Delete - capability claims waste tokens"
  fi

  # 4. Marketing language (ERROR)
  # Note: "guarantee" excluded - too many false positives with technical "type guarantees"
  if echo "$lower_line" | grep -qE '(best-in-class|world-class|cutting-edge|state-of-the-art|revolutionary|game-chang|next-gen|ensures? perfect|guarantees? (success|results|quality|perfect))'; then
    error "$LINE_NUM" "Marketing language" "$line" "Remove promotional language"
  fi

  # 5. Hedging language (WARN)
  if echo "$lower_line" | grep -qE '\b(try to|attempt to) [a-z]+'; then
    warn "$LINE_NUM" "Hedging language" "$line" "Be direct - remove 'try to'"
  fi

  if echo "$lower_line" | grep -qE 'you (might|may|could) want to'; then
    warn "$LINE_NUM" "Hedging language" "$line" "Be direct - state when to do it"
  fi

  # 6. Filler phrases (WARN)
  if echo "$lower_line" | grep -qE "(it('s| is) (important|worth|crucial) to (note|mention|remember))"; then
    warn "$LINE_NUM" "Filler phrase" "$line" "Delete intro - state the fact directly"
  fi

  if echo "$lower_line" | grep -qE '(please (keep in mind|note|remember) that)'; then
    warn "$LINE_NUM" "Filler phrase" "$line" "Delete - state directly"
  fi

  if echo "$lower_line" | grep -qE '(goes without saying|needless to say)'; then
    warn "$LINE_NUM" "Filler phrase" "$line" "Delete entirely - if it goes without saying, don't say it"
  fi

  if echo "$lower_line" | grep -qE '\bin order to\b'; then
    warn "$LINE_NUM" "Verbose phrase" "$line" "Use 'to' instead of 'in order to'"
  fi

  if echo "$lower_line" | grep -qE 'due to the fact that'; then
    warn "$LINE_NUM" "Verbose phrase" "$line" "Use 'because'"
  fi

  if echo "$lower_line" | grep -qE 'at this point in time'; then
    warn "$LINE_NUM" "Verbose phrase" "$line" "Use 'now'"
  fi

  # 7. Meta-commentary (WARN)
  if echo "$lower_line" | grep -qE '^this (agent|skill|command) (is used|helps|allows|enables|provides)'; then
    warn "$LINE_NUM" "Meta-commentary" "$line" "Delete - show what it does, don't describe it"
  fi

  if echo "$lower_line" | grep -qE 'the following (section|content|instructions) (describes?|explains?|shows?)'; then
    warn "$LINE_NUM" "Meta-commentary" "$line" "Delete - just show the content"
  fi

  # 8. Redundant tool explanations (WARN)
  if echo "$lower_line" | grep -qE 'the (read|write|edit|bash|glob|grep) tool (allows|lets|enables) you to'; then
    warn "$LINE_NUM" "Redundant explanation" "$line" "Delete - LLM knows tool capabilities"
  fi

done < "$FILE"

# Summary
echo "----------------------------------------"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo -e "${GREEN}Result: NO FLUFF DETECTED${NC}"
  exit 0
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YELLOW}Result: $WARNINGS warning(s) found${NC}"
  exit 1
else
  echo -e "${RED}Result: $ERRORS error(s), $WARNINGS warning(s)${NC}"
  exit 2
fi
