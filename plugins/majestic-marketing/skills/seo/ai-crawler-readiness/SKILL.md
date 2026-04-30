---
name: ai-crawler-readiness
description: Configure HTTP-layer signals so LLM clients can discover, fetch, and cite your content. Use when setting up a website for AI visibility, auditing robots.txt for AI bots, serving Markdown alternates, adding link headers, or instrumenting AI-referrer analytics. Pairs with llms-txt-builder (file format) and geo-content-optimizer (content patterns).
allowed-tools: Read Write Edit Grep Glob Bash WebFetch WebSearch
---

# AI Crawler Readiness

**Audience:** Developers configuring websites for AI visibility
**Goal:** Make HTML pages discoverable, fetchable, and trackable by LLM clients via standard HTTP signals — not content tricks.

**Related skills:**
- `llms-txt-builder` — generates the `/llms.txt` file content
- `geo-content-optimizer` — content framing for citation
- `schema-architect` — JSON-LD (note: structured data does NOT help LLM citation directly; see Honest Caveats)

## Scope (and what this skill does NOT do)

This skill covers the **HTTP/transport layer**. It does not write content, evaluate fact-density, or generate llms.txt content (delegate those).

| In scope | Out of scope |
|----------|--------------|
| robots.txt allowlist | Marketing copy |
| `.md` shadow routes | llms.txt content (use `llms-txt-builder`) |
| `<link rel="alternate">` tag | Schema.org JSON-LD (use `schema-architect`) |
| HTTP `Link` header | E-E-A-T strategy |
| Content negotiation | Fact-density rewrites |
| AI-referrer analytics | Backlink building |

## The Six Layers

1. **robots.txt** — explicitly allow AI crawlers
2. **`.md` shadow routes** — serve clean Markdown beside HTML
3. **Discovery markup** — `<link>` tag in HTML `<head>`
4. **HTTP discovery** — `Link` response header for headless agents
5. **Content negotiation** — honor `Accept: text/markdown`
6. **Analytics** — instrument AI traffic by User-Agent + Referer

Apply in order. Skipping layer 1 invalidates the rest.

## Tools Required

| Tool | Why |
|------|-----|
| Read / Write / Edit / Grep / Glob | Local repo edits to robots.txt, route handlers, layouts |
| Bash | `curl -I` for `Link` header, `curl -H "Accept: text/markdown"` for content negotiation, `dig -x` for IP reverse-DNS bot verification |
| WebFetch | Pull current operator docs (OpenAI, Anthropic, Google, Apple, Perplexity) — published bot tables change |
| WebSearch | Locate the current operator-published User-Agent reference page when WebFetch alone is insufficient |

If the audit is local-only (no live site to probe), the Bash and Web tools are unused — declare scope at start.

## Layer 1: robots.txt Allowlist

Block-by-default robots.txt invalidates every other layer. Audit first.

**Three orthogonal decisions — do not conflate:**

1. **Search/index crawlers** — drive citation in AI search products. Allow these for visibility.
2. **User-fetch agents** — fetch URLs a logged-in user pasted into ChatGPT/Claude/Perplexity. Allow for runtime answers.
3. **Training crawlers** — collect content for foundation-model training. Separate consent decision; not required for visibility.

Allowing a search bot does NOT allow training, and vice versa. Each bot below sits in exactly one bucket.

**Verify against operator docs before deploying — tokens and policies change.** Use WebFetch on:

- OpenAI: `https://platform.openai.com/docs/bots`
- Anthropic: search current docs site for `ClaudeBot`, `Claude-User`, `Claude-SearchBot`
- Google: `https://developers.google.com/search/docs/crawling-indexing/google-common-crawlers` and overview of `Google-Extended`
- Apple: `https://support.apple.com/en-us/119829`
- Perplexity: `https://docs.perplexity.ai/guides/bots`

**Search / index crawlers (allow for visibility):**

| Bot | User-Agent token | Operator | Notes |
|-----|------------------|----------|-------|
| OAI-SearchBot | `OAI-SearchBot` | OpenAI | ChatGPT Search index |
| Claude-SearchBot | `Claude-SearchBot` | Anthropic | Claude Search index |
| PerplexityBot | `PerplexityBot` | Perplexity | Search index + answers |
| Applebot | `Applebot` | Apple | Crawls webpages for Siri/Spotlight; required for Apple discoverability |
| Googlebot | `Googlebot` | Google | Classic + AI Overviews source (assumed allowed) |
| Bingbot | `Bingbot` | Microsoft | Copilot source (assumed allowed) |

**User-fetch agents (allow for runtime answers):**

| Bot | User-Agent token | Operator | Notes |
|-----|------------------|----------|-------|
| ChatGPT-User | `ChatGPT-User` | OpenAI | Fetches URL pasted by user |
| Claude-User | `Claude-User` | Anthropic | User-initiated fetches |
| Perplexity-User | `Perplexity-User` | Perplexity | User-initiated fetches |

**Training / data-use crawlers (separate opt-in decision):**

| Bot | User-Agent token | Operator | Controls |
|-----|------------------|----------|----------|
| GPTBot | `GPTBot` | OpenAI | Training data collection |
| ClaudeBot | `ClaudeBot` | Anthropic | Training data collection |
| Google-Extended | `Google-Extended` | Google | Gemini training opt-in (token only — not a real crawler) |
| Applebot-Extended | `Applebot-Extended` | Apple | Apple Intelligence training opt-out (token only — not a real crawler; pair with Applebot above) |
| Bytespider | `Bytespider` | ByteDance | Training |
| Meta-ExternalAgent | `Meta-ExternalAgent` | Meta | Training + agents |

**Default visibility template (search + user-fetch only — no training opt-in):**

```
User-agent: OAI-SearchBot
User-agent: Claude-SearchBot
User-agent: PerplexityBot
User-agent: Applebot
User-agent: ChatGPT-User
User-agent: Claude-User
User-agent: Perplexity-User
Allow: /

Sitemap: https://example.com/sitemap.xml
```

**Optional training/data-use opt-in (only if site owner has explicitly consented to model training on their content):**

```
# Add ONLY if you intend to permit training on your content.
# This is a separate decision from visibility.
User-agent: GPTBot
User-agent: ClaudeBot
User-agent: Google-Extended
Allow: /

# To explicitly OPT OUT of Apple Intelligence training while keeping
# Applebot search crawling enabled above:
User-agent: Applebot-Extended
Disallow: /
```

**Audit checklist:**
- For each bot in the three tables, current `robots.txt` reflects the intended bucket decision (visibility vs training)
- `Applebot` (the actual crawler) is allowed if Apple discoverability matters — `Applebot-Extended` alone does NOT crawl
- Training-only tokens (`Google-Extended`, `Applebot-Extended`) are not mistaken for crawlers — they only signal opt-in/opt-out
- WAF / Cloudflare bot fight mode is not silently blocking allowed bots (check edge config separately)
- `Sitemap:` directive present
- No `Crawl-delay` higher than 10 for allowed bots

**Forbidden:** Do NOT serve different `robots.txt` content based on User-Agent. That is cloaking.

## Layer 2: `.md` Shadow Routes

Serve a clean Markdown twin for every primary content URL. HTML pages are typically 80% chrome; Markdown is 100% content, which improves extraction quality and reduces token cost for LLM clients.

**Route convention:**

| HTML URL | Markdown URL |
|----------|--------------|
| `/blog/post-slug` | `/blog/post-slug.md` |
| `/docs/guide` | `/docs/guide.md` |
| `/` | `/index.md` |

**Implementation patterns:**

- **Static site generators (Next.js, Astro, Nuxt, Hugo):** Add a build step that emits `.md` alongside `.html`. Source markdown should already exist for content pages — publish the source, stripped of frontmatter and unrendered components.
- **Server-rendered (Rails, Django, Laravel):** Add a route handler that responds to `.md` extension by rendering the article body through a Markdown serializer (no layout, no nav).
- **CMS-backed:** Expose the raw body field via a `.md` endpoint; do not include sidebar/related-content blocks.

**Markdown content rules:**
- No nav, footer, cookie banners, or analytics scripts in the `.md` payload
- Keep heading hierarchy (`#`, `##`, `###`) identical to HTML
- Preserve canonical URL as a frontmatter line: `<!-- canonical: https://example.com/blog/post-slug -->`
- Convert internal links to absolute URLs
- Inline image `alt` text; do not require image fetches for comprehension

**Content-Type header:** `text/markdown; charset=utf-8`

## Layer 3: Discovery — `<link>` Tag

Every HTML page that has a Markdown twin advertises it in `<head>`:

```html
<link rel="alternate" type="text/markdown" href="/blog/post-slug.md" />
```

- One `<link>` per HTML page, pointing at its own `.md` twin
- Use the same path-relative or absolute URL convention as canonical
- Do not point multiple HTML pages at one shared `.md` (one-to-one only)

## Layer 4: HTTP `Link` Header

Headless fetchers may not parse HTML. Mirror the discovery hint at the protocol level:

```
Link: </blog/post-slug.md>; rel="alternate"; type="text/markdown"
```

- Add to every HTML response that has a `.md` twin
- Configure at the edge (Cloudflare Workers, nginx `add_header`, Rails `response.headers`)
- Multiple `Link` headers are valid; comma-separate values if combining

## Layer 5: Content Negotiation

When a client sends `Accept: text/markdown`, return the `.md` body for the canonical URL — no redirect, no extension required.

**Behavior matrix:**

| Request URL | `Accept` header | Response |
|-------------|-----------------|----------|
| `/blog/post` | `text/html` (or absent) | HTML |
| `/blog/post` | `text/markdown` | Markdown body, status 200 |
| `/blog/post.md` | any | Markdown body, status 200 |

**Vary header:** Include `Vary: Accept` so caches do not serve HTML to a Markdown-requesting client.

**Edge cache rule:** Key cache entries on `(URL, Accept-includes-markdown)` to avoid mixing.

## Layer 6: AI-Referrer Analytics

The article's central honest point: no LLM provider formally commits to reading any of these signals. **Empirical measurement is the only reliable signal.** Instrument the endpoints.

**What to log on every `.md` and `/llms.txt` request:**
- Timestamp
- Path
- `User-Agent` header (full, not parsed)
- `Referer` header
- `Accept` header
- Response status + bytes
- Client IP (for bot verification via reverse-DNS)

**AI-referrer hostnames to bucket:**

| Bucket | Hostname patterns |
|--------|-------------------|
| ChatGPT | `chatgpt.com`, `chat.openai.com` |
| Claude | `claude.ai` |
| Perplexity | `perplexity.ai` |
| Gemini | `gemini.google.com` |
| Copilot | `copilot.microsoft.com` |
| Phind | `phind.com` |
| You.com | `you.com` |

**AI-bot User-Agent buckets:** Match against the User-Agent table in Layer 1.

**Minimum metrics dashboard:**
- Daily fetch count per `(bot bucket, path)`
- Daily user-referral count per `(referrer bucket, path)`
- Top 20 paths by AI traffic (bot + referrer combined)
- 7-day trend per bucket

**Verification:** AI bots can be impersonated. For high-confidence bot identification, reverse-DNS the client IP and forward-confirm — OpenAI, Anthropic, Google, and Perplexity publish IP ranges or PTR records.

## Workflow

1. Declare scope: local-only audit (skip live probes) OR live-site audit (Bash + WebFetch enabled)
2. Refresh the bot tables with WebFetch on operator docs (Layer 1 link list)
3. If live: `curl -sI https://example.com/robots.txt` and parse User-agent / Allow / Disallow blocks
4. Audit `robots.txt` against the three crawler tables — list any bot blocked vs intended bucket
5. Inventory content URLs that should have `.md` twins (blog, docs, landing pages, FAQ)
6. Choose generation strategy per stack (build step vs route handler vs CMS endpoint)
7. Add `<link rel="alternate">` to HTML `<head>` template
8. Add `Link` response header at edge or app layer
9. If live: `curl -sI https://example.com/blog/post` and confirm `Link:` header presence
10. Implement `Accept: text/markdown` content negotiation with `Vary: Accept`
11. If live: `curl -sH "Accept: text/markdown" https://example.com/blog/post` and confirm Markdown body returned
12. Add structured logging on `.md` and `/llms.txt` endpoints; capture User-Agent + Referer
13. Build a minimal dashboard or report; baseline traffic for 14 days before claiming wins
14. Cross-link with `llms-txt-builder` output: `/llms.txt` should reference the `.md` URLs from layer 2

## Honest Caveats

- **No formal LLM commitment:** OpenAI, Anthropic, Google, and Perplexity have not publicly committed to reading `/llms.txt` or `<link rel="alternate" type="text/markdown">`. Treat these as discoverability hedges, not guaranteed citation lift.
- **Empirical signal only:** The single reliable success metric is server-side traffic data — bot fetches and user referrals. Set baselines before changing infra.
- **`/llms-full.txt` may outperform `/llms.txt`:** Mintlify's data shows 3–4× more visits to `/llms-full.txt` (full content) than `/llms.txt` (index). If shipping both, instrument both separately.
- **Schema.org / JSON-LD does not directly drive LLM citation.** It helps Google's classic indexing (and by extension AI Overviews), but no evidence current LLMs parse JSON-LD when answering. Do not over-invest in structured data as a GEO lever.
- **`<meta>` AI tags, HTML comments, and "AI info pages" are unproven.** No evidence any major LLM processes these. Skip them.
- **User-Agent sniffing to serve different content is cloaking.** Forbidden. Serve identical content to all clients; only `Accept`-driven content negotiation is acceptable.

## Output

When invoked, produce an audit report shaped like:

```
AI Crawler Readiness Audit
==========================
Layer 1 robots.txt:     [PASS/FAIL] — N bots allowed, M blocked
Layer 2 .md routes:     [PASS/FAIL] — X/Y content URLs have .md twins
Layer 3 <link> tag:     [PASS/FAIL] — present on N/M pages
Layer 4 Link header:    [PASS/FAIL] — sample HEAD response
Layer 5 negotiation:    [PASS/FAIL] — Accept: text/markdown returns 200
Layer 6 analytics:      [PASS/FAIL] — endpoints instrumented Y/N

Priority Fixes:
1. [specific change]
2. [specific change]
3. [specific change]
```
