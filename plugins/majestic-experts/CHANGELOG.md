# Changelog

All notable changes to this project will be documented in this file.

## [3.1.0] - 2025-12-23

### Added

- **Devils-advocate discussion type** - New two-round format where experts argue for, then against their positions
  - Round 1: Genuine position
  - Round 2: Challenge own position with strongest counter-arguments
  - Emphasizes stress-testing over consensus

### Enhanced

- **Critical Evaluation section** - All synthesis now includes mandatory critical analysis:
  - Blind spots: What the panel didn't consider
  - Assumptions under challenge: Validity of underlying assumptions
  - Counter-arguments: Strongest arguments against consensus
  - Failure modes: How recommendations could go wrong
  - Confidence calibration: Adjusted recommendations based on scrutiny

### Changed

- **Removed time estimates** - Discussion type descriptions no longer include estimated durations

## [3.0.0] - 2025-12-12

### Changed

- **Refactored** - `expert-panel-discussion` agent trimmed to ≤300 lines, synthesis template and edge cases extracted to `resources/`
- **Version unified** - All majestic plugins now at v3.0.0

## [1.1.0] - 2024-12-10

### Enhanced

- **DHH expert** - Added comprehensive "Case Against Microservices (2024)" section
  - 5 structured arguments against microservices for small teams
  - Key quotes preserved from original essay
  - New key phrases: "distributed ignorance", "rituals of appeasement", "process cosplay"

## [1.0.0] - 2024-12-09

### Added

- Initial release of majestic-experts plugin
- `/expert-panel` command for structured expert discussions
  - 4 discussion types: round-table, debate, consensus-seeking, deep-dive
  - Save/resume functionality for multi-session discussions
  - Export to markdown
  - Dynamic expert discovery with filtering
- `expert-panel-discussion` orchestrator agent
  - Parallel expert invocation for efficiency
  - Sequential thinking integration for analysis
  - Consensus, divergence, and unique insight detection
  - Comprehensive synthesis with actionable recommendations
- `expert-perspective` agent
  - Authentic expert voice simulation
  - Reads expert definition files for personality
  - Supports custom inline experts
- 22 curated expert personas across 5 categories:
  - Engineering (6): DHH, Martin Fowler, Kent Beck, Uncle Bob, Sandi Metz, Rich Hickey
  - Business (7): Seth Godin, Peter Thiel, Naval Ravikant, Jason Fried, Paul Graham, April Dunford, Rand Fishkin
  - Product (4): Ryan Singer, Julie Zhuo, Marty Cagan, Alan Cooper
  - Pricing (3): Patrick Campbell, Rob Walling, Josh Pigford
  - Security (2): Troy Hunt, Tanya Janca
- Expert registry file (`registry.yml`) for fast lookup
- Configuration support via `.agents.yml`:
  - `enabled_categories` for category-level filtering
  - `disabled_categories` for blacklist approach
  - `disabled_experts` for individual expert filtering
  - `custom_experts_path` for project-specific experts
- Full expert definition format with:
  - YAML frontmatter (name, credentials, category, subcategories, keywords)
  - Philosophy section
  - Communication style guidelines
  - Known positions by topic
  - Key phrases
  - Context for AI embodiment
  - Famous works
  - Debate tendencies
- README documentation with usage examples
