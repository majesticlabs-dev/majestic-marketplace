---
description: Generate images using Gemini API from text prompts
allowed-tools: Read, Write, Bash, Glob
argument-hint: "<prompt> <output-path> [--aspect RATIO] [--size SIZE]"
---

# Generate Image with Gemini

Generate images from text prompts using Google's Gemini API.

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Format:** `<prompt> <output-path> [options]`

**Options:**
- `--aspect` - Aspect ratio: 1:1, 16:9, 9:16, 3:2, 2:3, 4:3, 3:4, 4:5, 5:4, 21:9
- `--size` - Resolution: 1K, 2K, 4K

**Examples:**
```
/majestic-creative:generate-image "A cat in space" cat.jpg
/majestic-creative:generate-image "Epic landscape" landscape.jpg --aspect 16:9
/majestic-creative:generate-image "Product mockup" product.jpg --aspect 1:1 --size 2K
```

## Prerequisites

- `GEMINI_API_KEY` environment variable must be set
- Python 3.10+ with `google-genai` and `Pillow` packages

## Process

### Step 1: Validate Environment

```bash
python -c "import os; print('ok' if os.environ.get('GEMINI_API_KEY') else 'missing')"
```

If missing, inform user:
```
GEMINI_API_KEY not set. Get one at https://aistudio.google.com/apikey
```

### Step 2: Parse Arguments

Extract from `$ARGUMENTS`:
- **Prompt:** Text in quotes or first argument
- **Output path:** Second argument (ensure .jpg extension)
- **Aspect ratio:** `--aspect` value (optional)
- **Size:** `--size` value (optional)

### Step 3: Generate Image

Use the bundled script:

```bash
python {baseDir}/../skills/gemini-image-coder/scripts/generate_image.py \
  "<prompt>" \
  "<output-path>" \
  [--aspect <ratio>] \
  [--size <size>]
```

### Step 4: Verify and Report

Check that the output file was created:

```bash
ls -la <output-path>
```

Report success with file path and size.

## Error Handling

### Rate Limiting
If you get "API returned no content", wait 2-3 seconds and retry.

### Content Policy
If prompt is rejected, suggest modifying the prompt to be more generic.

### Multiple Images
When generating multiple images, add 2-second delays between requests:
```bash
sleep 2
```

## Output Format

```markdown
**Generated:** `<output-path>`
**Size:** <file-size>
**Prompt:** "<prompt>"

[Show the image if in a context that supports it]
```
