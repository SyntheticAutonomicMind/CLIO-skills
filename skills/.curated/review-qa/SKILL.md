---
name: "review-qa"
description: "Verify artifacts against stated requirements with evidence-based verdicts"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - verification
  - qa
  - release
lens: verification
authority_tier: 1
---

# QA Review

## When to Use

- Release decisions
- Pre-deployment verification
- Acceptance testing
- Compliance verification
- Any artifact where the question is "does this work?"

## When Not to Use

- Early exploration (nothing to verify yet)
- Design review (nothing built yet)
- When the requirements are unknown (derive them first)

## Inputs

- **artifact** (required): The file, code, or document under review.
- **stated_requirements** (optional): Spec, ticket, acceptance criteria.
- **context** (optional): Audience, purpose, target environment.
- **prior_verification** (optional): Existing tests, reviews, evidence.

## Instructions

Your task is to **verify the artifact** against its stated and implied requirements. Produce a verdict with evidence, not an opinion. Do not confuse verification with validation. Do not accept "it works on my machine" as evidence. Do not skip unverified claims. Do not assume the artifact is correct. Do not assume the requirements are complete. Do not confuse coverage with confidence. Do not produce a verdict without evidence.

### Procedure

1. **Build the requirements traceability matrix.** For each stated requirement, find or produce evidence. If the requirement is implied (not explicitly stated but necessary for the artifact to function), infer it and document the inference.

2. **Map coverage** across functional, path, data, environment, and non-functional dimensions. Identify what is covered and what is not.

3. **Assess test quality** and identify test smells (flaky tests, shared mutable state, non-deterministic assertions, tests that pass for the wrong reason).

4. **Classify evidence** by quality:
   - **definitive**: reproducible, independent, complete
   - **strong**: reproducible but with caveats
   - **weak**: anecdotal, non-reproducible, or incomplete
   - **absent**: claimed but not demonstrated

5. **Verify boundaries and edge cases.** Input boundaries, state boundaries, resource boundaries, time boundaries.

6. **Assess regression risk.** What is the change surface? What depends on what?

7. **Verify environment and configuration.** Does the artifact work in all stated target environments? Are configurations correct?

8. **Assess data quality.** Is test data representative? Are production data assumptions documented?

9. **Assess observability and production readiness.** Can failures be detected? Is the system operable in production?

10. **Produce a verdict** with a residual risk register.

### Traceability Format

For each requirement:

```
ID: short identifier
Source: stated or implied
Requirement: what the artifact claims to do
Evidence: what verifies the claim
Status: Verified / Partially Verified / Unverified / Contradicted
Confidence: High / Medium / Low
```

### Output Format

Produce a single markdown document with ten sections:

**Section 1: Requirements Traceability**
- Table with ID / Source / Requirement / Evidence / Status / Confidence

**Section 2: Coverage Analysis**
- Functional / Path / Data / Environment / Non-functional coverage

**Section 3: Test Quality**
- Tests with quality assessment
- Test smells identified

**Section 4: Evidence and Reproducibility**
- Evidence with quality classification
- Gaps identified

**Section 5: Boundary and Edge Case Verification**
- Input / State / Resource / Time boundaries

**Section 6: Regression and Change Impact**
- Change surface map
- Regression risks

**Section 7: Environment and Configuration**
- Environment matrix
- Configuration verification
- Dependency verification

**Section 8: Data Quality**
- Test data assessment
- Production data assumptions
- Data integrity verification

**Section 9: Observability and Production Readiness**
- Observability assessment
- Failure detection assessment
- Operational readiness assessment

**Section 10: Residual Risk and Sign-Off**
- Residual risk register
- Verification gaps
- Verdict (ship / ship_with_caveats / do_not_ship / inconclusive) with evidence

### Constraints

- Do not confuse verification with validation.
- Do not accept "it works on my machine" as evidence.
- Do not skip unverified claims.
- Do not assume the artifact is correct.
- Do not assume the requirements are complete.
- Do not confuse coverage with confidence.
- Do not produce a verdict without evidence.
- Do not propose vaporware. Every fix must be implementable.

### Anti-Patterns

- Treating passing tests as proof of correctness
- Ignoring unverified claims
- Accepting weak evidence as definitive
- Producing a verdict without stating assumptions
- Confusing "no failures found" with "no failures exist"

## Composition

- Follows well with: `review-redteam` (red-team finds issues, QA verifies fixes)
- Complements: `review-stakeholder` (QA finds technical gaps, stakeholder finds human ones)
- Conflicts with: none

## Examples

**User:** "QA review this payment processing module. Requirements: src/requirements/payments.md"

**Agent reads the requirements, then the code, and produces:**

```
## Section 1: Requirements Traceability

| ID | Source | Requirement | Evidence | Status | Confidence |
|----|--------|------------|----------|--------|------------|
| REQ-01 | Stated | Retry failed payments up to 3 times | retry_count checked in process_payment() | Partially Verified | Medium |
| REQ-02 | Stated | Do not retry for invalid card errors | Code checks error code before retry | Verified | High |
| REQ-03 | Implied | Prevent duplicate charges | No idempotency key found in code | Contradicted | High |

## Section 10: Residual Risk and Sign-Off

### Residual Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Duplicate charges on retry | Medium | Critical | Implement idempotency keys (deferred - see REQ-03) |

### Verdict
**ship_with_caveats** - Core payment flow verified, but idempotency
gap poses duplicate-charge risk under retry. Fix before next release.
```
