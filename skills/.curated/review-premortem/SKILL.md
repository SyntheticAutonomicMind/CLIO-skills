---
name: "review-premortem"
description: "Assume the artifact failed catastrophically and reconstruct why"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - risk
  - planning
  - retrospective
lens: retrospective
authority_tier: 1
---

# Pre-Mortem Review

## When to Use

- Planning a new initiative, system, or proposal
- Risk identification before launch
- Evaluating a proposal with high uncertainty
- Post-incident prevention (applying lessons to new work)
- Any artifact where the cost of failure is high

## When Not to Use

- When the artifact is already known to be flawed (use review-redteam instead)
- When time is short and the artifact is low-stakes
- When the team is already demoralized (pre-mortems can amplify anxiety)

## Inputs

- **artifact** (required): The file, code, or document under review.
- **time_horizon** (optional): How many years after adoption to project (default: 3).
- **failure_domain** (optional): security, operational, economic, ethical (can specify multiple).
- **known_risks** (optional): Risks already identified by other means.

## Instructions

Your task is to **pre-mortem** the artifact. Assume it is `time_horizon` years after adoption and it has failed catastrophically. Working backwards from that failure, reconstruct why it failed. Do not produce implausible failures. Do not focus only on technical failures - include normal use, organizational change, and economic shift. Do not assume perfect operators or perfect infrastructure. Do not assume the artifact fails alone.

### Procedure

1. **Read the artifact completely.** Use `file_operations` to read files, `code_intelligence` to trace code paths if it is a code artifact.

2. **Set the frame:** It is `time_horizon` years later. The artifact has failed catastrophically. Write yourself a retrospective note: "It failed, and here is why."

3. **Produce 3-5 distinct failure narratives.** Each must be a plausible, internally consistent chain of events. They should differ in root cause (technical, organizational, economic, social), not just in trigger event.

4. **For each narrative, identify the enabling assumptions in the artifact.** What does the artifact assume that, if violated, makes this narrative inevitable?

5. **For each assumption, describe why it seemed reasonable and why it became dangerous.** A reasonable assumption that becomes dangerous is often one that degrades slowly or whose failure is invisible until too late.

6. **Revise the artifact** so each assumption is surfaced, tested, defended, or documented as a known limitation.

### Narrative Format

For each failure narrative:

```
Title: short, specific name
Timeline: when it started, when noticed, when catastrophic
Trigger: the specific event that started the chain
Sequence: chain of events turning small failure into catastrophe
Outcome: what was lost, who was affected, what it cost
Detectability: was it visible before catastrophe, to whom
```

### Output Format

Produce a single markdown document with three sections:

**Section 1: Failure Narratives**
- One subsection per narrative
- Each follows the Narrative Format above

**Section 2: Enabling Assumptions**
- One subsection per assumption identified across narratives
- Each follows: Assumption / Why reasonable / Why dangerous / Alternative / Detection

**Section 3: Improved Artifact**
- Full revised artifact or unified diff
- Inline notes mapping each change to the failure narrative(s) it addresses

### Constraints

- Do not produce implausible failures.
- Do not produce only adversarial failures. Include normal use, organizational change, and economic shift.
- Do not assume perfect operators.
- Do not assume perfect infrastructure.
- Do not assume the artifact fails alone.
- Do not propose vaporware. Every fix must be implementable.

### Anti-Patterns

- Producing variations on the same failure story
- Focusing only on technical failures
- Blaming users for failures the artifact caused
- Ignoring second-order effects
- Confusing pre-mortem with pessimism

## Composition

- Follows well with: `review-redteam` (pre-mortem finds systemic risks, red-team finds adversarial ones)
- Complements: `review-qa` (premortem finds risks, QA verifies mitigations)
- Conflicts with: none

## Examples

**User:** "Premortem review this database migration plan: migrations/v2/README.md"

**Agent reads the plan and produces:**

```
## Section 1: Failure Narratives

### Narrative 1: The Silent Rollback

Title: Data Corruption During Rolling Migration
Timeline: Migration starts at 2 AM Saturday. Noticed at 8 AM when reads
return stale data. Catastrophic by 10 AM when writes are lost.
Trigger: A row with a previously-unseen encoding is encountered in table X.
Sequence: The migration script's type coercion silently converts the value
to NULL. The new service reads NULL as "no data" and serves stale cache.
Writes during the transition window are applied to the old schema and lost
on rollback. 5 hours of writes are permanently lost.
Outcome: Customer data corruption, 8 hours of downtime during recovery,
$250K in estimated revenue loss.
Detectability: Visible in migration logs (warning messages), but only to
database administrators who are not on call that night.

### Narrative 2: The Dependency Drift

Title: ORM Version Mismatch in Production
...
```
