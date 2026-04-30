---
name: ai-crawler-readiness
description: Configure HTTP-layer signals so LLM clients can discover, fetch, and cite your content. Use when setting up a website for AI visibility, auditing robots.txt for AI bots, serving Markdown alternates, adding link headers, or instrumenting AI-referrer analytics. Pairs with llms-txt-builder (file format) and geo-content-optimizer (content patterns).
allowed-tools: Read Write Edit Grep Glob
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

## Layer 1: robots.txt Allowlist

Block-by-default robots.txt invalidates every other layer. Audit first.

**Known AI crawler User-Agents (verify before deploying):**

| Bot | User-Agent token | Operator | Purpose |
|-----|------------------|----------|---------|
| GPTBot | `GPTBot` | OpenAI | Training + ChatGPT browsing |
| OAI-SearchBot | `OAI-SearchBot` | OpenAI | ChatGPT Search index |
| ChatGPT-User | `ChatGPT-User` | OpenAI | User-initiated fetches |
| ClaudeBot | `ClaudeBot` | Anthropic | Training |
| Claude-User | `Claude-User` | Anthropic | User-initiated fetches |
| Claude-SearchBot | `Claude-SearchBot` | Anthropic | Claude Search index |
| PerplexityBot | `PerplexityBot` | Perplexity | Index + answers |
| Perplexity-User | `Perplexity-User` | Perplexity | User-initiated fetches |
| Google-Extended | `Google-Extended` | Google | Gemini training opt-in |
| Applebot-Extended | `Applebot-Extended` | Apple | Apple Intelligence training |
| Bytespider | `Bytespider` | ByteDance | Training |
| Meta-ExternalAgent | `Meta-ExternalAgent` | Meta | Training + agents |

**Default-allow template:**

```
User-agent: GPTBot
User-agent: OAI-SearchBot
User-agent: ChatGPT-User
User-agent: ClaudeBot
User-agent: Claude-User
User-agent: Claude-SearchBot
User-agent: PerplexityBot
User-agent: Perplexity-User
User-agent: Google-Extended
User-agent: Applebot-Extended
Allow: /

Sitemap: https://example.com/sitemap.xml
```

**Audit checklist:**
- Current `robots.txt` does not contain `Disallow: /` for any AI bot above (unless intentional)
- WAF / Cloudflare bot fight mode is not silently blocking AI bots (check edge config separately)
- `Sitemap:` directive present
- No `Crawl-delay` higher than 10 for AI bots

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

1. Audit `robots.txt` against the AI crawler table — list any bot blocked by default
2. Inventory content URLs that should have `.md` twins (blog, docs, landing pages, FAQ)
3. Choose generation strategy per stack (build step vs route handler vs CMS endpoint)
4. Add `<link rel="alternate">` to HTML `<head>` template
5. Add `Link` response header at edge or app layer
6. Implement `Accept: text/markdown` content negotiation with `Vary: Accept`
7. Add structured logging on `.md` and `/llms.txt` endpoints; capture User-Agent + Referer
8. Build a minimal dashboard or report; baseline traffic for 14 days before claiming wins
9. Cross-link with `llms-txt-builder` output: `/llms.txt` should reference the `.md` URLs from layer 2

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
