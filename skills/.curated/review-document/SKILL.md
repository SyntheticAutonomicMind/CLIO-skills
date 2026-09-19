---
name: "review-document"
description: "Composite document review across twelve dimensions, producing critique and improved document"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - composite
  - document
  - review
lens: composite
authority_tier: 1
---

# Generic Document Review

## When to Use

- Reviewing a policy, strategy, research paper, or proposal
- Any document where the question is "is this good?"
- Preparing a document for publication or adoption

## When Not to Use

- When a single-lens review is sufficient (use review-redteam, review-stakeholder, etc.)
- When the document is a trivial memo or note

## Inputs

- **document** (required): The full document text or a path to read it.
- **context** (optional): Audience, purpose, constraints, prior art.
- **reviewer_role** (optional): Domain expertise to bring (e.g., security, legal, product).

## Instructions

Your task is to **review the document across twelve dimensions**. For each dimension, identify specific, concrete weaknesses where they exist. A dimension with zero findings is a valid result — do not fabricate weaknesses to meet a quota. For each weakness, state: the claim the document makes or assumes, how and why it fails, the severity, and a concrete fix. Focus on identifying issues rather than praising the document. Do not propose vaporware. Every fix must be implementable. Do not assume infinite resources, perfect humans, or perfect AI. Do not confuse criticism with cynicism.

### Procedure

1. **Read the document completely.** Use `file_operations` to read the file if a path is provided.

2. **For each of the twelve dimensions below**, identify specific, concrete weaknesses where they exist. A dimension with zero findings is a valid result — do not fabricate weaknesses to meet a quota. Cite exact sections, paragraphs, or statements. Do not be vague.

3. **For each weakness, state:**
   - **Location:** section heading, paragraph, or statement
   - **Claim:** what the document says or assumes
   - **Mechanism of failure:** how and why it fails
   - **Severity:** Critical / High / Medium / Low
   - **Suggested fix:** a concrete, implementable correction

4. **Produce a revised document** addressing the Critical and High severity issues (and Medium/Low where practical, or explain why deferred).

### The Twelve Dimensions

1. **Problem framing and assumptions** - Is the problem well-defined? Are hidden assumptions exposed?
2. **Clarity and precision** - Does the document communicate unambiguously? Are terms defined?
3. **Completeness and coverage** - Is anything material omitted? Are edge cases addressed?
4. **Feasibility and implementation** - Can what is proposed actually be done with available resources?
5. **Risks and failure modes** - Are failure scenarios considered? Are risks quantified?
6. **Security and privacy** - Are data, access, and confidentiality addressed?
7. **Economics and sustainability** - Is the cost model realistic? Is it viable long-term?
8. **Human factors and operations** - How do people actually use it? Are failure scenarios human-tractable?
9. **Alternatives and trade-offs** - Were alternatives considered? Are trade-offs explicit?
10. **Measurement and verification** - Can success be measured? Are success criteria defined?
11. **Governance and compliance** - Are responsibilities, approvals, and regulations addressed?
12. **Ethics and externalities** - Are unintended consequences considered? Who benefits and who is harmed?

### Output Format

Produce a single markdown document with two sections:

**Section 1: Critique**
- Organized by dimension (all twelve; dimensions with no findings should say "No issues found")
- Numbered weaknesses
- Each issue: Location / Claim / Mechanism of failure / Severity / Suggested fix

**Section 2: Improved Document**
- Complete revised document
- Same structure as original where possible
- Specific mechanisms, not just principles
- Inline notes marking where each major fix was applied

### Constraints

- Focus on identifying issues rather than praising the document.
- Do not propose vaporware. Every fix must be implementable.
- Do not hand-wave. Cite specific statements.
- Do not assume infinite resources, perfect humans, or perfect AI.
- Do not confuse criticism with cynicism.
- Do not ignore omissions (what the document does not say).
- Do not propose changes that require reading the document in a different context than provided.

### Anti-Patterns

- Reviewing only the surface (grammar, formatting)
- Missing structural flaws while nitpicking details
- Assuming the document's framing is correct
- Producing generic feedback that applies to any document
- **Hardcoding counts that go stale** — embedding specific numbers (e.g., "6 skills", "11 modules") in documentation prose. These become incorrect as the artifact evolves, misleading readers and agents alike. Reference dynamic sources or use ranges instead.

## Composition

- Follows well with: `review-qa` (to verify the revised document)
- Can be replaced by: any single-lens skill, if the review is focused
- Complements: `review-code` (for artifacts that include both prose and code)

## Examples

**User:** "Document review this product spec: specs/mobile-app-v2.md"

**Agent reads the spec and produces:**

```
## Section 1: Critique

### Dimension 1: Problem framing and assumptions

1. Location: Executive Summary, line 5
   Claim: "Users open the app 3x daily"
   Mechanism of failure: Analytics from v1 show 1.4x daily average, and
   this is never cited or justified. The entire monetization model rests
   on this figure.
   Severity: Critical
   Suggested fix: Cite the source or re-model revenue around actual usage.

### Dimension 2: Clarity and precision

1. Location: Section 3.2 "Smart Notifications"
   Claim: "Notifications are smart"
   Mechanism of failure: "Smart" is never defined. Stakeholders will
   interpret differently - some expect ML personalization, others expect
   basic time-based filtering.
   Severity: High
   Suggested fix: Define criteria: "Notifications are 'smart' if they
   use reading history to predict relevance, with >70% precision as
   measured by manual review."

...

## Section 2: Improved Document

[Full revised document with specific mechanisms]
```
