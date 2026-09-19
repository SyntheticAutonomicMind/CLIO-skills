---
name: "review-compose"
description: "Run multiple review lenses in one pass and synthesize a composite verdict"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - composite
  - meta
  - multi-lens
lens: meta
authority_tier: 1
---

# Composite Review

## When to Use

- High-stakes artifacts where one lens is not enough
- Pre-release reviews of critical systems
- Post-incident analysis of complex failures
- Any artifact where the cost of missing a flaw is high

## When Not to Use

- Routine reviews (one lens is sufficient)
- When time is short
- When the artifact is small and clear

## Inputs

- **artifact** (required): The file, code, or document under review.
- **lenses** (required): The list of lens IDs to compose (e.g., `review-redteam`, `review-premortem`, `review-qa`).
- **context** (optional): Audience, purpose, constraints, prior discussion.
- **synthesis_mode** (optional): `parallel` (independent) or `sequential` (each lens sees the previous). Default: `parallel`.

## Instructions

Your task is to **run multiple review lenses in one pass** and synthesize their findings into a composite verdict. Do not merge findings into an average. Preserve each lens's distinct perspective. Do not resolve conflicts by majority vote. State the conflict and let the reader decide. Do not assume more lenses is better. Do not run lenses that conflict without acknowledging the conflict.

### Procedure

1. **Read the artifact completely.** Use `file_operations` and `code_intelligence` to read all relevant files.

2. **For each lens in the `lenses` list**, run the corresponding review skill. Only single-lens skills should be composed — do not include `review-code` or `review-document` here, as they are themselves composite and already run multiple lenses. Use them directly instead of composing them through this skill:
   - `review-redteam`: Find exploitable attack surfaces and failure chains
   - `review-premortem`: Assume catastrophic failure and reconstruct why
   - `review-firstprinciples`: Design from scratch and find accidental complexity
   - `review-stakeholder`: Map human experiences across the lifecycle
   - `review-qa`: Verify against requirements with evidence

3. **Collect the findings** from each lens. Each lens produces its own structured critique.

4. **Identify overlaps** - findings that appear in multiple lenses (same issue, different framing).

5. **Identify conflicts** - findings that contradict each other (e.g., red-team says "remove this validation layer" while stakeholder says "this layer protects a real boundary condition").

6. **Identify gaps** - issues found by only one lens that the others missed. Assess whether other lenses should have found them.

7. **Synthesize into a composite verdict** that preserves each lens's perspective.

### Recommended Combinations

Run these combinations with the `review-compose` skill:

**Full review** (high-stakes, time available):
```yaml
lenses:
  - review-redteam
  - review-premortem
  - review-qa
```

**Security focused** (security-critical artifact):
```yaml
lenses:
  - review-redteam
  - review-premortem
  - review-qa
```

**Human focused** (policy, UX, ethics review):
```yaml
lenses:
  - review-stakeholder
  - review-premortem
```

**Simplification focused** (refactoring, technical debt):
```yaml
lenses:
  - review-firstprinciples
  - review-qa
```

**Release gate** (pre-release verification):
```yaml
lenses:
  - review-qa
  - review-redteam
```

### Composition Modes

1. **Parallel:** Each lens sees only the artifact. Use when lenses are independent (e.g., red-team and stakeholder).

2. **Sequential:** Each lens sees the artifact and the previous lens's findings. Use when lenses build on each other (e.g., steelman then premortem).

3. **Nested:** A lens's output becomes another lens's input. Use when one lens produces an artifact the next lens reviews (e.g., red-team produces a revised artifact, QA verifies it).

### Output Format

Produce a single markdown document with five sections:

**Section 1: Per-Lens Findings**
- One subsection per lens
- Each lens's findings, presented unchanged in structure (including "No issues found" sections where applicable)

**Section 2: Overlap Analysis**
- Findings that appear in multiple lenses
- Same issue, different framing - consolidate the perspective

**Section 3: Conflict Analysis**
- Findings that contradict each other
- State the conflict, the reasoning of each lens, and any resolution or escalation needed

**Section 4: Gap Analysis**
- Issues found by only one lens
- Assessment of whether other lenses should have found them

**Section 5: Composite Verdict**
- Verdict: Ship / Ship with caveats / Do not ship / Inconclusive
- Evidence and reasoning from all lenses
- Residual risk register
- Recommended next steps

### Constraints

- Do not merge findings into an average. Preserve each lens's distinct perspective.
- Do not resolve conflicts by majority vote. State the conflict and let the reader decide.
- Do not assume more lenses is better. Each lens costs time and attention.
- Do not run lenses that conflict without acknowledging the conflict.
- Do not produce a verdict without evidence from the lenses.

### Anti-Patterns

- Running every lens on every artifact
- Merging findings without noting their source
- Resolving conflicts without evidence
- Treating the composite verdict as more authoritative than the individual verdicts
- Missing the forest for the trees
- Forcing findings when a lens produces none (zero findings per dimension is valid)

## Composition

- Composes: any combination of single-lens skills
- Cannot be composed with: itself, or with review-code / review-document (those are composite skills that should be invoked directly)

## Examples

**User:** "Composite review of our auth service. Use red-team and QA."

**Agent loads review-redteam and review-qa, runs both against the code, and produces:**

```
## Section 1: Per-Lens Findings

### review-redteam

[Full red-team critique - 12 dimensions]

### review-qa

[Full QA review - 10 sections]

## Section 2: Overlap Analysis

1. Finding: SQL injection in auth.py:23
   - Red-team: Critical security issue
   - QA: Verbatim contradiction of REQ-05 "no injection vulnerabilities"
   - Status: Confirmed, high confidence

## Section 3: Conflict Analysis

1. No conflicts between red-team and QA findings.

## Section 4: Gap Analysis

1. Edge case: token expiration boundary
   - Found by: review-redteam (Security dimension)
   - Missed by: review-qa (no explicit test for expired token on refresh)
   - Assessment: QA should have covered this in boundary verification

## Section 5: Composite Verdict

**Do not ship** - SQL injection vulnerability is Critical and confirmed
by both lenses. Fix before any release.
```
