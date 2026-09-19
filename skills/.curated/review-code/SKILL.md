---
name: "review-code"
description: "Comprehensive code review across twelve dimensions, producing critique and improved implementation"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - composite
  - code
  - review
lens: composite
authority_tier: 1
---

# Generic Code Review

## When to Use

- Reviewing a pull request, module, or full codebase
- Any code where the question is "is this good?"
- Preparing code for merge, release, or handoff

## When Not to Use

- When a single-lens review is sufficient (use review-redteam for security, review-firstprinciples for simplification, etc.)
- When the code is a trivial snippet or script

## Inputs

- **code** (required): The full code, or file paths to read within the current project.
- **context** (optional): Language, framework, purpose, constraints, prior discussion.
- **reviewer_focus** (optional): security, performance, maintainability, correctness (prioritizes relevant dimensions).

## Instructions

You are a senior software engineer with deep expertise in the language, framework, and domain of the code under review. Your task is to **review the code across twelve dimensions** - find where it is wrong, unsafe, inefficient, unmaintainable, or naive - and then produce a better version. Focus on identifying issues rather than praising. Do not rewrite it arbitrarily. Preserve intent. Do not propose vaporware. Every fix must be implementable. Do not hand-wave. Reference specific lines. Do not over-engineer. The simplest correct solution is preferred.

If the code is part of a larger system, you may read surrounding code in the current working directory using `file_operations` and `code_intelligence`. State any assumptions you make.

### Procedure

1. **Read the code completely** before critiquing. Use `file_operations` to read files, `code_intelligence` to search for usages and trace call chains. Do not assume - verify by reading.

2. **Identify the code's claims, assumptions, and design decisions.** What does it say it does? What must be true for it to work?

3. **For each of the twelve dimensions below**, identify specific, concrete issues where they exist. A dimension with zero findings is a valid result — do not fabricate issues to meet a quota. If `reviewer_focus` is specified, weight findings toward that area but still cover all twelve.

4. **For each issue, state:**
   - **Location:** file, function, line number (if available)
   - **Claim:** what the code does or assumes
   - **Mechanism of failure:** how and why it fails
   - **Severity:** Critical / High / Medium / Low
   - **Suggested fix:** a concrete, implementable correction

5. **Prioritize issues by severity.** Critical and High severity issues must be addressed in the revised version.

6. **Produce a revised implementation** that addresses the Critical and High severity issues (and Medium/Low where practical, or explain why deferred).

### The Twelve Dimensions

1. **Correctness** - Does the code do what it claims? Logic errors, off-by-one, incorrect assumptions, return values, exceptions, error codes.
2. **Security** - Input validation, injection flaws, auth checks, secret management, race conditions, TOCTOU, dependency vulnerabilities, data exposure.
3. **Performance and scalability** - Algorithmic complexity, memory usage, I/O efficiency, lock contention, caching, behavior under load.
4. **Maintainability and readability** - Naming, function/module size, coupling/cohesion, duplication, comments, magic numbers.
5. **Error handling and resilience** - Exception handling, retry/backoff, circuit breakers, graceful degradation, logging, failure isolation.
6. **Testing** - Unit/integration/E2E coverage, test quality, edge cases, mocking, flakiness, determinism.
7. **Style and conventions** - Language idioms, framework conventions, linting, formatting, consistency.
8. **Resource management** - File handles, sockets, connections, memory lifecycle, cleanup on error paths.
9. **Concurrency and parallelism** - Thread safety, data races, deadlocks, atomicity, visibility, async/await correctness.
10. **Portability and compatibility** - Platform assumptions, version compatibility, configuration, environment handling.
11. **Documentation and comments** - Accuracy of comments, API documentation, README and usage examples.
12. **Build, packaging, and deployment** - Dependency management, build reproducibility, configuration, secrets, deployment, rollback.

### Output Format

Produce a single markdown document with two sections:

**Section 1: Critique**
- Organized by dimension (all twelve; dimensions with no findings should say "No issues found")
- Numbered issues
- Each issue: Location / Claim / Mechanism of failure / Severity / Suggested fix

**Section 2: Improved Code**
- Full revised files or unified diffs
- Inline comments explaining non-obvious changes
- A summary of what was changed and why
- Any assumptions made about the surrounding code
- Any deferred issues with justification

### Constraints

- Focus on identifying issues rather than praising the code.
- Do not rewrite the code arbitrarily. Preserve intent.
- Do not propose vaporware. Every fix must be implementable.
- Do not hand-wave. Every claim must reference a specific line or construct.
- Do not over-engineer. The simplest correct solution is preferred.
- Do not ignore context. If the code is intentionally simple for readability, say so.
- Do not assume infinite resources, perfect humans, or perfect infrastructure.
- Do not confuse criticism with cynicism.

### Anti-Patterns

- Nitpicking style while missing structural flaws
- Rewriting the code in a different style
- Ignoring context (intentional simplicity is not a flaw)
- Proposing changes that break backward compatibility without stating the cost
- Confusing personal preference with best practice
- **Hardcoding counts in documentation** — embedding numbers like "11 skills" or "6 modules" in prose that goes stale when the codebase changes. Use references like "see README.md" or dynamic listing commands instead.

## Composition

- Follows well with: `review-qa` (to verify the fixes)
- Can be replaced by: any single-lens skill, if the review is focused
- Complements: `review-document` (for artifacts that include both prose and code)

## Examples

**User:** "Code review this authentication module"

**Agent reads the file and produces:**

```markdown
## Section 1: Critique

### Security
- **Location:** auth.py:23
  **Claim:** SQL query is built by string interpolation of user input.
  **Mechanism:** Attacker submits email="admin' OR '1'='1' --" which
  short-circuits the WHERE clause and returns the first user row,
  bypassing password verification.
  **Severity:** Critical
  **Fix:** Use parameterized queries with placeholders.

- **Location:** auth.py:45
  **Claim:** Password compared with ==.
  **Mechanism:** String comparison via == short-circuits on first byte
  mismatch, leaking timing information for byte-by-byte password
  recovery.
  **Severity:** High
  **Fix:** Use hmac.compare_digest() for constant-time comparison.

...

### Testing
- **Location:** auth.py (module)
  **Claim:** No test file exists.
  **Mechanism:** Without tests, regressions in auth logic are
  undetected. Authentication is security-critical.
  **Severity:** Critical
  **Fix:** Add test_auth.py covering happy path, invalid credentials,
  expired tokens, and SQL injection attempts.

## Section 2: Improved Code

[Unified diff with inline comments]
```
