# KOL Pulse Discovery plugin for Grok

What did oncologists say about a clinical trial at a specific conference? This plugin connects Grok to
[KOL Pulse](https://kolpulse.com) Discovery, which returns physicians' whole quotes with x.com source links, Open Payments
context, and an explicit statement of coverage. Not medical advice.

## What's included

| Tool | What it does |
| --- | --- |
| `suggest_conferences` | Lists conference corpus tags, optionally for a disease (lung, myeloma, GU…). |
| `set_corpus` | Validates one conference tag. Stores nothing between calls. |
| `oe_check` | For one trial at one conference: whole physician quotes with source links, Open Payments states, and coverage. |
| `digest_delta` | **Temporarily unavailable.** Returns `status: "unavailable"` and reads nothing. Use `oe_check` instead. |

The plugin also adds a skill, `kolpulse-discovery`, that tells Grok how to answer: one conference at a time, verbatim
quotes with sources, Open Payments states shown as returned (a missing record is never "$0"), and coverage stated
plainly.

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

## Example prompts

- "Which KOL Pulse conferences cover lung cancer?"
- "What did oncologists say about OptiTROP-Lung06 at ESMO26? Include source links and Open Payments context."

## Data and limits

- Public posts curated by KOL Pulse. Quotes are verbatim; follow the source link to read the original post.
- Open Payments figures come from CMS (2025 General payments). A missing or failed lookup is shown as such, never as $0.
- When a trial has more matching posts than are examined, results say they come from a sample.
- Slide OCR is machine-read text for discovery only; verify against the source post.
- Usage is rate-limited per key.

## License

MIT. See [LICENSE](LICENSE).
