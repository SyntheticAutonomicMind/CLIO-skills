---
name: "audit-documentation"
description: "Systematic adversarial audit of an entire project's documentation system — inventory, cross-reference against implementation, detect contradictions, validate examples, redesign architecture"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence", "terminal_operations"]
tags:
  - audit
  - documentation
  - systematic
  - adversarial
lens: methodology
authority_tier: 1
---

# Adversarial Project-Wide Documentation Audit & Remediation

## When to Use

- Auditing an entire project's documentation for accuracy, coherence, and completeness
- When documentation has drifted from implementation and users are confused
- Before a major release where documentation quality matters
- When taking over maintenance of a project with poor or stale documentation
- Any scenario where the question is "does our documentation system actually represent this software accurately?"

## When Not to Use

- Reviewing a single document for quality (use `review-document` instead)
- Generating documentation for a single code file (use `doc` instead)
- When you only need to verify a single claim or example

## Inputs

- **repository_path** (required): Path to the repository root.
- **audit_depth** (optional): `standard` (inventory + accuracy) or `deep` (full information architecture redesign). Default: `standard`.
- **known_doc_issues** (optional): Documentation issues already identified that can be cross-checked.

## Instructions

You are a principal software architect, senior technical writer, code auditor, documentation engineer, and adversarial reviewer working together. Your assignment is to perform a **complete, implementation-grounded audit of the entire project and then systematically improve its documentation** to accurately describe the software as it exists, explain how and why it works, and provide a coherent, maintainable source of truth for users and developers.

This is not a README-polishing exercise. It is not a request to document files as you happen to encounter them. It is not a request to generate a large quantity of prose.

The objective is to make the project's documentation a reliable representation of the actual software, its architecture, behavior, contracts, constraints, workflows, and design decisions.

Assume that both the implementation and the documentation may contain subtle problems. Existing documentation may be stale, contradictory, incomplete, misleading, duplicated, or confidently wrong. The code may also behave differently from what its authors intended or what existing documentation claims.

**Do not assume that a document is correct because it is detailed, recently updated, well written, or consistent with other documents. Multiple documents can repeat the same mistake.**

The **implementation is the primary source of evidence for current behavior.** Verified tests, runtime observations, configuration, public interfaces, and explicit design contracts provide additional evidence. Existing documentation is material to investigate, not an authority to trust.

At the same time, do not blindly document every implementation quirk as desirable behavior. Distinguish what the software demonstrably does from what it is intended to do, what it guarantees, and what remains a defect or unresolved design question.

### Phase 1: Repository Inventory

Inspect the repository before forming conclusions. Inventory:

- Every skill and its complete instructions.
- Repository-level README files, indexes, manifests, metadata, examples, templates, and usage documentation.
- Skill naming, directory layout, required frontmatter or metadata, and formatting conventions.
- Dependencies, references, shared terminology, and links between skills.
- Installation, discovery, activation, and invocation mechanisms.
- Tests, validation scripts, linting, CI workflows, and release procedures.
- Historical changes and existing design decisions when Git history is available.

Determine the intended operating environment: which agents or skill loaders consume these files, how skills are discovered, whether they are invoked manually or automatically, and whether the loader imposes format or size constraints.

**Produce a factual inventory before judging quality.** Identify missing tests, undocumented assumptions, inaccessible dependencies, and anything that prevents reliable validation.

### Phase 2: Implementation Ground Truth

1. **Read each skill completely.** Evaluate its actual instructions, not just its name or stated purpose. For each skill, examine: Does it have a clear, distinct purpose? Is its scope narrow enough to be applied reliably? Does it define when it should and should not be used? Are prerequisites and expected outputs explicit?

2. **Establish what the software is, how it executes, what it exposes, how its components interact, and which claims can be verified.** Trace the major execution paths from their entry points to their outcomes. For each important subsystem, establish: What initiates execution, which components participate, how data and control flow, what configuration or environmental conditions change the path, what state is created/modified/persisted/discarded, what assumptions and contracts exist at boundaries, what failures/exceptions/retries/recovery paths are possible, what observable results occur, which tests exercise these behaviors, which facts are explained/omitted/misrepresented in documentation.

3. **Construct an internal inventory of capabilities and contracts.** For each significant feature or interface, identify: purpose and intended audience, entry point and invocation mechanism, inputs, outputs, side effects, and state changes, defaults, prerequisites, dependencies, and constraints, error handling and recovery behavior, security and permission implications, relevant tests and coverage strength, current documentation and accuracy, any uncertainty, ambiguity, or suspected implementation defect.

4. **Record the documentation baseline.** For each document: what it is intended to accomplish, which audiences it serves, what information it owns, which other documents link to or depend on it, which claims appear duplicated or contradictory, which important implementation areas lack documentation, which examples, commands, links, and configuration references appear obsolete, which validation mechanisms are available.

### Phase 3: Adversarial Documentation Audit

**Actively search for ways the existing documentation could mislead a reader.** Do not merely confirm that the documentation broadly resembles the code. Try to falsify its claims.

For each significant technical claim, ask: Does the current implementation actually support this claim? Does the documented behavior occur on every relevant execution path? Are important conditions, limitations, or exceptions omitted? Has a refactor changed the behavior without changing the documentation? Does the description confuse intended behavior with actual behavior? Does the documentation describe an obsolete implementation? Does it claim that a test validates something the test does not actually assert? Are names, flags, defaults, paths, return values, and error conditions correct?

Trace suspicious claims to the relevant implementation and tests.

**Do not assume documentation is authoritative when implementation or loader behavior contradicts it.**

4. **Search for important capabilities and contracts that have no adequate explanation.** Look especially for: public interfaces with undocumented inputs/outputs/errors, complex subsystems whose purpose is not apparent, important algorithms or architectural decisions that are difficult to reconstruct, configuration options implemented but not documented, implicit defaults and precedence rules, integration boundaries and data-flow contracts, setup steps/prerequisites/platform-specific requirements, failure and recovery behavior, security boundaries and trust assumptions, migration requirements and compatibility constraints, limitations that users need to know, development workflows contributors must rediscover, operational behavior that is important but not obvious from a happy path.

5. **Compare related information across the entire project.** Look for conflicting statements about: feature behavior, architecture and component responsibilities, installation and build procedures, configuration defaults and precedence, CLI syntax and API contracts, supported platforms and dependencies, security properties, testing requirements, release and deployment procedures, version compatibility and migration, terminology/naming/project identity. For each contradiction, determine which source is authoritative based on implementation, verified contracts, project conventions, and intended audience. **Resolve the conflict deliberately.** Do not merely make one page agree with another if both are wrong.

6. **Identify content copied into multiple locations** that is likely to drift. Distinguish useful summaries from redundant maintenance burdens. For each duplicated subject, decide whether to: establish one canonical explanation and link to it, keep a short audience-specific summary while centralizing detailed reference, generate multiple representations from a single source, or retain intentional duplication where necessary for usability.

7. **Challenge whether the documentation explains how the project fits together.** Ask: Can a new developer understand the major components and responsibilities? Is it clear how a typical request travels through the system? Are important dependencies and integration boundaries explained? Is ownership of state and responsibility clear? Are differences between similar subsystems explained? Are public contracts distinguishable from private implementation details? Are architectural constraints and invariants documented? Can a reader trace a feature from entry point through dependencies? Are non-obvious design decisions explained where the reasoning is supported by evidence? Does the documentation accurately describe the current architecture rather than an earlier design?

8. **Treat every executable example and operational instruction as a potential defect.** Check, where feasible: command names and arguments, file paths and directory assumptions, required dependencies and versions, environment variables, configuration formats and schemas, copy-and-paste usability, expected outputs and exit behavior, platform-specific differences, ordering requirements and prerequisites, authentication, permissions, and security implications, whether the example still represents a supported usage pattern. **Run examples or validate them mechanically whenever practical.** If execution is impossible, identify the reason and distinguish verified examples from unverified ones. Do not claim validation merely because a command looks plausible.

9. **Apply extra scrutiny to claims involving security, data handling, permissions, persistence, concurrency, reliability, and recovery.** Distinguish an attempt to redact secrets from a guarantee that secrets cannot escape, a local execution mode from a guarantee that no data leaves the machine, a retry mechanism from guaranteed recovery, a lock from complete race prevention, passing tests from comprehensive correctness, a documented feature from a supported public contract, best-effort behavior from transactional behavior. Document actual trust boundaries, prerequisites, limitations, and failure conditions. Never turn an unverified security assumption into a guarantee.

### Phase 4: Information Architecture Design

Do not start editing pages independently until you have determined the appropriate overall structure.

1. **Identify the real audiences** for this project: new users, experienced users, operators and administrators, contributors, maintainers, integrators and extension authors, security reviewers, researchers or other specialized audiences if applicable.

2. **Determine the questions each audience needs answered.**

3. **Design a structure** that fits the actual size, complexity, and conventions of the project. Consider which material belongs in: a project overview and README, a getting-started guide, installation and configuration documentation, user guides and workflows, feature-specific explanations, CLI and API reference material, architecture and subsystem documentation, development and contribution guides, testing and troubleshooting guides, security and operational documentation, migration guides and changelogs, examples, recipes, and tutorials.

4. **Create a clear ownership model** for important information: the implementation and validated contracts establish actual behavior, the canonical configuration reference owns detailed option definitions, the architecture guide owns system-level relationships, the CLI reference owns complete command syntax, the getting-started guide owns the minimum path to a working installation, the changelog owns historical release changes, migration guides own upgrade-specific actions. Adapt this model to the project.

5. **Use consistent conventions** for: terminology and naming, headings and page organization, relative links and navigation, code examples and expected output, configuration tables and defaults, version and compatibility statements, warnings/limitations/security notes, diagrams and their source files, references to implementation details, deprecation and migration notices. Follow existing project conventions when they are effective. Change them when there is a concrete reason and apply improvements consistently.

### Phase 5: Remediation

Update the documentation according to the established plan.

Ensure that the primary project overview accurately communicates: what the software is, what problem it solves, who it is for, its major capabilities, its general operating model, its important requirements and limitations, how to get started, where to find deeper technical information. Describe demonstrated capabilities, not aspirational marketing claims.

Users and developers need mental models, not just lists of commands and source files. Where appropriate, explain: the core concepts and terminology, the relationships between components, why different execution paths exist, how configuration affects behavior, how data and state move through the system, what happens during success/failure/retries/recovery, which responsibilities belong to which components, what invariants maintain correctness.

For significant public interfaces, explain the information readers need to use them correctly: invocation syntax and accepted arguments, input formats, output formats, and return values, defaults and precedence, side effects and state changes, error behavior, required permissions and prerequisites, compatibility expectations, relevant constraints and edge cases, examples that demonstrate supported usage. Clearly distinguish public guarantees from incidental internal behavior. Do not promise stability or compatibility without evidence that the project actually provides it.

Provide enough architectural explanation that maintainers can reason about changes without repeatedly reconstructing the entire system. Use layered explanations: system-level overview, major component responsibilities and relationships, important execution flows and cross-component contracts, detailed subsystem behavior where complexity warrants it. Document significant invariants and explain where they are enforced. Link architectural claims to relevant source locations or tests when useful. Keep these references maintainable and avoid making prose depend unnecessarily on unstable line numbers.

Record material limitations, unsupported cases, incomplete functionality, and important operational constraints. Differentiate: verified limitations, known defects, deliberate design constraints, unverified concerns, and planned work. Do not silently reclassify bugs as features. Do not imply that planned functionality already exists. Where a defect makes existing documentation materially misleading, correct the claim and, if necessary, cross-reference the relevant known issue or investigation.

**Make corrections directly in the repository.** Do not substitute a proposed outline, a list of recommendations, or a report describing what should be done for the actual edits.

### Phase 6: Self-Audit Pass

Treat the documentation changes themselves as a patch requiring adversarial review. Review the changes against the implementation again.

Ask: Did I infer anything that I did not verify? Did I accidentally convert a possibility into a guarantee? Did I describe an internal implementation detail as a public contract? Did I omit an important condition or failure path? Did I introduce a contradiction elsewhere? Did I document intended behavior that the current code does not deliver? Did I make a broad statement based on a narrow test? Did I create a new source of truth that duplicates an existing one? Did I introduce unnecessary complexity or maintenance burden?

Check: internal links and anchors, navigation entries, file and directory paths, CLI commands and option names, configuration keys and documented defaults, code snippets and examples, version-specific claims, references to modules/functions/classes/tests, documentation generator configuration, generated output if applicable.

**Do not treat tests as infallible documentation authorities.** When a test is used to support a claim, verify what it actually exercises and asserts. Distinguish among: behavior inferred from reading implementation, behavior exercised by an existing test, behavior reproduced in a runtime experiment, a documented contract explicitly established by the project, and a claim that remains uncertain.

If the audit discovers an apparent code defect: establish the evidence, determine whether the defect affects documented behavior, investigate the root cause when the task and available scope permit, determine whether a safe implementation correction is necessary to make the documentation truthful, if changing code preserve existing behavior except where correction is justified and add regression coverage where appropriate, if the implementation cannot safely be changed within scope document the actual limitation without presenting it as correct or desirable behavior, record the unresolved issue and the evidence needed to settle it.

**This assignment primarily targets documentation, but documentation must not become a mechanism for hiding broken software.** Do not undertake unrelated implementation refactors merely because the audit has exposed adjacent opportunities.

### Phase 7: Final Checklist and Report

1. The repository and its documentation mechanisms have been inventoried.
2. Major execution paths, interfaces, configuration surfaces, and subsystem boundaries have been investigated.
3. Existing documentation has been checked against the actual implementation.
4. Significant documentation gaps, contradictions, duplication, and inaccuracies have been identified.
5. The investigation ledger accurately records reviewed and unreviewed scope.
6. The documentation structure has a clear purpose and audience.
7. Canonical sources of truth are identifiable.
8. Redundant independently maintained content has been reduced where appropriate.
9. Navigation, internal links, and cross-references are coherent.
10. The project's primary overview accurately communicates its purpose and capabilities.
11. Significant public interfaces and important behaviors are documented adequately.
12. Major architectural relationships and execution flows are understandable.
13. Configuration, defaults, prerequisites, and limitations are accurately described where relevant.
14. Important error, recovery, security, and operational behaviors are covered where applicable.
15. Examples and commands have been validated to the extent reported.
16. No unsupported guarantee or invented capability has been introduced.
17. Implementation defects discovered during the audit have been addressed or explicitly recorded.
18. Appropriate documentation checks have been run.
19. Relevant examples and links have been checked.
20. Changed technical claims have undergone a second evidence-based review.
21. The independent adversarial pass has been completed to the reported scope.
22. Remaining uncertainties and unverified areas are explicitly documented.

A passing checklist is not, by itself, proof of quality. Use engineering judgment to determine whether the resulting documentation actually helps its intended readers understand and use the project correctly.

### Investigation Ledger

Maintain a durable investigation ledger that records for each significant finding: Observation, Evidence, Impact, Root Cause, Remediation, Validation, and Status (Verified, Corrected, Partially Corrected, Unresolved, or Not Applicable). Classify evidence honestly: Static inspection, Execution-path analysis, Existing test evidence, New regression test or validation, Reproduced runtime behavior, Unverified inference. Do not inflate confidence by presenting these categories as equivalent. Maintain separate records for documentation defects and implementation defects where that distinction helps track remediation.

### Output Format

Produce a single markdown document with the following sections:

**Section 1: Report Summary**
- The resulting documentation structure, the role of each major document, which sources are canonical for important subjects, what duplication was removed or intentionally retained, how readers should navigate the documentation.

**Section 2: Repository Inventory**
- Every relevant skill, supporting file, and validation mechanism inspected.

**Section 3: Significant Issues Discovered**
- For each finding: location, impact, what was changed or why it remains unresolved.

**Section 4: Documentation Changes Made**
- List of files created, modified, or deleted, with rationale for each change.

**Section 5: Verification Report**
- Commands and checks actually executed, which examples were executed or validated, results and failures, which claims received runtime or test verification, what could not be validated and why.

**Section 6: Remaining Gaps and Risks**
- Areas reviewed, areas updated, areas reviewed but left unchanged, areas only partially reviewed, areas not reviewed, remaining uncertainties and risks, any follow-up work necessary to achieve fuller coverage.

**Section 7: Candid Assessment**
- Whether the documentation is materially more accurate, coherent, complete, and maintainable than before. The most consequential improvements, the largest remaining gaps, and any changes requiring particular maintainer attention.

### Constraints

- Do not substitute recommendations for actual edits.
- Do not treat documentation as authoritative when implementation contradicts it.
- Do not fabricate test results, execution results, source evidence, or documentation coverage.
- Do not modify generated documentation output when its canonical source should be changed instead.
- Do not change public behavior solely to make it match an incorrect document.
- Do not introduce new dependencies or elaborate tooling without a clear justification.
- Do not create empty placeholder documents or pad pages with boilerplate.
- Do not use broad automated rewrites without reviewing their effects.
- Do not suppress, bypass, or misrepresent validation failures.
- Do not commit, push, publish, or perform destructive Git operations unless explicitly authorized.
- Do not optimize for the number of files edited, the volume of prose produced, or the speed of the initial pass. Optimize for verified accuracy, useful understanding, architectural coherence, discoverability, and low long-term maintenance cost.

### Anti-Patterns

- Polishing the README based on a superficial impression of the project
- Confirming that documentation broadly resembles the code
- Assuming that a document is correct because it is detailed or recently updated
- Stopping at grammar/formatting issues while missing structural flaws
- Assuming the document's framing is correct
- Producing generic feedback that applies to any document
- Creating redundant documentation when the project already has an appropriate location
- Treating documentation as a series of isolated files rather than a system
- Inflating coverage metrics instead of improving understanding
- Inventing guarantees, capabilities, performance figures, compatibility claims, or design rationales
- Converting possibilities into guarantees
- Claiming validation because a command looks plausible
- Ignoring contradictions between documents
- Producing recommendations instead of edits

## Composition

- **Complements:** `review-document` (for single-document focused review), `audit-codebase` (for verifying implementation matches documentation)
- **Uses internally:** `review-document` as a lens for individual document quality during the systematic pass
- **Followed by:** `review-qa` (to verify documentation changes don't break generation or builds)
- **Triggers:** This skill is the top-level methodology for documentation system auditing

## Examples

**User:** "Audit the documentation in this CLIO skills repository."

**Agent:**
1. Inventories all 14 skills, README.md, CONTRIBUTING.md, validate-skill.sh, SKILL.md format spec embedded in CONTRIBUTING.md
2. Establishes ground truth: reads each SKILL.md, confirms the 12-dimension review structure, confirms the `name` field matches directory name
3. Finds contradiction: README.md says "GPLv3 recommended" for LICENSE.txt, but CONTRIBUTING.md mandates GPLv3 — these agree, but CONTRIBUTING.md also says "GPLv3 required" while the instructions file says "GPLv3 required" — verified consistent
4. Finds stale example in `review-code`: the example output hardcodes "12 dimensions" — this is self-referential and consistent
5. Finds missing documentation: no skill has a "how skills compose" guide — the `Composition` sections exist per-skill but there is no top-level composition reference
6. Runs validate-skill.sh on all skills — all pass
7. Creates docs/composition-guide.md as canonical reference, updates individual skills to link to it, updates README.md to mention composition
8. Self-audit pass: verifies no broken links, verifies the guide accurately reflects the Composition sections
9. Final report: 7 findings (3 corrected, 2 clarified, 2 documented as limitations), 1 new doc created
