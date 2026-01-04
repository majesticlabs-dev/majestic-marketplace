---
name: gemini-image-coder
description: Gemini image coder - Generate and edit images using Google's Gemini API. Supports text-to-image, image editing, multi-turn refinement, and composition from multiple reference images. Use when user asks to generate images, create images, edit images, or mentions "gemini image coder".
allowed-tools: Read, Write, Bash, WebSearch
---

# Gemini Image Generation

Generate and edit images using Google's Gemini API. Requires `GEMINI_API_KEY` environment variable.

## Quick Reference

| Setting | Default | Options |
|---------|---------|---------|
| **Model** | `gemini-3-pro-image-preview` | Use this for all generation |
| **Resolution** | 1K | 1K, 2K, 4K |
| **Aspect Ratio** | 1:1 | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 |

## CLI Scripts

### Generate Image

```bash
python scripts/generate_image.py "A cat in space" output.jpg
python scripts/generate_image.py "Epic landscape" landscape.jpg --aspect 16:9 --size 2K
python scripts/generate_image.py "Logo for Acme Corp" logo.jpg --aspect 1:1
```

### Edit Image

```bash
python scripts/edit_image.py input.jpg "Add a rainbow" output.jpg
python scripts/edit_image.py photo.jpg "Make it look like Van Gogh" artistic.jpg
```

## Core API Pattern

```python
import os
from google import genai
from google.genai import types

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=["Your prompt here"],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
    ),
)

for part in response.parts:
    if part.text:
        print(part.text)
    elif part.inline_data:
        image = part.as_image()
        image.save("output.jpg")  # Always use .jpg!
```

## Custom Resolution & Aspect Ratio

```python
response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=[prompt],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
        image_config=types.ImageConfig(
            aspect_ratio="16:9",
            image_size="2K"
        ),
    )
)
```

## Editing Images

```python
from PIL import Image

img = Image.open("input.jpg")
response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=["Add a sunset to this scene", img],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
    ),
)
```

## Multi-Turn Refinement

```python
chat = client.chats.create(
    model="gemini-3-pro-image-preview",
    config=types.GenerateContentConfig(response_modalities=['TEXT', 'IMAGE'])
)

response = chat.send_message("Create a logo for 'Acme Corp'")
# Save first image...

response = chat.send_message("Make the text bolder and add a blue gradient")
# Save refined image...
```

## Prompting Best Practices

| Style | Prompt Pattern |
|-------|---------------|
| **Photorealistic** | Include camera: lens, lighting, angle, mood |
| **Stylized Art** | Specify style explicitly: "kawaii-style", "cel-shading" |
| **Text in Images** | Be explicit: font style, placement, colors |
| **Product Mockups** | Describe lighting setup and surface |

### Examples

```
# Photorealistic
"A photorealistic close-up portrait, 85mm lens, soft golden hour light, shallow depth of field"

# Stylized
"A kawaii-style sticker of a happy red panda, bold outlines, cel-shading, white background"

# Logo with text
"Create a logo with text 'Daily Grind' in clean sans-serif, black and white, coffee bean motif"

# Product mockup
"Studio-lit product photo on polished concrete, three-point softbox setup, 45-degree angle"
```

## Advanced Features

### Google Search Grounding

```python
response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=["Visualize today's weather in Tokyo as an infographic"],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
        tools=[{"google_search": {}}]
    )
)
```

### Multiple Reference Images (Up to 14)

```python
response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=[
        "Create a group photo of these people in an office",
        Image.open("person1.jpg"),
        Image.open("person2.jpg"),
        Image.open("person3.jpg"),
    ],
    config=types.GenerateContentConfig(
        response_modalities=['TEXT', 'IMAGE'],
    ),
)
```

## Critical: File Format

**Gemini returns JPEG by default. Always use `.jpg` extension.**

```python
# CORRECT
image.save("output.jpg")

# WRONG - causes "Image does not match media type" errors
image.save("output.png")  # Creates JPEG with PNG extension!
```

### If PNG is Required

```python
from PIL import Image

for part in response.parts:
    if part.inline_data:
        img = part.as_image()
        img.save("output.png", format="PNG")  # Explicit conversion
```

### Verify Format

```bash
file image.png
# If output shows "JPEG image data" - rename to .jpg!
```

## Notes

- All generated images include SynthID watermarks
- Default to 1K for speed; use 2K/4K when quality is critical
- For editing, describe changes conversationally—the model understands semantic masking
- Image-only mode won't work with Google Search grounding
