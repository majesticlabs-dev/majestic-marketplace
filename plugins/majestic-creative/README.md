# majestic-creative

AI-powered creative tools for Claude Code.

## Skills

### gemini-image-coder

Generate and edit images using Google's Gemini API. Supports:

- Text-to-image generation
- Image editing and refinement
- Multi-image composition (up to 14 reference images)
- Resolutions up to 4K
- Multiple aspect ratios (1:1, 16:9, 9:16, 21:9, etc.)

## Installation

```bash
claude plugins add majestic-creative@majestic-marketplace
```

## Requirements

- Google AI API key with Gemini access
- `google-genai` Python package

## Setup

1. Install the Python dependency:

```bash
pip install "google-genai>=1.35.0"
```

2. Get your API key from [Google AI Studio](https://aistudio.google.com/api-keys)
3. Set the `GEMINI_API_KEY` environment variable:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

## Usage

The skill activates when you're working on image generation tasks. It provides:

- Correct API patterns and model selection
- Prompting best practices for different styles
- File format handling (JPEG vs PNG gotchas)
- Resolution and aspect ratio guidance
