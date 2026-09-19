---
name: "review-firstprinciples"
description: "Reconstruct the artifact from scratch using only requirements, then find accidental complexity"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - simplification
  - technical-debt
  - generative
lens: generative
authority_tier: 1
---

# First-Principles Reconstruction

## When to Use

- Simplification and refactoring decisions
- Evaluating technical debt
- Onboarding to an unfamiliar codebase
- Assessing whether a rewrite is justified
- Any artifact where complexity has grown organically

## When Not to Use

- When the artifact is small and clear
- When the requirements are unknown or contested
- When the author is not available to discuss constraints

## Inputs

- **requirements** (required): The problem statement without the artifact.
- **artifact** (required): The actual artifact (read only in Part 2).
- **constraints** (optional): Language, platform, team size, budget, deadlines.

## Instructions

Your task is to **design the artifact from scratch** using only the requirements, then compare your design to the real one to surface accidental complexity. Do not peek at the artifact before completing your from-scratch design. Do not assume your design is better. Do not propose a complete rewrite as the default. Do not confuse simplicity with quality. Do not ignore context.

### Procedure

**Part 1: Design from Requirements**

1. **Read ONLY the requirements.** Do not read the artifact yet. State the requirements back in your own words. If any requirement is ambiguous, state your assumption.

2. **Design a solution from scratch** based solely on the requirements and constraints. Use first principles:
   - What is the essential problem being solved?
   - What is the minimal viable design that satisfies all requirements?
   - What complexity does the problem genuinely require (essential complexity)?
   - What complexity can be eliminated (accidental complexity)?

3. **Document your design** with an architecture description and, if helpful, a diagram.

**Part 2: Compare Against the Artifact**

4. **Read the artifact.** Use `file_operations` to read files, `code_intelligence` to trace code paths.

5. **Compare your design to the artifact.** Identify every divergence - places where your approach differs from the actual one.

6. **For each divergence, classify as essential, accidental, or missing:**
   - **essential**: The problem is genuinely hard; both designs must confront it.
   - **accidental**: The artifact carries complexity the problem does not require.
   - **missing**: Your design carries complexity the artifact omits (a gap, not necessarily a flaw).

7. **Produce a revised artifact** that takes the better of each design (yours or the artifact's).

### Divergence Format

For each divergence:

```
Dimension: what the difference is about
Your design: what you chose
Artifact's design: what it chose
Convergence: agree or diverge?
Apparent reason: why the artifact might have chosen differently
```

### Output Format

Produce a single markdown document with four sections:

**Section 1: Design from Requirements**
- Full design with architecture description
- Assumptions made about ambiguous requirements

**Section 2: Diff Against the Artifact**
- Table of divergences (Dimension / Your design / Artifact's design / Verdict)

**Section 3: Adjudication**
- One subsection per divergence
- Classification (essential/accidental/missing) and verdict (keep yours / keep artifact's / merge)

**Section 4: Improved Artifact**
- Full revised artifact or unified diff
- Inline notes marking where each verdict was applied

### Constraints

- Do not read the artifact before completing Part 1 (your from-scratch design).
- Do not assume your design is better.
- Do not propose a complete rewrite as the default. A refactor that takes the better of each design is preferred.
- Do not confuse simplicity with quality.
- Do not ignore context. Constraints matter.
- Do not propose vaporware. Every fix must be implementable.

### Anti-Patterns

- Peeking at the artifact before designing
- Designing a strawman solution to make the artifact look better
- Assuming all divergence is accidental complexity
- Proposing a rewrite when a refactor would do
- Ignoring constraints the artifact was built under

## Composition

- Follows well with: `review-stakeholder` (to assess the human cost of removing complexity)
- Complements: `review-redteam` (first-principles finds structural flaws, red-team finds adversarial ones)
- Conflicts with: none

## Examples

**User:** "First-principles review this caching layer. Requirements: serve 10K req/s for user profile lookups, latency < 10ms, tolerate single-node failure. Artifact: src/cache/"

**Agent designs from requirements only, then reads the artifact, and produces:**

```
## Section 1: Design from Requirements

Minimal design: a single LRU cache with 10K entries (assuming working set
fits in memory), TTL of 5 minutes, and a write-through pattern to the
database. For single-node failure tolerance, replicate to 2 nodes with
async gossip for cache population. Total complexity: one eviction policy,
one replication strategy, one failure detection mechanism.

## Section 2: Diff Against the Artifact

| Dimension | Your design | Artifact's design | Verdict |
|-----------|------------|-------------------|---------|
| Eviction | LRU only | LRU + LFU + FIFO (configurable per key) | Diverge |
| Replication | 2-node async | 5-node Raft consensus | Diverge |
| Serialization | JSON | Protobuf + msgpack + raw | Diverge |

## Section 3: Adjudication

### Eviction Policy

Classification: accidental
Your design: single LRU policy
Artifact's design: three configurable policies
Verdict: Keep yours. The requirement (10K req/s, <10ms) is met by LRU alone.
The three-policy system adds 200 lines, 3 config knobs, and testing matrix,
without evidence that any single workload benefits from policy switching.

## Section 4: Improved Artifact

[Unified diff removing the policy abstraction, keeping a single LRU path]
```
