---
name: "probe-engineer"
description: "Hypothesis-driven debugging that blocks instrumentation until a falsifiable hypothesis is formed"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "terminal_operations"]
tags:
  - debugging
  - testing
  - discipline
lens: hypothesis
authority_tier: 1
---

# Probe Engineer

## When to Use

- A reported bug
- A failing test
- Behavior that contradicts documentation or expectation

Even competent agents shotgun-debug: add prints, run, remove prints,
repeat. This burns tokens, invalidates prompt caches, and often finds
the symptom rather than the cause. This skill forces a falsifiable
hypothesis before any instrumentation is added.

## When Not to Use

- The fix is obvious (e.g., a missing `return` statement) and requires no
  investigation
- The bug is already fully understood and you are just applying a known fix

## Inputs

- **problem** (required): The failing test, error message, or observed behavior
  that contradicts expectations.
- **code** (optional): The specific file or function under investigation.

## Instructions

This skill blocks any edit that adds a print statement, log line,
breakpoint, debugger attach, or temporary assertion until the protocol
is satisfied.

### Step 1: Write the hypothesis block

In working notes, in exactly this format:

```
HYPOTHESIS:      <one sentence claim about root cause>
EVIDENCE:        <observed fact that supports this>
FALSIFIER:       <observation that would prove this wrong>
PROBE:           <minimal instrumentation to distinguish the two>
EXPECTED_IF_TRUE:  <what you will see if hypothesis holds>
EXPECTED_IF_FALSE: <what you will see if it doesn't>
```

Always get user acknowledgment before adding any probe instrumentation.
Do not skip this checkpoint. Log the block to `.clio/probes/<session_id>.log`
(if the `.clio/probes/` directory does not exist, create it first).

### Step 2: Add exactly the PROBE

Add exactly the instrumentation described in PROBE. Nothing else.
Do not add "a few more prints to be safe." Do not add a debugger.
Do not modify the code under investigation to make it easier to probe.

### Step 3: Run and record

Run. Record the observed result against EXPECTED_IF_TRUE and
EXPECTED_IF_FALSE.

### Step 4: Decide

- If hypothesis confirmed: remove the probe, proceed to fix.
- If hypothesis falsified: remove the probe, write a NEW hypothesis
  block. Do not adjust the old probe. That is shotgun debugging with
  extra ceremony.

If three consecutive hypotheses are falsified, invoke a sub-agent with
the full probe log. The sub-agent's job is to challenge the framing,
not to form a fourth hypothesis in the same space.

### Step 5: Persist

- `.clio/probes/<session_id>.log` — every hypothesis block and result (create `.clio/probes/` if it does not exist)
- Long-term memory entry on resolution: confirmed hypothesis + evidence

## Anti-Patterns

- Adding multiple prints "just to see what happens"
- Keeping old probes around after they have served their purpose
- Modifying the code being investigated to make probing easier
- Running the full test suite to "narrow it down" before forming a
  hypothesis
- Treating a falsified hypothesis as a partial success ("well, we
  learned something")
- Forming a new hypothesis that is a minor variation of the falsified
  one

## Composition

- Follows well with: `review-qa` (to verify the fix works)
- Can be triggered by: any bug report, failing test, or unexpected behavior

## Examples

**User:** "The login test fails with 'Permission denied' but only on CI, not locally."

**Agent:**
```
HYPOTHESIS: The CI environment is missing a database migration that
            creates the users table.
EVIDENCE:    Local DB has the table; CI runs migrations in a different
            order per .github/workflows/ci.yml
FALSIFIER:   If the CI logs show the users table already exists when
            the error occurs, the migration is not the cause.
PROBE:       Add a print statement before the query that runs
            `SHOW TABLES LIKE 'users'` and logs the result.
EXPECTED_IF_TRUE:  "users" is absent from the table list
EXPECTED_IF_FALSE: "users" is present, meaning the query itself
                    has a different problem
```

Agent runs the probe, sees "users" is present — hypothesis falsified.
Writes a new hypothesis block about connection credentials, probes again.
Third hypothesis is confirmed: CI uses a read-only DB user. Fix applied.
