---
name: "change-impact-analyzer"
description: "Pre-edit blast radius analysis for signature, interface, or symbol changes"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - architecture
  - safety
  - refactoring
lens: impact
authority_tier: 1
---

# Change Impact Analyzer

## When to Use

- About to change a function signature, class interface, or exported symbol
- Renaming a sub, package, or exported symbol
- Modifying a typedef, struct, or protocol
- Changing a serialized format that crosses a process boundary

A signature change in Memory.pm breaks Agent.pm at runtime, but only
when that path executes. You find out three sessions later. This skill
forces a blast-radius report before any interface-touching edit.

## When Not to Use

- Adding a new function/method (no existing callers to break)
- Fixing a typo in a comment or documentation string
- Changes that are provably isolated (private function, last caller already updated)

## Inputs

- **symbol** (required): The exact symbol being changed (`Package::sub_name`, `Module.ClassName.method`, etc.)
- **symbol_graph_cache** (optional): Path to cached call graph for incremental checks

## Instructions

### Step 1: Identify the symbol

Name the exact symbol: `Package::sub_name`, `Module.ClassName.method`,
or the C++/Swift equivalent.

### Step 2: Check the cache freshness

If `.clio/symbol-graph.json` does not exist, proceed with a full re-scan (no
cache to compare against). If the cache exists, compare it against current HEAD.
If the cache is stale (more than `stale_after_commits` since last build), force
a full re-scan before proceeding. A stale graph produces false negatives, which
are worse than no graph.

### Step 3: Find all usages

Use `list_usages(symbol)` (backed by git grep) across ALL languages in
the repo. Include:

- Direct calls
- Method calls via variable
- String references (Perl `can()`, Python `getattr`, Swift `selector`)
- FFI/binding references (C++ <-> Perl, Swift <-> C)
- Test fixtures that mock the symbol
- Documentation references

### Step 4: Classify the impact

```
CALLER                 | LANGUAGE | IMPACT       | ACTION REQUIRED
-----------------------|----------|--------------|----------------
Agent.pm:220           | Perl     | BREAKS       | update call site
t/memory.t:45          | Perl     | BREAKS       | update test
clio.pl:112            | Perl     | COMPATIBLE   | none
sam/Sources/CLIO.swift | Swift    | UNKNOWN      | manual review
docs/API.md:30         | Markdown | DOCS DRIFT   | update docs
```

### Step 5: Decide

If ANY caller is BREAKS or UNKNOWN:

- STOP. Do not make the edit yet.
- Present the impact table.
- Then choose:
    1. Get user approval to proceed with the full change set, OR
    2. Make a backward-compatible change (add optional param, keep
       alias, introduce new symbol and deprecate old), OR
    3. Abort the change.

If proceeding, make the change and ALL dependent updates in ONE commit.
No partial changes. No "I'll update the callers next session."

### Step 6: Persist

- Updated `.clio/symbol-graph.json` (create the file if it did not exist; create `.clio/` directory if needed)
- Log to long-term memory: "symbol changed, caller count, impact classes"
- If any caller crosses a language boundary, hand off to
  `cross-language-interface-consistency`

## Anti-Patterns

- Relying on the compiler or test suite to find breakage
- Marking a caller UNKNOWN and proceeding anyway
- Splitting the change across multiple commits "to keep commits small"
- Trusting a stale symbol graph
- Grepping only the current language

## Composition

- Triggered BEFORE: any interface-touching edit
- Hands off to: `cross-language-interface-consistency` if boundary callers found
- Followed by: `review-qa` to verify the changes

## Examples

**User:** "I need to add a required `timeout` parameter to `CLIO::Memory::recall_sessions`."

**Agent:**
1. Checks symbol graph cache — fresh (0 commits behind)
2. `list_usages("CLIO::Memory::recall_sessions")` across all Perl files
3. Finds 8 callers: 3 in production code (BREAKS), 3 in tests (BREAKS), 2 in docs (DOCS DRIFT)
4. Also finds Swift FFI binding via `cross-language-interface-consistency` manifest
5. Presents impact table — 6 BREAKS + 1 cross-language handoff
6. Stops and asks user: "This change will break 6 call sites across Perl and Swift. Proceed with full change set?"
