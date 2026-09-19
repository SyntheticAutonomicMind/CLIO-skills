---
name: "capability-drift-check"
description: "Periodically verify that model/API/tool capabilities still match cached assumptions"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "web_operations"]
tags:
  - maintenance
  - infrastructure
  - verification
lens: verification
authority_tier: 1
---

# Capability Drift Check

## When to Use

- On session start (if cached verification is stale)
- When a model's capabilities seem to have changed
- Before relying on a capability that was assumed but unverified
- After upgrading or swapping a model provider

Model capabilities (context window, tool support, JSON mode, vision,
function-calling schema) change. The agent's assumptions about its own
tooling rot silently. This skill forces a periodic reconciliation.

## When Not to Use

- The capability cache was verified within the last `max_age_days`
- You are only making changes that don't depend on model capabilities
- The provider being checked is not in active use

## Inputs

- **capability_file** (required): Path to capability cache (default: `.clio/model-capabilities.json`). If the file does not exist, treat it as empty (no cached assumptions — verify everything).
- **max_age_days** (optional): Maximum age before re-verification (default: 14)
- **providers** (optional): List of providers to check (default: all configured)

## Instructions

### Step 1: Trigger

On session start:

1. Attempt to read `.clio/model-capabilities.json`. If the file does not exist, treat it as a fresh cache with no `last_verified` timestamp — proceed to full verification.
2. Check `last_verified` timestamp
3. If age > `max_age_days`: run this skill
4. Else: skip, log "fresh"

### Step 2: Read CLIO configuration

Read CLIO config for currently configured providers. Do not check
providers you do not use.

### Step 3: Check each provider

**ANTHROPIC:**
- docs.anthropic.com/en/docs/about-claude/models
- pricing page (context window sometimes differs by tier)
- release notes for new model versions

**OPENAI:**
- platform.openai.com/docs/models
- changelog

**LOCAL (llama.cpp, ollama, vLLM, etc.):**
- version check of installed runtime
- model card for each loaded model
- context window actually served (may differ from card)

### Step 4: Compare and update

```
MODEL              | CACHED CTX | OBSERVED CTX | CACHED TOOLS | OBSERVED TOOLS
-------------------|------------|--------------|--------------|---------------
claude-sonnet-4.5  | 200K       | 200K         | yes          | yes
gpt-4o             | 128K       | 128K         | yes          | yes
local-qwen-32b     | 32K        | 8K (!)       | yes          | no  (!)
```

For each DIFF:

- Update `.clio/model-capabilities.json`
- Log to long-term memory: "capability change detected"
- If a capability DOWNGRADED (e.g., tools no longer supported), flag
  as WARNING — the agent's current behavior may be invalid.
- If UPGRADED, log as OPPORTUNITY — mention to user.

### Step 5: Set timestamp and commit

Set `last_verified` to today. If the capability file did not exist before, create it with the current state as the initial baseline. Commit the capability file.

## Anti-Patterns

- Checking providers not in use, wasting tokens
- Trusting the model card over the runtime's reported capabilities
- Silently accepting a DOWNGRADE without surfacing it to the user
- Re-checking on every session when the cache is fresh
- Treating this as a code check rather than a judgment call about
  whether prior assumptions are invalidated

## Composition

- Triggered BY: session-start hook
- Referenced by: any skill that depends on model/tool capabilities

## Examples

**Session start** — capability cache is 18 days old (exceeds 14-day max).

**Agent:**
1. Reads `.clio/model-capabilities.json` — last verified: 18 days ago
2. Checks Anthropic docs — `claude-sonnet-4.5` now supports 300K context (was 200K)
3. Checks local runtime — `qwen-32b` model card claims 32K context, but runtime reports 8K
4. Updates cache with new values
5. Logs to LTM: "claude-sonnet-4.5 context upgraded 200K -> 300K" and "qwen-32b context downgraded 32K -> 8K (DOWNGRADE — warn user)"
6. Sets `last_verified` and commits
