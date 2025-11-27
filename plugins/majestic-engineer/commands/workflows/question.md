---
allowed-tools: Bash(git ls-files:*), Read
description: Answer questions about the project structure and documentation without coding
---

# Question

Answer the user's question by analyzing the project structure and documentation. This prompt is designed to provide information and answer questions without making any code changes.

## Instructions

- **IMPORTANT: This is a question-answering task only - DO NOT write, edit, or create any files**
- **IMPORTANT: Focus on understanding and explaining existing code and project structure**
- **IMPORTANT: Provide clear, informative answers based on project analysis**
- **IMPORTANT: If the question requires code changes, explain what would need to be done conceptually without implementing**

## Execute

- `git ls-files` to understand the project structure

## Read

- README.md for project overview and documentation

## Analysis Approach

- Review the project structure from git ls-files
- Understand the project's purpose from README
- Connect the question to relevant parts of the project
- Provide comprehensive answers based on analysis

## Response Format

- Direct answer to the question
- Supporting evidence from project structure
- References to relevant documentation
- Conceptual explanations where applicable

## Question

$ARGUMENTS

