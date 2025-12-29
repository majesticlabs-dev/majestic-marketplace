# Changelog

## [1.1.0] - 2025-12-28

### Changed

- **codex-reviewer**: Replaced `codex review` with `codex exec` for full control over review prompts
  - Now includes project context (CLAUDE.md, review topics)
  - Default model updated to `gpt-5.2-codex` with `model_reasoning_effort="xhigh"`
  - Custom prompts instead of Codex's opinionated built-in review
- **/majestic-llm:review**: Updated default model and added "How It Works" section

## [1.0.0] - 2024-12-20

### Added

- Initial release extracted from majestic-tools
- **Agents:**
  - `codex-consult`: Architecture perspectives from OpenAI Codex
  - `codex-reviewer`: Code review from OpenAI Codex
  - `gemini-consult`: Architecture perspectives from Google Gemini
  - `gemini-reviewer`: Code review from Google Gemini
  - `multi-llm-coordinator`: Multi-LLM synthesis with consensus/divergence
- **Commands:**
  - `/majestic-llm:consult`: Architecture/design consulting
  - `/majestic-llm:review`: Code review from external LLMs
