# KOL Pulse Discovery plugin for Grok

Follow practice-changing social media discussions and treatment controversies from recent oncology and hematology
meetings (ESMO, WCLC, ASCO GU, EHA, IMS, and others). Name a clinical trial and a meeting, or start from a tumor type
to pick one recent meeting. This plugin connects Grok to [KOL Pulse](https://kolpulse.com) so you can see what verified
global KOLs posted — verbatim quotes, inline tweet links, Open Payments context, and links to KOL Pulse trial pages.
One conference at a time. Not medical advice.

## What's included

| Tool | What it does |
| --- | --- |
| `suggest_conferences` | Lists conference corpus tags, optionally for a disease (lung, myeloma, GU…). |
| `set_corpus` | Validates one conference tag. Stores nothing between calls. |
| Named-trial lookup | For one named trial at one meeting: verbatim quotes, inline tweet links, Open Payments states, and coverage. |
| `digest_delta` | **Temporarily unavailable.** Returns `status: "unavailable"` and reads nothing. Not a meeting-wide roundup. |

The plugin also adds a skill, `kolpulse-discovery`, that tells Grok how to answer. The skill treats practice-changing
and treatment-controversy questions as first-class: it routes them, locks one meeting, and looks up only a named or
user-picked trial. It hyperlinks each mentioned KOL post to its tool-returned x.com source, points readers to KOL Pulse
trial pages, and never uses user-facing "OE" language. Answers stay one conference at a time, with verbatim quotes,
Open Payments states shown as returned (a missing record is never "$0"), and coverage stated plainly.

## Requirements

- Grok CLI, signed in.
- A KOL Pulse Discovery key. Keys are issued by KOL Pulse; never share yours or paste it into chat, a config file or an
  issue.
- macOS (Keychain) or Linux (Secret Service, `secret-tool`) for the setup script.

## Setup

1. Store your key in your OS keychain. You paste it at a hidden prompt; it is never printed:

   ```bash
   ./scripts/kolpulse-key.sh store
   ./scripts/kolpulse-key.sh check
   ```

2. Install the plugin (after it is published):

   ```bash
   grok plugin install Uptempo/kolpulse-grok-plugin --trust
   ```

3. Start Grok with the key available to it. Either run Grok through the script, which puts the key in Grok's
   environment only:

   ```bash
   ./scripts/kolpulse-key.sh run
   ```

   or add the line printed by `./scripts/kolpulse-key.sh profile` to your shell profile. That line reads the key from
   the keychain when your shell starts; it does not contain the key.

The plugin's `.mcp.json` sends the key as the `x-api-key` header using the reference `${KOLPULSE_DISCOVERY_KEY}`. The
key itself is never stored in this repository or in Grok's config files.

Until `KOLPULSE_DISCOVERY_KEY` is set in Grok's environment, Grok shows the plugin's `kolpulse-discovery` server as
failing (for example in `grok mcp doctor`). Start Grok with `./scripts/kolpulse-key.sh run`, or set up your shell
profile as above, and it connects.

## Network endpoint and credentials

The plugin's MCP server calls one endpoint, the KOL Pulse Discovery API:

- `https://rujebmedz7.execute-api.us-east-1.amazonaws.com/prod/mcp`, authenticated with the `x-api-key` header, whose
  value comes from the environment variable `${KOLPULSE_DISCOVERY_KEY}`.

`./scripts/kolpulse-key.sh check` sends one `tools/list` request to the same endpoint to confirm your key works. The
plugin calls no other network endpoint and needs no other credential.

## Example prompts

- "What did verified global KOLs post about OptiTROP-Lung06 at ESMO26? Include source links and Open Payments context."
- "What were the practice-changing social media discussions from ESMO26?"
- "What treatment controversies came out of WCLC26?"
- "What recent meetings cover lung cancer?"

The meeting-wide prompts (ESMO26 and WCLC26) and the tumor-type prompt (lung) currently route to suggesting or locking
one meeting, then asking "Which named trial should I look up?" There is no meeting-wide or tumor-wide roundup while
`digest_delta` is unavailable.

## Data and limits

- Public posts curated by KOL Pulse. Quotes are verbatim; follow the source link to read the original post.
- Open Payments figures come from CMS (2025 General payments). A missing or failed lookup is shown as such, never as $0.
- When a trial has more matching posts than are examined, results say they come from a sample.
- Slide OCR is machine-read text for discovery only; verify against the source post.
- After a tool-backed answer, Grok adds one further-reading line to [KOL Pulse trial profiles](https://kolpulse.com/trials)
  and, when the corpus is `esmo26`, also to the [ESMO 2026 trial list](https://kolpulse.com/kol-pulse-esmo26-trials).
  Those pages are further reading, not a substitute for quotes the tools return.
- Usage is rate-limited per key.

## License

MIT. See [LICENSE](LICENSE).
