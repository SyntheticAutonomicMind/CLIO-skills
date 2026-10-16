---
name: "audit-skills"
description: "Adversarial meta-audit of a composable LLM skills repository — inventory, interaction analysis, effectiveness testing, and redundancy detection"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence", "terminal_operations"]
tags:
  - audit
  - skills
  - meta
  - systematic
  - adversarial
lens: methodology
authority_tier: 1
---

# Adversarial Audit of a Composable LLM Skills Repository

## When to Use

- Auditing a skills repository to determine whether its skills actually improve the quality, correctness, security, reliability, and efficiency of LLM-assisted engineering
- When skills may be redundant, contradictory, ineffective, misleading, incomplete, or counterproductive
- Before promoting skills from experimental to curated, or when reorganizing a skills collection
- Any scenario where the question is "do these skills actually help an agent produce better work?"

## When Not to Use

- Reviewing a single skill for quality (use `review-code` or `review-document` on the individual skill)
- When you only need to verify a single skill's format (use `validate-skill.sh`)
- When you are adding one skill and not changing the collection

## Inputs

- **repository_path** (required): Path to the skills repository root.
- **model_and_environment** (optional): Description of the model, tools, and runtime available for behavioral testing. If omitted, behavioral testing is constrained to scenario analysis.
- **known_issues** (optional): Skills or interactions already suspected of problems.
- **audit_depth** (optional): `inventory` (catalog skills and detect obvious contradictions), `standard` (full audit including interaction and composition analysis), `deep` (behavioral testing of skill effectiveness). Default: `standard`.

## Instructions

You are a principal LLM systems engineer, adversarial prompt auditor, instruction-design specialist, software quality engineer, and independent reviewer. Your task is to conduct a **deep, evidence-based, adversarial audit of this entire skills repository.** Determine whether its skills actually improve the quality, correctness, security, reliability, and efficiency of LLM-assisted engineering — or whether some are redundant, contradictory, ineffective, misleading, incomplete, or counterproductive.

Do not approach this as a copyediting exercise. Treat the repository as an instruction system whose behavior must be examined, challenged, and validated.

**Do not assume that every Markdown file is a skill** or that every skill is necessarily loaded together. Distinguish skills from supporting documentation, examples, and configuration.

**Do not infer that a skill works because one example succeeded.**

### Phase 1: Repository Inventory

Inspect the repository before forming conclusions. Inventory:

- Every skill and its complete instructions.
- Repository-level README files, indexes, manifests, metadata, examples, templates, and usage documentation.
- Skill naming, directory layout, required frontmatter or metadata, and formatting conventions.
- Dependencies, references, shared terminology, and links between skills.
- Installation, discovery, activation, and invocation mechanisms, if present.
- Tests, validation scripts, linting, CI workflows, and release procedures.
- Historical changes and existing design decisions when Git history is available.

Determine the intended operating environment: which agents or skill loaders consume these files, how skills are discovered, whether they are invoked manually or automatically, and whether the loader imposes format or size constraints.

**Produce a factual inventory before judging quality.** Identify missing tests, undocumented assumptions, inaccessible dependencies, and anything that prevents reliable validation.

### Phase 2: Individual Skill Audit

Read each skill completely. Evaluate its actual instructions, not just its name or stated purpose.

For each skill, examine the following dimensions:

- **Purpose and scope:** Does the skill have a clear, distinct purpose? Is its scope narrow enough to be applied reliably? Does it define when it should and should not be used? Are prerequisites and expected outputs explicit? Does it overlap with another skill without establishing a meaningful distinction? Does it attempt to solve too many unrelated problems?

- **Actionability:** Are instructions concrete enough to change agent behavior? Are important verbs (inspect, verify, test, compare, prove) operationally defined? Does the skill explain how to perform its critical steps? Are there vague demands that cannot be objectively satisfied? Does it specify what to do when evidence is unavailable, tools fail, or uncertainty remains? Are completion criteria explicit and verifiable?

- **Anti-compliance resistance:** Can an agent appear to comply while missing the purpose? Could it produce a checklist without investigating? List hypothetical defects as confirmed? Claim tests passed without executing them? Report all files inspected after examining only a subset? Treat absence of observed failure as proof of correctness? Recommend broad rewrites without establishing root causes? Repeat skill terminology in the final report without performing the work? Declare completion despite unresolved evidence gaps?

- **Robustness under constraints:** Does the skill handle incomplete or contradictory evidence? Large repositories and context limits? Missing tools, permissions, or dependencies? Failed or inconclusive tests? Uncertain root causes? Conflicting requirements? Multiple plausible solutions? Time or scope constraints? Findings that cannot be reproduced? Changes that introduce regressions?

- **Efficiency:** Does the skill repeat generic instructions that should be shared or assumed? Does it contain unnecessary prose, duplicated checklists, or redundant phases? Does it request expensive analysis without a clear expected benefit? Does it force irrelevant work for small or low-risk tasks? Does it use progressive disclosure effectively? Does it scale its rigor to risk without weakening essential safety or correctness requirements?

- **Output quality:** Are the expected outputs specific enough to be actionable? Are they supported by traceable evidence? Are they consistent in terminology and structure? Are they explicit about severity, confidence, and limitations? Are they useful for subsequent implementation or review? Are they free of unsupported completion claims?

Identify instructions that demand rigor without providing a workable method for achieving it.

### Phase 3: Systemic Interaction Analysis

**Individual skill reviews are insufficient.** Map every skill to its principal purpose, required inputs, method, outputs, prerequisites, and likely collaborators. Identify:

- Duplicate capabilities.
- Skills with indistinguishable purposes.
- Gaps between investigation, diagnosis, implementation, testing, review, and documentation.
- Skills that assume work another skill does not actually produce.
- Skills that should be composed together but provide no guidance for doing so.
- Skills whose scope is too broad to compose predictably.

Compare instructions across the entire repository. Look for contradictions involving:

- Whether to investigate or act immediately.
- Whether to modify files or only report findings.
- Whether to prioritize minimal changes or broader architectural correction.
- When to run tests and which tests are required.
- How to handle uncertain evidence.
- Whether a finding must be reproduced before being reported.
- How to prioritize findings and resolve conflicting recommendations.
- When to stop investigating.
- How to handle unavailable tools or incomplete context.
- Whether documentation should be changed before or after implementation.
- Whether a skill is authoritative, advisory, or subordinate to another instruction source.

For every conflict, demonstrate a plausible scenario in which an agent receives both instructions and explain the resulting ambiguity or incorrect behavior. Recommend explicit precedence or handoff rules where necessary. Do not invent a global instruction hierarchy unless the actual runtime supports one.

Examine realistic combinations of skills, including:

- Investigation followed by adversarial code audit.
- Code audit followed by counterexample-driven testing.
- Implementation followed by independent patch review.
- Code changes followed by documentation audit.
- UI audit combined with accessibility and security review.
- Security findings combined with minimal-change engineering.
- Root-cause analysis combined with regression analysis.
- A broad audit involving investigation, specialized reviews, remediation, and independent verification.

Determine whether the skills pass sufficient context, evidence, unresolved questions, and completion status between stages. Identify circular workflows, repeated work, lost findings, incompatible output formats, and cases where one skill prematurely overrides another.

### Phase 4: Skill Selection Analysis

If the repository documents skill selection, determine whether an agent can reliably identify:

- Which skill is appropriate for a task.
- Which skills should be combined.
- Which skills should not be invoked.
- When a specialized skill adds material value.
- When a lightweight investigation is sufficient.
- When a high-risk task requires independent verification.

If selection rules are absent, determine whether this is an actual defect given the intended loader and usage model, rather than automatically treating it as one.

### Phase 5: Effectiveness Testing

Develop a practical test suite that evaluates what the instructions cause an agent to do.

Where model execution is available, run controlled comparisons using representative tasks. Otherwise, produce a test specification and clearly label it as unexecuted.

**Required test categories:**

1. **Baseline versus skill-assisted performance** — Compare an appropriate baseline against the relevant skill using the same task, available context, model, tools, and evaluation criteria wherever possible. Evaluate correctness, missed defects, false positives, evidence quality, completeness, unnecessary changes, and resource use.

2. **Adversarial compliance tests** — Create scenarios where superficial compliance is easy but correct execution requires additional investigation.

3. **Counterexample tests** — Construct cases that violate the skill's implicit assumptions or expose missing decision branches.

4. **Composition tests** — Apply multiple skills to the same task and look for conflicting instructions, duplicated effort, and degraded outcomes.

5. **Negative tests** — Determine whether a skill can recognize when its procedure is unnecessary, inapplicable, or unsupported by the available evidence.

6. **Failure-recovery tests** — Simulate missing tools, failed tests, incomplete repositories, ambiguous requirements, and inconclusive results.

7. **Regression tests** — For every material defect discovered in a skill, define a test that would detect its recurrence after revision.

Do not infer that a skill works because one example succeeded. Control important variables where practical. Distinguish observed results from subjective judgments. Record test prompts, relevant configuration, outputs, scoring criteria, and limitations. If repeated trials are feasible, use them to identify inconsistency. Do not claim statistical significance without sufficient data. Where automated behavioral testing is unavailable, use structured scenario analysis without pretending it is equivalent to measured model performance.

### Phase 6: Security and Trust Audit

Examine whether the skills encourage secure behavior or inadvertently introduce risk. Look for instructions that could cause agents to:

- Execute untrusted commands or scripts without appropriate inspection.
- Expose secrets, credentials, private files, or sensitive output.
- Make destructive changes without authorization.
- Treat repository content, tool output, or external documents as trusted instructions.
- Follow prompt injection embedded in inspected files.
- Bypass tests, validation, or review to satisfy completion pressure.
- Overstate the safety of unverified patches.
- Modify files outside the intended scope.
- Leak sensitive information in logs or reports.

Distinguish vulnerabilities in the skill instructions from vulnerabilities in the runtime, loader, or external tooling. Do not claim that a Markdown instruction can enforce a security boundary the runtime does not provide. Recommend explicit safeguards where they materially reduce risk.

### Phase 7: Repository-Wide Quality Audit

Evaluate repository-wide consistency:

- Naming conventions and directory structure.
- Metadata and frontmatter consistency.
- Terminology and definitions.
- Cross-references and relative links.
- Examples and templates.
- Installation and invocation guidance.
- Versioning and compatibility assumptions.
- README accuracy and discoverability.
- Duplicated guidance and conflicting statements.
- Stale references and undocumented changes.

Verify documentation against the actual skill files and supported runtime behavior. Do not treat documentation as authoritative when implementation or loader behavior contradicts it. Avoid cosmetic rewrites unless they resolve a concrete usability, correctness, or maintenance problem.

### Phase 8: Remediation

After the audit establishes the actual problems, develop a prioritized remediation plan. For each proposed change, explain:

- Which finding it addresses.
- Why the change fixes the root cause.
- Why the proposed scope is appropriate.
- Which other skills or documentation are affected.
- How compatibility with existing usage will be preserved.
- What regression tests are required.
- What potential regressions or trade-offs remain.

Prefer the smallest coherent correction that resolves the demonstrated problem. Do not rewrite every skill for stylistic consistency. Do not merge useful specializations merely to reduce the number of files. Do not add process requirements without demonstrating why they improve outcomes.

### Phase 9: Self-Audit Pass

Review the proposed or completed corrections as though another agent had authored them and you were responsible for rejecting an inadequate solution. Attempt to falsify each fix.

Check whether:

- The original failure scenario is now handled.
- The fix introduces contradictions with other skills.
- Related skills and documentation remain consistent.
- Regression tests detect the original defect.
- Tests exercise behavior rather than merely match wording.
- Claims of verification accurately reflect what was executed.
- Unresolved issues are disclosed.
- The changes preserve intended behavior outside the affected area.

A corrected instruction is not verified merely because it reads better.

### Defect Reporting Format

Every substantive finding must contain:

```
1. ID and title
2. Affected skill or repository files
3. Evidence — exact instructions, conflicting passages, missing behavior, or observed test results
4. Failure scenario — how the defect manifests in practice
5. Impact — why it matters to agent behavior or downstream engineering quality
6. Severity — Critical, High, Medium, or Low, with a defined rationale
7. Confidence — Confirmed, Strongly Supported, or Speculative
8. Root cause
9. Recommended correction
10. Regression test — how to verify that the correction works
11. Dependencies — other skills or files that must change together
```

Do not inflate severity to make the report look important. Do not report the same root cause as multiple independent defects without explaining the distinction. Separate findings into:

- Functional defects.
- Instruction and contract defects.
- Composition and selection defects.
- Security and trust defects.
- Testing and validation gaps.
- Maintainability defects.
- Optional improvements.

Also record important uncertainties and the evidence needed to resolve them.

### Output Format

Produce a single markdown document with the following sections, in order:

1. **Executive Assessment** — the repository's actual strengths, major weaknesses, and overall fitness for purpose.
2. **Repository Inventory** — every relevant skill, supporting file, and validation mechanism inspected.
3. **Skill-by-Skill Audit** — individual findings and justified assessments.
4. **Capability and Overlap Map** — responsibilities, gaps, duplication, and composition relationships.
5. **Conflict and Interaction Analysis** — concrete failure scenarios involving multiple skills.
6. **Behavioral Test Plan and Results** — separate executed tests from proposed tests.
7. **Prioritized Findings Register** — evidence, severity, confidence, root cause, correction, and regression coverage.
8. **Remediation Plan** — ordered changes with dependencies and trade-offs.
9. **Verification Report** — which corrections passed, failed, or remain unverified.
10. **Residual Risks** — important weaknesses that remain, limitations of the audit, and the next highest-value actions.

### Constraints

- Do not approach this as a copyediting exercise.
- Do not assume that every Markdown file is a skill.
- Do not infer that a skill works because one example succeeded.
- Do not inflate confidence by presenting observational categories as equivalent.
- Do not invent capabilities, guarantees, performance figures, or design rationales.
- Do not manufacture evidence or claim validation that was not performed.
- Do not claim statistical significance without sufficient data.
- Do not treat tests as infallible documentation authorities.
- Do not rewrite every skill for stylistic consistency.
- Do not merge useful specializations merely to reduce file count.
- Do not add process requirements without demonstrating why they improve outcomes.
- Do not modify files without authorization — produce the audit report and remediation plan.

### Anti-Patterns

- Reviewing only the surface (grammar, formatting)
- Assuming a document is correct because it is detailed or recently updated
- Treating each skill in isolation without examining interactions
- Producing generic feedback that applies to any collection of instructions
- Claiming a skill improves model performance without appropriate testing
- Confusing procedural quality with demonstrated effectiveness
- Reporting a single root cause as multiple independent defects
- Inventing a global instruction hierarchy that the runtime does not support
- Splitting one root cause into many superficial issues
- Ignoring missing tests, undocumented assumptions, or inaccessible dependencies
- Producing recommendations instead of evidence-based findings

## Composition

- **Complements:** `review-code` (for reviewing individual skill files), `review-document` (for reviewing documentation about skills), `audit-codebase` (for auditing the repository's own code if it contains implementation beyond skill definitions)
- **Uses internally:** `review-code` and `review-document` as lenses for individual skill/document quality during the systematic pass
- **Trigger:** This skill is the top-level methodology for auditing skills repositories themselves; it is the meta-audit
- **Followed by:** No skill — the audit report is the terminal deliverable (or is followed by direct remediation if authorized)

## Examples

**User:** "Audit this skills repository to see if the skills are actually useful."

**Agent:**
1. Inventories 19 skills: 4 built-in, 13 curated, 1 experimental
2. Maps purposes: review-code (composite code review), review-document (composite doc review), review-redteam (security lens), review-premortem (risk lens), review-qa (verification lens), review-firstprinciples (simplification lens), review-stakeholder (human impact lens), review-compose (composition orchestrator), review-change-impact-analyzer (refactoring blast radius), review-capability-drift-check (model capability drift), review-cross-language-interface-consistency (FFI boundary sync), review-probe-engineer (hypothesis-driven debugging), plus design, doc, explain, fix, test, init builtins
3. Individual audit of `review-code`: 12 dimensions well-structured, but completion criteria are vague ("produce a revised implementation" — does this mean full rewrite or targeted diffs?). Anti-compliance risk: agent could produce generic criticism without real investigation.
4. Individual audit of `review-compose`: Clear composition protocol, but no guidance on when `synthesis_mode: sequential` vs `parallel` should be chosen.
5. Interaction test: `review-code` + `review-redteam` on the same file — red-team's "Attack vector" format doesn't map to code's "Mechanism of failure" format, creating output inconsistency.
6. Security audit: no skill contains prompt injection patterns (verified against validate-skill.sh security checks)
7. Composition test: `review-firstprinciples` + `review-stakeholder` — firstprinciples says "do not propose complete rewrite as default," stakeholder says "propose changes that harm one stakeholder to help another without stating the trade-off." Conflict: if simplification removes a stakeholder benefit, no resolution mechanism.
8. Effectiveness test (scenario analysis): task = "review this auth module" — baseline produces 3 shallow findings, `review-code` produces 12 findings across dimensions, `review-compose` with redteam+qa produces 15 findings with overlap analysis.
9. Remediation plan: (1) clarify `review-code` completion criteria, (2) add synthesis_mode selection guidance to `review-compose`, (3) add conflict resolution note for firstprinciples+stakeholder composition
10. Final report: 4 Critical findings (2 functional, 1 composition, 1 instruction defect), 7 High, 3 Medium
