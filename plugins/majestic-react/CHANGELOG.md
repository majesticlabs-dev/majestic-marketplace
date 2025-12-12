# Changelog

All notable changes to the majestic-react plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-12-12

### Changed

- **Refactored** - `react-patterns` skill trimmed to ≤500 lines, examples extracted to `resources/`
- **Refactored** - `react-coder` agent trimmed to ≤300 lines, patterns extracted to `resources/`
- **Refactored** - `react-architect` agent trimmed to ≤300 lines, examples extracted to `resources/`
- **Refactored** - `react-reviewer` agent trimmed to ≤300 lines, review examples extracted to `resources/`
- **Version unified** - All majestic plugins now at v3.0.0

## [0.1.0] - 2025-12-03

### Added
- Initial release of majestic-react plugin
- **Agents:**
  - `react-coder` - Write modern React components with TypeScript and hooks
  - `react-reviewer` - Review React code for best practices and performance
  - `react-architect` - Design React application architecture
- **Skills:**
  - `react-patterns` - Modern React patterns (hooks, composition, state management)
  - `react-testing` - Testing strategies with Vitest and React Testing Library
  - `tailwind-styling` - Responsive Tailwind CSS styling for React components
- Tech stack support for:
  - React 18+
  - TypeScript
  - Vite/Next.js
  - Tailwind CSS
  - Vitest/Jest
  - React Testing Library
  - pnpm

### Philosophy
- Simplicity over cleverness
- Component composition over complex components
- Testability as quality indicator
- Performance optimization
- Accessibility first

[0.1.0]: https://github.com/majesticlabs-dev/majestic-marketplace/releases/tag/majestic-react-v0.1.0
