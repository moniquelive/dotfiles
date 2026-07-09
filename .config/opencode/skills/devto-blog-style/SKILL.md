---
name: devto-blog-style
description: Use ONLY when drafting, revising, or reviewing DEV Community (`dev.to`) technical posts in MoniqueLive's practical, concise, implementation-first style.
---

# Dev.to Blog Style

## Source Material

- Treat the author's notes, code, command output, and project files as the source of truth.
- When style fidelity needs more evidence and network access is available, consult a small sample of posts from `https://dev.to/moniquelive`; do not copy distinctive phrases.
- Use first person only for experiences, decisions, and results supplied by the author or verified from source material.
- Never invent motivations, chronology, commands, outputs, benchmarks, incidents, design rationale, or future plans. Ask about important gaps or mark them with `[TODO: ...]`.

## Voice And Structure

- Start from the concrete problem, annoyance, or useful result when the source material supports it.
- Keep the article practical and implementation-driven. Take the shortest path from context to working code or configuration.
- Prefer short paragraphs, descriptive sections, examples, commands, and small explanations over exhaustive background.
- Use a casual first-person voice, contractions, and direct language without over-polishing.
- Include code or configuration snippets when they clarify usage, and explain the non-obvious parts immediately around them.
- Explain reliability and design choices only when they materially affected the result.
- Avoid generic scene-setting, hype, forced enthusiasm, SEO filler, and repetitive summaries.
- Usually end with a brief result, lesson, limitation, or realistic next step; do not force a closing section onto a very short post.

## DEV Markdown

- Preserve valid existing frontmatter. For a new publication-ready draft, start unpublished:

```yaml
---
title:
published: false
description:
tags:
cover_image:
canonical_url:
series:
---
```

- Never set `published: true` unless explicitly requested.
- Use no more than four relevant comma-separated tags. Use `canonical_url` only when the article was published elsewhere first.
- Do not repeat the title as an H1 in the body; DEV renders it. Begin body sections at H2.
- Use language-tagged code fences, descriptive link text, and alt text that explains meaningful images.
- Keep secrets, private hosts, personal paths, and credentials out of examples; replace them with obvious placeholders.

## Validation

- Verify technical claims, commands, snippets, versions, and links when possible. Clearly identify anything not run or confirmed.
- Check frontmatter syntax, heading order, code-fence languages, image URLs, DEV embeds, unsupported claims, repetition, and accidental secrets.
- Ensure the title and description accurately match the article, then preview in DEV when publication-ready rendering matters.
