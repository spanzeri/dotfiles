---
name: strata-ops
description: Operate and tune the local Strata server — which config is live, profiles, presets, sweeps, logs. Use when configuring or debugging Strata itself, not code running on it.
---

# Strata ops

Strata is Sam's local inference engine, served on `127.0.0.1:8080`, model `qwen3.8-flash-next-iq3_xxs` (125B MoE, IQ3_XXS) on an RTX 4070 Ti. Prefer the `strata` CLI over editing files by hand: it validates, keeps revisions, and journals what it did.

## First: which config is actually live

There are two layers, and they are *not* the same file. Getting this wrong means editing a config nothing reads.

| Layer | Path | Holds |
|---|---|---|
| run config | `~/.local/share/strata/install/strata-iq3_xxs.json` | engine exe/args, pack, model paths, `reasoning_effort`, tokenizer, port |
| run config (launch track) | `~/.local/state/strata/launch/dslab-iq3_xxs-128k.json` | same shape, plus kv-resident/conversation-cache/mmap args; this is what `strata launch` and saved profiles use |
| saved profile | `~/.config/strata/profiles/*.json` | only overrides (`host`/`port`/`parallel`) + `source_config` pointer |

Ask the running system, don't guess:

```sh
strata runtime status          # owned instance, owner/instance id, loaded state
strata status                  # one telemetry snapshot
strata profile list --json     # saved profiles -> source_config paths
strata launch --list-presets   # launch presets + when each was tuned
strata launch --preset dslab-iq3_xxs-128k --plan --output json   # effective launch, starts nothing
```

The `--plan` output is the cheapest true answer to "what would run": it pins the profile, `extra` engine args, `tuned_preset`, and the flags string a plain `strata launch` would use.

`run-iq3_xxs.sh` (`exec strata serve --profile <install>/strata-iq3_xxs.json`) serves the **install** config; `strata launch` / `strata runtime` serve the **state/launch** config via the saved profile. A tuning change usually has to land in both. Restart is required — the profile is read at start, not per request.

## Config keys that bite

- `reasoning_effort` at the config top level accepts **`none|low|medium|high` only**. `"xhigh"` makes the server `SystemExit` at startup (`serve/server.py` `clean_shared_defaults`). For the Qwen family `high` *is* `xhigh` (`frontend.EFFORT` maps `high → xhigh`), so write `high`.
- An `--reasoning-effort` flag inside `args` is not an engine option; it is lifted into the config key at startup (and printed). Prefer the key.
- Sampling is **per request**, not in the profile: `temperature`, `top_p`, `top_k`, `min_p`, `presence_penalty` arrive from the client (`~/.pi/agent/models.json` or the app). The engine only has `--seed`, `--top-k`, `--top-p`, `--temperature`; there is no `min_p` engine flag at all.
- `--spec-min-p` is **not** `min_p`. It is the MTP drafter's confidence threshold for extending a verify window.
- `--max-context 131072` is the real context ceiling; the model natively does 262,144. Client `maxTokens` + compaction `reserveTokens` must fit under it.

## CLI map

```sh
strata tune plan|run|apply|rollback|status|list|auto     # bounded engine-config sweep; auto ≈ 20 min
strata presets list|status|show|apply|recheck|off        # saved tuning presets, active one marked *
strata engine calibrate                                  # measure -> review -> apply, with rollback
strata ops list|show|plan|run|runs|result --profile P    # typed operator recipes with a journal
strata profile create|list|show|validate|set|history|rollback
strata models list|inspect|import|move
strata bench run|report|compare|cancel                   # evidence in an absolute output dir
strata doctor | strata components                        # read-only install check
strata logs --source runtime|harness [--follow]          # bounded redacted activity
strata config show | strata connection list              # client-side endpoint/credential origin
```

Mutating paths are two-step on purpose: `plan` → reviewed `--if-*` preconditions → execute. Always take revisions/digests from the plan output; a plan reserves nothing.

## Evidence lives here

- `~/.config/strata/presets/*.json` + `active.json` + `history.jsonl` — tuning results.
- `~/.local/state/strata/launch/<track>.engine.log` and `.tune.json` — engine log and last sweep.
- `~/explore/Strata-data/bench-results/<date>-<gpu>-<hash>/` — `results.json`, `outputs.jsonl`, `README.md`, `provenance/`.
- `~/.config/strata/profiles/<id>.json` — profile revisions live in the store, not in git.

## Read on demand (version-pinned, glob the dir)

```sh
C=$(ls -d ~/.local/share/strata/components/control/*/ | tail -1)
$C/docs/MANAGEMENT_PROTOCOL.md   # typed owner-local actions, exact params, preconditions
$C/docs/TERMINAL_LAUNCH.md       # launch/monitor screens and flags
$C/tools/strata_mcp.py           # MCP server, see below
```

Source of truth for behaviour is the Python in `$C/serve/`: `frontend.py` (request translation, effort table), `server.py` (config validation ~line 9098, shared defaults ~8273), `config.py`. Read a function before believing a doc.

## MCP: exists, and is the wrong tool for this

`$C/tools/strata_mcp.py` is a stdio MCP **server** (`strata_status`, `strata_models`, `strata_install`, `strata_start`, `strata_stop`, `strata_logs`, `strata_benchmark`, `strata_connect_info`). It covers install/lifecycle only — no profiles, tuning or presets — so it adds nothing over the CLI for tweaking. If it is ever registered with pi, use `"exposure": "deferred"` in `~/.pi/agent/mcp.json` so its schemas cost no context until `tool_search` loads one.

## Verify, then report

```sh
strata serve --profile <config> --plan --output json   # validate a config without loading the model
strata doctor
```

A config edit is unverified until either `--plan` passes or the server starts and prints `[strata] thinking level: …`. Do not cold-start a 75 GB model through a 12 GiB card to answer a config question — say it was not load-tested.
