---
description: Generate complete favicon set from source image and update project HTML
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion
argument-hint: "<source-image>"
disable-model-invocation: true
---

# Favicon Generator

Generate a complete set of favicons from a source image and integrate them into your project.

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Format:** `<source-image-path>`

**Supported formats:** PNG, JPG, JPEG, SVG, WEBP, GIF

**Examples:**
```
/majestic-engineer:favicon logo.png
/majestic-engineer:favicon assets/icon.svg
```

## Prerequisites

ImageMagick v7+ required. Verify with:

```bash
which magick
```

If missing:
- **macOS:** `brew install imagemagick`
- **Linux:** `sudo apt install imagemagick`

## Workflow

### Step 1: Validate Source Image

1. Check source file exists
2. Verify supported format (PNG, JPG, JPEG, SVG, WEBP, GIF)
3. Note if SVG (gets special handling)

If invalid, report error and stop.

### Step 2: Detect Framework

Check for marker files to identify framework and assets directory:

| Framework | Marker File | Assets Directory |
|-----------|-------------|------------------|
| Rails | `config/routes.rb` | `public/` |
| Next.js | `next.config.*` | `public/` |
| Gatsby | `gatsby-config.*` | `static/` |
| SvelteKit | `svelte.config.*` | `static/` |
| Astro | `astro.config.*` | `public/` |
| Hugo | `hugo.toml` or `hugo.yaml` | `static/` |
| Jekyll | `_config.yml` | Root directory |
| Vite | `vite.config.*` | `public/` |
| Create React App | `package.json` with `react-scripts` | `public/` |
| Vue CLI | `vue.config.*` | `public/` |
| Angular | `angular.json` | `src/assets/` |
| Eleventy | `.eleventy.js` or `eleventy.config.*` | Root or `_site/` |
| Static HTML | `index.html` in root | Same directory as HTML |

**Priority rule:** If existing favicon files found (`favicon.ico`, `apple-touch-icon.png`), use their location regardless of framework detection.

If uncertain about asset placement → use `AskUserQuestion` to confirm target directory.

### Step 3: Resolve App Name

Check sources in order (use first found):
1. Existing `site.webmanifest` → `name` field
2. `package.json` → `name` field
3. Rails `config/application.rb` → module name
4. Current directory name

Convert to title case for display.

### Step 4: Generate Favicon Assets

Run ImageMagick commands (preserve alpha with `-alpha on -background none`):

```bash
# Multi-resolution ICO (16x16, 32x32, 48x48)
magick "<source>" -alpha on -background none \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  -delete 0 "<target>/favicon.ico"

# PNG variants
magick "<source>" -alpha on -background none -resize 96x96 "<target>/favicon-96x96.png"
magick "<source>" -alpha on -background none -resize 180x180 "<target>/apple-touch-icon.png"
magick "<source>" -alpha on -background none -resize 192x192 "<target>/web-app-manifest-192x192.png"
magick "<source>" -alpha on -background none -resize 512x512 "<target>/web-app-manifest-512x512.png"
```

If source is SVG, also copy directly:
```bash
cp "<source>" "<target>/favicon.svg"
```

### Step 5: Generate/Update Web Manifest

Create or update `site.webmanifest` in target directory.

If exists: preserve `theme_color`, `background_color`, `display` values.

```json
{
  "name": "<app-name>",
  "short_name": "<app-name>",
  "icons": [
    { "src": "/web-app-manifest-192x192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
    { "src": "/web-app-manifest-512x512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ],
  "theme_color": "#ffffff",
  "background_color": "#ffffff",
  "display": "standalone"
}
```

### Step 6: Update HTML Layout

**Rails** → Edit `app/views/layouts/application.html.erb`:

```erb
<link rel="icon" type="image/png" href="/favicon-96x96.png" sizes="96x96" />
<link rel="icon" type="image/svg+xml" href="/favicon.svg" />
<link rel="shortcut icon" href="/favicon.ico" />
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
<meta name="apple-mobile-web-app-title" content="<app-name>" />
<link rel="manifest" href="/site.webmanifest" />
```

**Next.js** → Edit `app/layout.tsx` or `app/layout.js` metadata export:

```typescript
export const metadata = {
  // ... existing metadata
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: '48x48' },
      { url: '/favicon-96x96.png', sizes: '96x96', type: 'image/png' },
      { url: '/favicon.svg', type: 'image/svg+xml' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180' },
    ],
  },
  manifest: '/site.webmanifest',
  appleWebApp: {
    title: '<app-name>',
  },
}
```

**Static HTML** → Edit `index.html` `<head>`:

```html
<link rel="icon" type="image/png" href="/favicon-96x96.png" sizes="96x96" />
<link rel="icon" type="image/svg+xml" href="/favicon.svg" />
<link rel="shortcut icon" href="/favicon.ico" />
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
<meta name="apple-mobile-web-app-title" content="<app-name>" />
<link rel="manifest" href="/site.webmanifest" />
```

**Other/Unknown** → Output HTML snippet for user to add manually.

**Note:** Omit SVG-related tags if source was not SVG format.

### Step 7: Report Summary

```markdown
## Favicon Generation Complete

- **Framework:** <detected-framework>
- **Assets directory:** <target-path>
- **App name:** <resolved-name>

### Generated Files
- favicon.ico (16x16, 32x32, 48x48)
- favicon-96x96.png
- apple-touch-icon.png (180x180)
- web-app-manifest-192x192.png
- web-app-manifest-512x512.png
- site.webmanifest
[- favicon.svg (if source was SVG)]

### Updated Files
- <layout-file-path>

### Overwrites
[List any existing files that were replaced]
```
