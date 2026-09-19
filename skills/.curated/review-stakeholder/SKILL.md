---
name: "review-stakeholder"
description: "Map every stakeholder journey through the artifact to find friction, harm, and misalignment"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - human-centered
  - ux
  - ethics
  - policy
lens: human-centered
authority_tier: 1
---

# Stakeholder Journey Review

## When to Use

- UX and human factors review
- Policy and governance review
- Ethics review
- Any artifact where human impact matters
- Post-incident analysis focused on human causes

## When Not to Use

- Purely technical artifacts with no human interface
- When the stakeholder set is trivially small
- When the goal is purely performance optimization

## Inputs

- **artifact** (required): The file, code, or document under review.
- **context** (optional): Audience, purpose, constraints, prior discussion.
- **known_stakeholders** (optional): Roles you already know about.
- **power_map** (optional): Who has influence over the artifact.

## Instructions

Your task is to **map the experience of every person who touches the artifact** at every stage of its lifecycle. Find where it helps, where it hinders, and where it harms. Do not skip low-power stakeholders. Do not assume stakeholders are rational. Do not assume stakeholders agree with each other. Do not confuse UX with user satisfaction. Do not propose changes that harm one stakeholder to help another without stating the trade-off.

### Procedure

1. **Read the artifact completely.** Use `file_operations` to read files, `code_intelligence` to trace code paths if it is a code artifact.

2. **Enumerate every stakeholder at every lifecycle stage.** Consider the roles below; add or remove as appropriate to context.

3. **For each stakeholder, walk the full journey** across the lifecycle stages. At each stage, ask: What does this stakeholder want? What do they need? What do they actually get? What's missing?

4. **Identify friction and harm moments.** Categorize each as:
   - **confusion**: The stakeholder does not understand something they need to understand.
   - **wasted effort**: The stakeholder does work the artifact should have done.
   - **misaligned incentive**: The artifact rewards behavior that hurts other stakeholders.
   - **harm**: The stakeholder is damaged by the artifact.

5. **Prioritize issues by impact.** Focus on harm and misaligned incentives first.

6. **Revise the artifact** to address the highest-impact issues.

### Stakeholder Roles

- Author (who created the artifact)
- Reviewer (who evaluates it)
- Operator (who runs it in production)
- Maintainer (who keeps it working over time)
- End user (who directly uses it)
- Auditor (who checks compliance, security, ethics)
- Adversary (who seeks to abuse or subvert it)
- Bystander (who is affected indirectly)
- Future owner (who inherits it)

### Journey Stages

- First contact (discovering the artifact)
- Onboarding (getting started, understanding how to use it)
- Daily use (regular interaction)
- Failure modes (when things go wrong)
- Offboarding (handoff, decommission, handoff to future owners)

### Output Format

Produce a single markdown document with four sections:

**Section 1: Stakeholder Map**
- One subsection per stakeholder
- Each: Who / Wants / Fears / Power (influence over the artifact)

**Section 2: Journey per Stakeholder**
- One subsection per stakeholder
- Lifecycle stages with: What happens / What they need / What they get / What's missing

**Section 3: Friction and Harm**
- One subsection per issue
- Each: Stakeholder / Stage / Issue / Root cause / Severity / Fix

**Section 4: Improved Artifact**
- Full revised artifact or unified diff
- Inline notes mapping changes to specific issues addressed

### Constraints

- Do not skip low-power stakeholders.
- Do not assume stakeholders are rational.
- Do not assume stakeholders agree with each other.
- Do not confuse UX with user satisfaction.
- Do not propose changes that harm one stakeholder to help another without stating the trade-off.
- Do not propose vaporware. Every fix must be implementable.

### Anti-Patterns

- Listing only obvious stakeholders (author, user)
- Ignoring the bystander stakeholder
- Assuming the artifact is neutral
- Treating friction as a UX problem when it is a values problem
- Proposing changes that benefit the powerful at the expense of the powerless

## Composition

- Follows well with: `review-firstprinciples` (to assess the cost of removing complexity)
- Complements: `review-qa` (stakeholder finds human issues, QA finds technical ones)
- Conflicts with: none

## Examples

**User:** "Stakeholder review this API documentation: docs/api.md"

**Agent reads the docs and produces:**

```
## Section 1: Stakeholder Map

### End User
Wants: Quick answers to "how do I call this endpoint?"
Fears: Getting rate-limited, breaking their integration
Power: Low - they can't change the API

### New Hire (Developer Onboarding)
Wants: Understand how auth works, what libraries to use
Fears: Making a mistake that breaks production
Power: Low - junior, can't change processes

### Security Auditor
Wants: Explicit auth requirements, rate limit details, PII handling
Fears: Undocumented access patterns, implicit assumptions
Power: High - can block release

## Section 2: Journey per Stakeholder

### New Hire - Onboarding

First contact: Searches docs for "authentication"
  Need: Clear explanation of auth method
  Get: A paragraph mentioning "API keys"
  Missing: No link to the auth guide, no code example

Daily use: Tries first API call
  Need: Copy-pasteable example with correct headers
  Get: Example uses curl without headers
  Missing: Header values, error handling pattern

## Section 3: Friction and Harm

### Issue 1

Stakeholder: New Hire
Stage: Onboarding
Issue: Authentication example omits required headers
Root cause: The example was written for interactive curl testing, not
  copy-paste into code
Severity: High - causes immediate failed attempts, frustration
Fix: Add explicit header examples in Python, JavaScript, and curl

## Section 4: Improved Artifact

[Unified diff adding authentication guide with multi-language examples]
```
