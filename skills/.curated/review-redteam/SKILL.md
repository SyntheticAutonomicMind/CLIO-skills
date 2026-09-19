---
name: "review-redteam"
description: "Adversarial security and failure-mode review — find where artifacts break, how an attacker or failure scenario exploits them, and why"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence"]
tags:
  - security
  - risk
  - adversarial
lens: adversarial-single
authority_tier: 1
---

# Red-Team Review

## When to Use

- Security review focused on exploitable attack surfaces
- Safety-critical artifact assessment (attack surfaces, failure chains)
- Adversarial threat modeling (identify exploitable weaknesses)
- Pre-release risk assessment where the cost of a discovered vulnerability is high
- Any artifact where the question is "what is the worst realistic failure here?"

## When Not to Use

- Early drafts that are not ready to be attacked (use review-stakeholder first)
- Exploratory work where criticism kills momentum
- When the author needs encouragement, not correction
- When a comprehensive multi-dimension review is needed (use review-code instead)

## Inputs

- **artifact** (required): The file, code, or document under review. Specify a path or paste the content.
- **context** (optional): Audience, purpose, constraints, or prior discussion.
- **threat_model** (optional): Known threats to prioritize.
- **failure_depth** (optional): How many failure steps to trace (default: trace to root). Options: `shallow` (immediate failure), `deep` (cascading chain).

## Instructions

Your task is to **find the worst realistic failure** the artifact is vulnerable to. Do not audit every line — attack the attack surface. This skill is a single lens focused on three questions:

1. **What can an adversary exploit?** (injection, auth bypass, privilege escalation, data disclosure)
2. **What can fail catastrophically?** (resource exhaustion, crash loops, data loss, corruption)
3. **What assumption, if violated, makes the above inevitable?**

This is NOT a comprehensive multi-dimension code review. Do not re-audit style, naming, or general maintainability — `review-code` covers those. Stay adversarial: prove the artifact is wrong before trusting it.

If the artifact is part of a larger system, you may read surrounding code in the current working directory using `file_operations` and `code_intelligence`. State any assumptions you make.

### Procedure

1. **Read the artifact completely** before critiquing. Use `file_operations` to read files, `code_intelligence` to search for usages and trace call chains.

2. **Identify the artifact's claims, assumptions, and design decisions.** What does it say it does? What must be true for it to work?

3. **Identify the attack surface.** Enumerate every entry point: user-facing APIs, external inputs, file reads, network calls, FFI boundaries, configuration files, environment variables, dependency imports. For each, ask: "how could this be turned against the system?"

4. **For each issue, state:**
   - **Location:** file, function, line number (or section heading)
   - **Attack vector:** how an adversary triggers the failure
   - **Mechanism of failure:** how and why it fails
   - **Severity:** Critical / High / Medium / Low
   - **Exploitation difficulty:** Trivial / Easy / Moderate / Hard
   - **Suggested fix:** a concrete, implementable correction

5. **Chain failures into attack narratives.** For Critical issues, trace the failure from initial exploit through to impact: what must be true at each step, what the attacker learns or gains, and where the chain could break.

6. **Produce a revised artifact** that addresses Critical and High severity issues (and Medium/Low where practical, or explain why deferred).

### Review Focus Areas

Focus on these adversarial lenses (do not audit all twelve — that is `review-code`'s job):

- **Injection vectors** — input that crosses a trust boundary into SQL, shell, eval, template rendering, regex, or FFI calls
- **Authentication & authorization** — bypasses, escalations, missing checks, timing leaks, token reuse
- **Resource exhaustion** — unbounded loops, memory allocation, file descriptors, connection pools, disk usage
- **Crash & corruption** — unhandled exceptions, null dereferences, race conditions, data races, state-machine violations
- **Information disclosure** — error messages, logs, stack traces, timing channels, config/credential exposure
- **Dependency risk** — vulnerable transitive deps, untrusted input to external libraries, supply-chain attack surface

### Output Format

Produce a single markdown document with two major sections:

**Section 1: Red-Team Critique**
- Organized by focus area (the adversarial lenses above)
- Each focus area has a numbered list of specific issues (or "No issues found" if clean)
- Each issue follows: Location / Attack vector / Mechanism of failure / Severity / Exploitation difficulty / Suggested fix
- For Critical issues, include a brief attack narrative tracing failure through the system

**Section 2: Improved Artifact**
- Full revised files or unified diffs
- Inline comments explaining non-obvious changes
- A summary of what was changed and why
- Any deferred issues with justification

### Constraints

- Focus on finding what is wrong and how it fails, rather than praising the artifact.
- Do not rewrite the code arbitrarily. Preserve intent.
- Do not propose vaporware. Every fix must be implementable.
- Do not hand-wave. Every claim must reference a specific line or construct.
- Do not assume infinite resources. Consider realistic constraints.
- Do not assume perfect humans, AI, or infrastructure.
- Do not confuse criticism with cynicism. The goal is better code, not a demolished author.
- Do not ignore context. If the artifact is intentionally simple for readability, say so.
- Do not over-engineer. The simplest correct solution is preferred.
- Do not audit general code quality — that is `review-code`'s mandate. Stay adversarial: prove the artifact fails.

### Anti-Patterns

- Vague criticism ("this could be better")
- Nitpicking style while missing structural flaws
- Listing every possible failure without prioritization
- Ignoring context (intentional simplicity is not a flaw)
- Reporting theoretical vulnerabilities that have no exploitable path
- Auditing for style/naming/maintainability (review-code covers that)
- Duplicating review-code's 12-dimension audit under a different name

## Composition

- Follows well with: `review-qa` (to verify the fixes)
- Complements: `review-stakeholder` (red-team finds technical failures, stakeholder finds human failures)
- Conflicts with: none

## Examples

**User:** "Red-team review this authentication module: src/auth/login.py"

**Agent reads the file, traces the code, and produces:**

```
## Section 1: Red-Team Critique

### Injection Vectors
1. Location: login.py:23
   Attack vector: POST /login with email="admin' OR '1'='1' --"
   Mechanism of failure: SQL query built by string interpolation. The injected
   payload short-circuits the WHERE clause, returning the first user row and
   bypassing password verification entirely.
   Severity: Critical
   Exploitation difficulty: Trivial — standard SQL injection payload, no auth required
   Suggested fix: Use parameterized queries with placeholders.
   Attack narrative: Unauthenticated attacker sends crafted email → DB returns first
   user row → password check is bypassed → full account takeover.

### Authentication & Authorization
2. Location: login.py:45
   Attack vector: Repeated login attempts with different passwords
   Mechanism of failure: Password compared with ==, which short-circuits on first
   byte mismatch, leaking timing information for byte-by-byte password recovery.
   Severity: High
   Exploitation difficulty: Moderate — requires ~1000 samples per byte
   Suggested fix: Use hmac.compare_digest() for constant-time comparison.

### Resource Exhaustion
3. Location: login.py:12
   Attack vector: Repeated login attempts with very long usernames
   Mechanism of failure: No rate limiting or input length check. Attacker can
   trigger unbounded query construction and database load.
   Severity: Medium
   Exploitation difficulty: Trivial — script sending POST requests
   Suggested fix: Add input length validation and rate limiting.

## Section 2: Improved Artifact

[Unified diff with inline comments]
```
