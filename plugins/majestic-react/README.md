# Majestic React

Modern React development plugin for Claude Code with TypeScript, component generation, and testing strategies.

## Overview

Majestic React provides AI-powered tools for React development, including:
- **3 specialized agents** for coding, reviewing, and architecture
- **3 skills** covering patterns, testing, and styling

## Installation

```bash
claude /plugin install majestic-react
```

## Agents

### Code Agents

#### `react-coder`
Write modern React components with TypeScript, hooks, and best practices.

**Use cases:**
- Generate functional components with proper typing
- Create custom hooks with cleanup logic
- Implement compound components and composition patterns
- Build forms with validation and error handling

**Example:**
```bash
claude agent react-coder "Create a SearchBar component with debounced input"
```

### Review Agents

#### `react-reviewer`
Review React components for best practices, performance, accessibility, and testing coverage.

**Use cases:**
- Code review for React components
- Performance optimization suggestions
- Accessibility compliance checking
- Hook dependency validation
- TypeScript type safety review

**Example:**
```bash
claude agent react-reviewer "Review components/UserProfile.tsx"
```

### Planning Agents

#### `react-architect`
Design React application architecture and component hierarchies.

**Use cases:**
- Plan component structure and state management
- Design scalable folder organization
- Recommend performance optimization strategies
- Create testing strategy and coverage plan

**Example:**
```bash
claude agent react-architect "Design architecture for a dashboard app with real-time data"
```

## Skills

### `react-patterns`
Expert guidance on modern React patterns including hooks, composition, state management, and concurrent features.

**Covers:**
- Compound components
- Render props pattern
- Higher-order components
- Custom hooks (data fetching, forms, debounce)
- Context + useReducer for complex state
- Performance optimization with memoization
- Code splitting strategies
- Error boundaries
- Accessibility patterns

### `react-testing`
Comprehensive testing strategies with Vitest, React Testing Library, and Jest.

**Covers:**
- Component testing (basic, forms, interactions)
- Hook testing (custom hooks, dependencies)
- Integration testing (with Context, Router)
- API mocking with MSW
- Component mocking
- Accessibility testing with jest-axe
- Best practices for maintainable tests

### `tailwind-styling`
Generate responsive, performant Tailwind CSS styles for React components.

**Covers:**
- Common component patterns (buttons, cards, forms, inputs)
- Layout patterns (container, grid, flexbox)
- Responsive design (breakpoints, mobile-first)
- Dark mode implementation
- Custom utilities and configuration
- Performance optimization
- Component library patterns

## Tech Stack

This plugin assumes the following modern React stack:
- **React 18+** with concurrent features
- **TypeScript** for type safety
- **Functional components** with hooks
- **pnpm** for package management
- **Vite** or **Next.js** for tooling
- **Tailwind CSS** for styling
- **Vitest** or **Jest** for testing
- **React Testing Library** for component tests

## Philosophy

- **Simplicity > Cleverness**: Straightforward code that's easy to understand
- **Component Composition**: Build complex UIs from simple, reusable pieces
- **Testability as Quality Indicator**: If it's hard to test, the structure needs refactoring
- **Performance**: Minimize re-renders, optimize heavy computations
- **Accessibility**: Build inclusive, keyboard-navigable interfaces

## Examples

### Creating a Component

```bash
claude agent react-coder "Create a Card component with title, content, and optional footer"
```

### Reviewing Code

```bash
claude agent react-reviewer "Review the Dashboard component for performance issues"
```

### Planning Architecture

```bash
claude agent react-architect "Design state management for an e-commerce checkout flow"
```

## Best Practices

1. **Prefer functional components** with hooks over class components
2. **Extract custom hooks** when logic is reused or complex
3. **Use compound components** for flexible component APIs
4. **Memoize** expensive computations and callbacks
5. **Code split** routes and heavy components
6. **Handle errors** with error boundaries
7. **Manage focus** in modals and dynamic content
8. **Use semantic HTML** and ARIA labels
9. **Test hooks** in isolation from components
10. **Keep components small** (< 200 lines)

## Version

Current version: 0.1.0

## Contributing

Found a bug or have a feature request? Please open an issue at:
https://github.com/majesticlabs-dev/majestic-marketplace/issues

## License

MIT License - see LICENSE file for details

## Author

Created by [Majestic Labs LLC](https://majesticlabs.dev)
