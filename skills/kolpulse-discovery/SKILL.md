---
name: kolpulse-discovery
description: |
  Use for what verified global KOLs posted about a named clinical trial at one oncology or hematology meeting (verbatim quotes, tweet links, Open Payments, KOL Pulse trial pages); which conference corpora exist for a disease or tumor type; and questions like "what were the practice-changing social media discussions at [meeting]?" or "what treatment controversies came out of [meeting]?" Route those, lock one corpus, and look up only named or user-picked trials — do not independently label results practice-changing unless a returned quote uses that language. Not for web search, ClinicalTrials.gov, scraping kolpulse.com, mixing ASCO/ESMO, using native X search as the evidence source, or medical advice.
allowed-tools:
  - mcp__kolpulse-discovery__suggest_conferences
  - mcp__kolpulse-discovery__set_corpus
  - mcp__kolpulse-discovery__oe_check
  - mcp__kolpulse-discovery__digest_delta
---

# KOL Pulse Discovery

KOL Pulse (https://kolpulse.com) curates public posts by verified global KOLs, tagged by conference and clinical trial. This plugin surfaces sourced discussions of named-trial data from one oncology or hematology meeting: verbatim quotes, tweet links, Open Payments context, and links to KOL Pulse trial pages. It reads that public content. It is not medical advice.

Two ways in: the user names a clinical trial and a meeting, or starts from a tumor type to pick one recent meeting. After the meeting is locked, look up what verified global KOLs posted about a named trial — before the user writes or decides.

Do not write that the plugin "surfaces practice-changing discussions" or "identifies breaking data." Do not say "medical meetings" in general. Scope is oncology and hematology only.

Sentences shown to the user must never say "OE", "OE-check", or "OE Desk". The tool name in the table below is for you; do not write it in the answer.

## Tools

| Need | Tool |
| --- | --- |
| Which conference corpora exist (optionally for a disease such as lung, myeloma, GU) | `suggest_conferences` |
| Check that one conference tag is valid | `set_corpus` (validates only; it stores nothing between calls) |
| What verified global KOLs posted about one trial at one conference | `oe_check(trial, corpus)` |
| "What's new" across a whole conference | `digest_delta` is **temporarily unavailable** (see below) |

## digest_delta is temporarily unavailable

`digest_delta` currently always returns `status: "unavailable"` and reads nothing. Do not present that as "nothing new". Tell the user the conference-wide digest is temporarily unavailable.

If they asked what was practice-changing or what treatment controversies came from a meeting and do not name a trial, point them to that meeting's KOL Pulse trial-results page only when you have a confirmed URL (for ESMO 2026: https://kolpulse.com/kol-pulse-esmo26-trials) or to https://kolpulse.com/trials, then ask: "Which named trial should I look up?" Never say "I can run an OE-check." Never say "here are the practice-changing trials" from memory or from that page.

## Practice-changing questions and treatment controversies

Treat practice-changing questions and treatment controversies as first-class requests. Route them as below. Look up only trials the user names or picks. Incomplete paths never skip to a roundup. Lead answers with named clinical trials, not tumor-type headlines.

Do not yourself label a result "practice-changing" unless a returned quote uses that language. Never paraphrase a quote into "this was practice-changing" unless those words appear in the returned quote.

One critical or dissenting post is not a controversy. Present both sides only when returned posts about the same named trial actually disagree. If they do not, say the returned discussion doesn't show a split. Do not invent the other side or pick a winner.

"Social media discussions" means corpus-scoped posts from that locked meeting via the `oe_check` tool, not native X search and not general-web or medical-meeting chatter. For a non-trial topic, ask for the clinical trial name; do not expand the topic.

### Routing

1. **Trial and meeting named.** Lock that one corpus, call `oe_check` for that trial, and return the sourced discussion. Do not re-ask.
2. **Tumor type** (with or without practice-changing or controversy wording; "lung cancer" alone is this path). Call `suggest_conferences` for that disease. Known tags: lung: `wclc26`, `davalung26`, `esmo26`; myeloma: `ims26`, `eha26`; GU: `asco26-gu` (ASCO GU 2026). Never write `asco26` or bare "ASCO" as if an annual ASCO 2026 corpus exists; write `asco26-gu` / "ASCO GU". For an unknown disease, use only what `suggest_conferences` returns (usually `esmo26`). When more than one meeting is returned, the user picks one. Lock that one meeting, then ask "Which named trial should I look up?" Add further reading: the catalog (https://kolpulse.com/trials) always, and the ESMO 2026 list (https://kolpulse.com/kol-pulse-esmo26-trials) only if the locked corpus is `esmo26`. Do not invent a practice-changing or controversy list across meetings, from memory, or from the website.
3. **Meeting named, no trial.** Ask "Which named trial should I look up?" Link the catalog. Link the ESMO 2026 trial list only for `esmo26`.
4. **Trial named, no meeting.** Ask which meeting. Offer `suggest_conferences` only if they also named a tumor type. Do not infer a meeting or a tumor type from the trial name.

### User-facing prompts

When nothing is locked yet, open with this wording:

"I can look up what verified global KOLs posted about a named trial at one meeting — or suggest recent meetings for that tumor type. Which trial and meeting, or which tumor type?"

After a meeting is locked and no trial is named:

"Which named trial should I look up?"

Use "verified global KOLs" for the product and the corpus in listing and canned prompts. On a specific person, do not upgrade a handle to "verified global KOL" as flavor unless the tool result supports it. Name them and link the `sourceTweet`. Open Payments chips stay as returned (US when present).

## Rules for every answer

1. **One conference at a time.** Every lookup takes exactly one corpus tag (for example `esmo26`). Never combine corpora, and never present results from one conference as if they came from another. If the user names no conference, ask, or use `suggest_conferences`.
2. **Whole quotes, with inline tweet links.** Quote each returned `text` verbatim and in full. Never paraphrase inside quotation marks and never shorten a quote. Whenever you mention a KOL post or quote, markdown-link the attribution to that item's tool-returned `sourceTweet` URL (x.com), for example [Jane Doe](https://x.com/...). Never mention a post without that link. Use the exact `sourceTweet` from the tool result — never build an x.com URL from a handle, and never substitute a native-X-search hit. If a physician is named only for Open Payments context and no `sourceTweet` was returned, name them with no tweet link (do not invent one).
3. **Open Payments states.** Show each quote's `opChip` / `opStatus` as returned, with the `opUrl` link when present:
   - `ok`: the label carries the 2025 General payments total.
   - `none_reported_2025`: no 2025 General payments were reported to CMS.
   - `no_cms_record`: no CMS Open Payments record (for example a non-US physician). This is **not** $0.
   - `unavailable`: the CMS lookup failed; say so and suggest retrying later.
   Never turn a missing or unavailable state into "$0", and never imply wrongdoing from a payment.
4. **Coverage.** Report `coverage` and `postsExamined` / `postsInCorpus`. If coverage is not complete, say plainly that the quotes come from a sample (the newest posts examined), not from every matching post.
5. **Slide text.** OCR captions are machine-read slide text for discovery only. Never treat them as ground truth; point the user to the source post.
6. **No summaries of results.** Do not summarize, characterize, or paraphrase trial results (efficacy, safety, "positive", "practice-changing") beyond the quotes the tools return. Let the returned quotes carry the results.
7. If a call fails or returns no posts, say so. Do not fill gaps from memory or other sources. Do not scrape kolpulse.com to fill MCP gaps.
8. **Further reading.** After a tool-backed answer, add one further-reading line at the end (not after every quote). Always link https://kolpulse.com/trials (KOL Pulse trial profiles). Link https://kolpulse.com/kol-pulse-esmo26-trials only when the corpus is `esmo26`. For any other corpus, link the catalog — do not construct `kol-pulse-{corpus}-trials` URLs. Link a specific trial profile (`kol-pulse-trial-profile-…`) only when a tool returned that URL or it was already confirmed this session. Never invent slugs. Website links are further reading, not a substitute if MCP is empty or `digest_delta` is down.
