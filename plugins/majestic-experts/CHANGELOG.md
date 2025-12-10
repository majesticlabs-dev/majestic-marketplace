# Changelog

All notable changes to this project will be documented in this file.

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
