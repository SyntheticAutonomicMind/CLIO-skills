---
name: "audit-codebase"
description: "Systematic adversarial audit of an entire codebase — find, remediate, and verify defects across all subsystems with scope discipline and a self-audit pass"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence", "terminal_operations"]
tags:
  - audit
  - systematic
  - adversarial
  - codebase
lens: methodology
authority_tier: 1
---

# Adversarial Full-Codebase Audit & Remediation

## When to Use

- Auditing a production codebase for latent defects, architectural drift, and quality decay
- Before a major release or post-incident analysis
- When taking ownership of a legacy or unfamiliar codebase
- Any scenario where a single-file review is insufficient — the question is "what is wrong with this entire system?"

## When Not to Use

- Reviewing a single file, function, or small PR (use `review-code` or `review-compose` instead)
- When the repository is a single file or trivial script
- When you need a focused lens (security, performance) on a single artifact (use `review-redteam`, `review-firstprinciples`, etc.)

## Inputs

- **repository_path** (required): Path to the repository root.
- **audit_depth** (optional): `standard` (all areas, medium detail) or `deep` (all areas, exhaustive detail including minor smells). Default: `standard`.
- **failure_domain** (optional): `technical`, `operational`, `economic`, `social` (can specify multiple). Constrains the failure narratives if conducting a focused pass.
- **known_issues** (optional): Issues already identified that can be cross-checked rather than rediscovered.

## Instructions

You are performing a **deep, adversarial software engineering audit and remediation** of an existing production codebase. This is not a superficial code review.

Your job is to systematically examine the **entire codebase**, identify defects and structural problems, understand why they exist, and remediate them safely.

The codebase has evolved over time and may have been developed through a combination of human and AI-assisted development. Assume that this history may have produced:

- duplicated implementations
- stale abstractions
- partially completed features
- disconnected code paths
- accidental behavior changes
- contradictory assumptions
- inadequate tests
- misleading tests
- dead code
- shadowed state
- subtle bugs
- architectural drift
- workarounds that became permanent
- code that appears correct locally but fails at system boundaries

**Do not assume that code is correct because it compiles, passes existing tests, looks clean, or appears intentional.**

You are expected to challenge those assumptions.

### Phase 1: Repository Mapping and Scope Discipline

Before modifying anything, understand the repository.

1. **Inspect the repository structure.** Use `file_operations` to enumerate the complete directory tree. Identify: source files, tests, build scripts, package manifests, dependency declarations, configuration, examples, command-line interfaces, scripts, generated code, schemas, migrations, documentation relevant to behavior, CI configuration, lint/static-analysis configuration, deployment configuration, integration tests, fixtures, mocks/stubs, development tooling.

2. **Establish the audit checklist.** Create a checklist that partitions the entire repository into logical areas. Every major subsystem, directory, module, package, executable, script, test suite, configuration system, and integration must be named explicitly. No area may be skipped without a documented justification.

3. **Determine the real executable entry points.** Trace the actual execution paths from entry points (CLI commands, web handlers, cron jobs, CI steps) through the system. Do not assume directory structure represents architecture.

4. **Establish the execution-map.** For each major subsystem, establish:
   ```
   entry point
       v
   initialization
       v
   state/configuration
       v
   primary execution
       v
   dependent operations
       v
   error/fallback paths
       v
   cleanup/finalization
   ```

5. **Follow critical values.** For each critical operation, trace the data flow:
   ```
   input
     -> validation
     -> transformation
     -> processing
     -> side effects
     -> result
     -> consumer
   ```

6. Set up an investigation ledger that records every area examined, every finding, and every justification for skipped scope. The ledger must survive context trimming via `memory_operations`.

### Phase 2: Systematic Investigation

Process every area on your checklist. For each:

1. Read all relevant source files, tests, fixtures, and configuration.
2. Trace execution from entry points through to side effects.
3. Search for:
   - unreachable functions
   - unreachable branches
   - unused modules
   - unregistered handlers
   - unconnected callbacks
   - dead event subscriptions
   - features that are implemented but unreachable
   - CLI options that do nothing
   - configuration values that do nothing
   - state that nobody observes
   - state that is read but never updated
   - results that are discarded
   - ignored return values
   - ignored errors
   - swallowed exceptions
   - impossible error paths
   - broken fallback paths
   - partially implemented features
   - incomplete integrations
   - stale compatibility layers
   - obsolete interfaces
   - implementations no longer matching their callers
   - initialization assumptions that are not guaranteed
   - cleanup that does not execute on all relevant paths
   - resources that can leak
   - asynchronous operations that are never awaited
   - promises/futures/tasks whose results are ignored
   - callbacks that may execute after their owner is destroyed
   - race-prone state transitions
   - state machines with missing transitions
   - state machines with contradictory transitions

4. **Search for semantic duplication.** Look for multiple implementations of validation, normalization, configuration handling, state transitions, serialization, deserialization, error handling, retry behavior, caching, path construction, provider selection, API interaction, command dispatch, business rules, UI/business logic, authentication, authorization, lifecycle handling. For each duplicate, determine: Are these genuinely different behaviors? Which is authoritative? Have they drifted? Do they have different edge-case behavior? Has one received bug fixes the other lacks? Can they safely share an implementation?

5. **Audit variables and state.** Search for the pattern `A = X; A = Y; use(A)` and determine whether `X` is dead. Search for `state.foo = X; ...; state.foo = Y` and determine whether the first assignment was intended or accidental. Investigate indirect overwrites through helper functions, object mutation, references, callbacks, closures, asynchronous operations, inheritance, global/shared state, configuration merging, environment variables, command-line arguments, defaults, and dependency injection.

6. **Hunt for code smells and anti-patterns.** Look for excessively large functions/classes, deeply nested control flow, boolean parameter abuse, primitive obsession, hidden side effects, temporal coupling, feature envy, shotgun surgery, divergent change, inappropriate intimacy, speculative generality, leaky abstractions, excessive indirection, magic values, magic strings, inconsistent naming, misleading names, unreachable defensive code, defensive code that hides failures, silent failure, catch-and-ignore behavior, inconsistent error semantics, mutable shared defaults, hidden dependencies, implicit ordering requirements, fragile initialization order, global caches, unnecessary caching, premature optimization, unnecessary synchronization, duplicated synchronization, resource ownership ambiguity, lifecycle ambiguity.

7. **Search for subtle bug classes.** Look for: empty input, null/nil/undefined values, missing fields, malformed data, unexpected types, integer overflow/underflow, precision problems, encoding problems, Unicode issues, path handling, platform-specific behavior, case sensitivity, line-ending assumptions, locale assumptions, timezone assumptions; stale state, state synchronization failures, invalid transitions, partial state updates, state updated in the wrong order, state reset unexpectedly, stale caches, duplicate sources of truth; swallowed errors, incorrect error propagation, incorrect error classification, retries of non-retryable failures, non-retries of transient failures, cleanup failures hiding primary failures, success returned after partial failure, failure returned after successful completion; races, deadlocks, lock ordering, double execution, lost updates, stale reads, use-after-close, cancellation races, task lifetime problems, thread safety assumptions, unsafe shared state; initialization occurring too late or twice, cleanup occurring too early or never, resources surviving their owners, resources dying before their consumers, shutdown races, restart inconsistencies.

### Phase 3: Test Audit

1. **Inventory all tests.** Map production paths to test coverage. Identify production paths with no tests, branches with no meaningful coverage, error paths with no tests, boundary conditions with no tests, concurrency paths with no tests, lifecycle paths with no tests, integration boundaries with no tests, fallback behavior with no tests, configuration combinations with no tests.

2. **Audit test quality.** Find: tests that mock away the behavior they supposedly validate, tests that only verify implementation details, tests that can pass while production behavior is broken, tests that assert weak conditions, tests that never fail when the underlying behavior is removed, duplicated tests, stale tests, tests for obsolete behavior, fixtures that hide important behavior, mocks that no longer resemble production interfaces.

3. **For each production path with inadequate tests, write a regression test** before or alongside the fix. The test should demonstrate observable behavior, not merely internal implementation.

4. For each important test, ask: "If I deliberately broke the implementation, would this test fail?" Validate by temporarily introducing controlled failures where practical.

### Phase 4: Documentation Audit

Compare documentation with actual behavior. Identify: documented features that do not work, undocumented behavior that callers rely upon, obsolete architecture descriptions, incorrect configuration documentation, stale examples, incorrect API contracts, comments describing behavior that no longer exists.

If the implementation is correct and documentation is stale, update the documentation. If documentation describes intended behavior that the implementation violates, determine which is authoritative before changing anything.

### Phase 5: Remediation

For every confirmed defect:

1. Understand the root cause.
2. Determine the smallest coherent correction.
3. Modify the implementation.
4. Add or improve tests where appropriate.
5. Run relevant tests.
6. Run broader tests.
7. Inspect the resulting diff.
8. Check for unintended side effects.
9. Revisit callers and consumers.
10. Verify that the original defect is actually gone.

**Do not paper over defects with:** extra conditionals, silent fallbacks, broad exception handling, arbitrary defaults, additional state, duplicated logic, disabling tests, weakening assertions, suppressing warnings, ignoring errors.

Fix root causes whenever reasonably possible. **Preserve existing behavior** unless the existing behavior is itself defective. Do not perform unrelated modernization. Do not rewrite functioning subsystems merely because you prefer another architecture. Do not introduce new dependencies without justification. Do not silently remove functionality. Do not remove apparently dead code until you have established that it is genuinely dead or obsolete. Do not change public interfaces without understanding all consumers.

### Phase 6: Self-Audit Pass (Second Adversarial Pass)

After completing remediation, **start another audit pass targeting your own changes.**

For every significant modification ask:

- What did this change assume?
- What existing caller could disagree with that assumption?
- Did I introduce duplicated state?
- Did I create another special case?
- Did I move the bug somewhere else?
- Did I fix one execution path but miss another?
- Did I change error semantics?
- Did I alter lifecycle behavior?
- Did I introduce a race?
- Did I invalidate an existing cache?
- Did I create a new source of truth?
- Did I make a previously unreachable path reachable?
- Are the new tests actually capable of catching regression?
- Did the change preserve behavior outside the intended scope?

Rerun the relevant portions of the audit.

### Phase 7: Final Checklist and Report

Before declaring completion, explicitly ask: "What categories of defects have I not yet investigated?" Perform another repository-wide search for: unused code, duplicate code, stale state, overwritten values, unreachable paths, untested paths, suspicious TODOs/FIXMEs, compatibility code, temporary workarounds, commented-out code, disabled tests, skipped tests, ignored errors, broad exception handlers, suspicious casts, unsafe assumptions, duplicated configuration, inconsistent naming, inconsistent error handling, suspiciously similar functions, suspiciously similar variables, inconsistent implementations of the same operation.

Do not finish merely because the expected checklist is exhausted. Look for defects that do not fit the checklist.

### Defect Reporting Format

For each substantive finding, establish:

```
OBSERVATION
What was found?

EVIDENCE
Where does it occur? (file, function, line number)

IMPACT
What can go wrong?

ROOT CAUSE
Why does it happen?

REMEDIATION
What was changed?

VALIDATION
How was the fix verified?
```

Classify each finding as: confirmed defect, probable defect, suspicious code requiring investigation, maintainability concern, or intentional design choice. Do not invent certainty.

### Output Format

Produce a single markdown document with the following sections:

**Section 1: Repository Areas Examined**
- List every subsystem, directory, module, package, executable, script, test suite, configuration system, and integration that was examined.

**Section 2: Execution Paths Traced**
- For each major entry point, the execution flow from entry point through side effects.

**Section 3: Test Suites Examined**
- Inventory of test suites, coverage mapping, test quality assessment.

**Section 4: Defects Found and Remediated**
- For each confirmed defect, the full reporting format above.

**Section 5: Remaining Duplication and Smells**
- Duplication, questionable abstractions, smells, and anti-patterns that were investigated but determined to be acceptable, plus any that remain unresolved.

**Section 6: Areas with Insufficient Testing**
- Production paths with inadequate or missing test coverage.

**Section 7: Verification Report**
- Tests executed, static analysis executed, linters executed, builds executed, integration tests executed, other validation performed.

**Section 8: Remaining Uncertainty and Risks**
- Areas that could not be confidently verified or safely changed.

**Section 9: Residual Recommendations**
- Highest-value follow-up work, prioritized.

### Constraints

- Do not optimize for the shortest audit.
- Do not optimize for the fewest changes.
- Do not optimize for producing an impressive report.
- Optimize for **finding real defects and leaving the codebase measurably more correct, coherent, testable, and maintainable than you found it.**
- Do not stop after finding several bugs.
- Do not stop because the test suite passes.
- Do not stop because static analysis is clean.
- Do not stop because the repository is large.
- Do not assume code is correct because it compiles or looks intentional.

### Anti-Patterns

- Spot-checking a representative sample and extrapolating
- Stopping because the test suite passes
- Stopping because a subsystem appears mature
- Assuming directory structure represents architecture
- Treating absence of observed failure as proof of correctness
- Papering over defects with broad exception handling or silent fallbacks
- Removing dead code without establishing that it is genuinely dead
- Changing public interfaces without understanding all consumers
- Performing unrelated modernization
- Disabling or weakening tests to accommodate implementation changes
- Reporting style preferences as defects
- Creating new sources of truth instead of consolidating

## Composition

- **Complements:** `review-code` (use for single-file focused reviews), `review-compose` (compose individual lens skills for targeted multi-lens review of specific artifacts)
- **Follows well with:** `review-qa` (to verify remediations), `review-premortem` (to identify systemic risks the audit may have missed)
- **Uses internally:** `review-redteam`, `review-firstprinciples`, `review-qa`, `review-stakeholder` as lenses during the systematic pass
- **Triggers:** This skill is the top-level methodology; it orchestrates the lens skills but is not itself composed into larger workflows

## Examples

**User:** "Audit the entire repository for defects."

**Agent:**
1. Maps the repository: `src/` (backend modules), `frontend/` (web UI), `tests/`, `docs/`, `configs/`, `AGENTS.md`, `package.json`, CI workflows
2. Builds an audit checklist covering all 12 directories
3. Traces execution: `src/main.go:47` -> `PowerStateManager` -> sysfs writes -> `fan_controller` -> temperature polling -> error handling
4. During the fan controller review, notices that `set_pwm_duty_cycle()` in `src/fan_controller.go:33` returns an error but callers in `src/profile_manager.go:189` and `src/ac_handler.go:73` both discard the result
5. Writes a regression test that simulates an I/O failure, confirms the error is swallowed
6. Fixes by propagating the error up the call chain
7. Runs tests, inspects diff, checks callers
8. Self-audit pass: confirms no new duplication, error semantics preserved on other paths
9. Final report with 12 findings, 3 of which were Critical
