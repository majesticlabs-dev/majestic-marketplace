# majestic-llm

External LLM integration tools for Claude Code. Get second opinions from Codex (OpenAI) and Gemini (Google) on architecture, design, and code review.

## Overview

This plugin provides tools to consult external LLMs when working with Claude Code:

- **Architecture consulting**: Get alternative perspectives on design decisions
- **Code review**: Get second opinions on code changes
- **Multi-LLM synthesis**: Query multiple LLMs and synthesize consensus/divergence

## Prerequisites

Install at least one CLI:

- **Codex**: `npm install -g @openai/codex && codex login`
- **Gemini**: See [gemini-cli](https://github.com/google-gemini/gemini-cli)

## Commands

| Command | Description |
|---------|-------------|
| `/majestic-llm:consult` | Get architecture/design perspectives from external LLMs |
| `/majestic-llm:review` | Get code review from external LLMs on current changes |

## Agents

| Agent | Description |
|-------|-------------|
| `codex-consult` | Get architecture perspectives from OpenAI Codex |
| `codex-reviewer` | Get code review feedback from OpenAI Codex |
| `gemini-consult` | Get architecture perspectives from Google Gemini |
| `gemini-reviewer` | Get code review feedback from Google Gemini |
| `multi-llm-coordinator` | Query multiple LLMs and synthesize responses |

## Available Models

### Codex (OpenAI)

| Model | Use Case |
|-------|----------|
| `gpt-5.1-codex-mini` | Fast, cost-effective |
| `gpt-5.1-codex` | Balanced (default for consult) |
| `gpt-5.1-codex-max` | Maximum intelligence (default for review) |

### Gemini (Google)

| Model | Use Case |
|-------|----------|
| `gemini-2.5-flash` | Fast, cost-effective |
| `gemini-2.5-pro` | Balanced |
| `gemini-3.0-pro-preview` | Latest (default) |

## Usage Examples

### Consult on Architecture

```bash
# Quick consult with both LLMs
/majestic-llm:consult Should we use Redis or PostgreSQL for session storage?

# Consult only Codex
/majestic-llm:consult --llm codex Best approach for API versioning?

# High-stakes decision with max model
/majestic-llm:consult --codex-model gpt-5.1-codex-max Database migration strategy
```

### Code Review

```bash
# Review uncommitted changes with both LLMs
/majestic-llm:review

# Review staged changes with Codex only
/majestic-llm:review --staged --llm codex

# Review branch against main
/majestic-llm:review --branch --llm all
```

## When to Use

- **High-stakes decisions**: Architecture, security, breaking changes
- **Uncertainty**: When you're not sure about the right approach
- **Validation**: Confirming Claude's recommendations
- **Blind spot detection**: Identify issues a single model might miss

## When NOT to Use

- **Simple queries**: Single perspective is sufficient
- **Speed-critical**: Multiple queries add latency
- **Cost-sensitive**: Multiple API calls = higher cost
