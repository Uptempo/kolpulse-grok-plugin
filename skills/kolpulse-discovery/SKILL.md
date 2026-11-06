---
name: kolpulse-discovery
description: |
  Use when the user asks about KOL Pulse or kolpulse.com conference intelligence: what oncologists said about a named clinical trial at a specific conference (for example "what did KOLs say about OptiTROP-Lung06 at ESMO26"), which conference corpora exist for a disease, or the Open Payments context of those physicians. Do not use for general web search, ClinicalTrials.gov lookups, or medical advice.
allowed-tools:
  - mcp__kolpulse-discovery__suggest_conferences
  - mcp__kolpulse-discovery__set_corpus
  - mcp__kolpulse-discovery__oe_check
  - mcp__kolpulse-discovery__digest_delta
---

# KOL Pulse Discovery

KOL Pulse (https://kolpulse.com) curates public posts by oncologists, tagged by conference and clinical trial. This plugin
reads that public content. It is not medical advice.

## Tools

| Need | Tool |
| --- | --- |
| Which conference corpora exist (optionally for a disease such as lung, myeloma, GU) | `suggest_conferences` |
| Check that one conference tag is valid | `set_corpus` (validates only; it stores nothing between calls) |
| What physicians said about one trial at one conference | `oe_check(trial, corpus)` |
| "What's new" across a whole conference | `digest_delta` is **temporarily unavailable** (see below) |

## digest_delta is temporarily unavailable

`digest_delta` currently always returns `status: "unavailable"` and reads nothing. Do not present that as "nothing new".
Tell the user the conference-wide digest is temporarily unavailable, then offer `oe_check` for the specific trials they
care about. If they do not know which trials, call `suggest_conferences` and ask which trial to check.

## Rules for every answer

1. **One conference at a time.** Every `oe_check` call takes exactly one corpus tag (for example `esmo26`). Never combine
   corpora, and never present results from one conference as if they came from another. If the user names no
   conference, ask, or use `suggest_conferences`.
2. **Whole quotes, with sources.** Quote each physician's `text` verbatim and in full. Never paraphrase inside quotation
   marks and never shorten a quote. Give every quote's `sourceTweet` link (x.com) next to it.
3. **Open Payments states.** Show each quote's `opChip` / `opStatus` as returned, with the `opUrl` link when present:
   - `ok`: the label carries the 2025 General payments total.
   - `none_reported_2025`: no 2025 General payments were reported to CMS.
   - `no_cms_record`: no CMS Open Payments record (for example a non-US physician). This is **not** $0.
   - `unavailable`: the CMS lookup failed; say so and suggest retrying later.
   Never turn a missing or unavailable state into "$0", and never imply wrongdoing from a payment.
4. **Coverage.** Report `coverage` and `postsExamined` / `postsInCorpus`. If coverage is not complete, say plainly that
   the quotes come from a sample (the newest posts examined), not from every matching post.
5. **Slide text.** OCR captions are machine-read slide text for discovery only. Never treat them as ground truth; point
   the user to the source post.
6. **No summaries of results.** Do not summarize, characterize or paraphrase trial results (efficacy, safety,
   "positive", "practice-changing") beyond the quotes the tools return. Let the physicians' own words carry the results.
7. If a call fails or returns no posts, say so. Do not fill gaps from memory or other sources.
