# CLIO Skills

A curated collection of skills for CLIO (Command Line Intelligence Orchestrator).

## What are Skills?

Skills are prompt templates that give CLIO specialized knowledge and behavior for specific tasks. They're like "modes" that help the AI assistant excel at particular types of work.

## Skill Categories

### `.curated/`
Reviewed and approved skills for general use. These have been tested for quality and safety.

| Skill | Description |
|-------|-------------|
| `ansi-terminal-display` | Universal language-agnostic reference for terminal/TTY display: ANSI escape codes, box drawing (CP437/Unicode), visual alignment, wide chars, encoding pipeline, layout patterns, and common mistakes. Applies to all languages. |
| `capability-drift-check` | Periodically verify that model/API/tool capabilities still match cached assumptions |
| `change-impact-analyzer` | Pre-edit blast radius analysis for signature, interface, or symbol changes |
| `cross-language-interface-consistency` | Ensure symbols crossing language boundaries (FFI, XS, pybind11) stay in sync across implementations |
| `probe-engineer` | Hypothesis-driven debugging that blocks instrumentation until a falsifiable hypothesis is formed |
| `review-code` | Comprehensive code review across twelve dimensions, producing critique and improved implementation |
| `review-compose` | Run multiple review lenses in one pass and synthesize a composite verdict |
| `review-document` | Composite document review across twelve dimensions, producing critique and improved document |
| `review-firstprinciples` | Reconstruct the artifact from scratch using only requirements, then find accidental complexity |
| `review-premortem` | Assume the artifact failed catastrophically and reconstruct why |
| `review-qa` | Verify artifacts against stated requirements with evidence-based verdicts |
| `review-redteam` | Adversarial security and failure-mode review — find where artifacts break, how an attacker or failure scenario exploits them, and why |
| `review-stakeholder` | Map every stakeholder journey through the artifact to find friction, harm, and misalignment |
| `audit-codebase` | Systematic adversarial audit of an entire codebase — find, remediate, and verify defects across all subsystems with scope discipline and a self-audit pass |
| `audit-documentation` | Adversarial audit of an entire project's documentation system — inventory, cross-reference against implementation, detect contradictions, validate examples |
| `audit-ui` | Adversarial audit of a UI/interface system — feature matrix, control-to-backend tracing, state sync, responsiveness, and discoverability |
| `audit-skills` | Adversarial meta-audit of a composable LLM skills repository — inventory, interaction analysis, effectiveness testing, and redundancy detection |
| `cross-language-interface-consistency` | Ensure symbols crossing language boundaries (FFI, XS, pybind11) stay in sync across implementations |
| `incremental-upstream-merge` | Cherry-pick upstream commits into a fork in small groups with a fast automated test after each group, isolating regressions to a known commit range |
| `merge-conflict-resolution` | Resolve git merge conflicts by investigating both sides, preserving local additions, and integrating upstream restructuring |
| `probe-engineer` | Hypothesis-driven debugging that blocks instrumentation until a falsifiable hypothesis is formed |

## Installing Skills

CLIO can download and install skills from this repository:

```bash
# List available skills
/skills search

# Download and install a skill
/skills install <skill-name>

# Install into user scope (visible in all projects)
/skills install <skill-name> --scope=user
```

## Creating Skills

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on creating and submitting skills.

### Skill Structure

Each skill is a directory containing:

```
skill-name/
├── SKILL.md        # Required: Skill definition and instructions
├── LICENSE.txt     # Required: License (GPLv3)
├── agents/         # Optional: Agent configurations
├── scripts/        # Optional: Helper scripts
└── assets/         # Optional: Templates, examples, etc.
```

### SKILL.md Format

```markdown
---
name: "skill-name"
description: "Brief description (shown in /skills list)"
version: "1.0.0"
author: "Your Name"
tools: ["file_operations", "terminal_operations"]  # Optional: Tools this skill uses
tags:
  - review        # Optional: Categorization tags
lens: methodology  # Optional: Skill classification (reference, methodology, verification, etc.)
authority_tier: 1  # Optional: Authority level (1 = authoritative, 2 = advisory, etc.)
depends: []        # Optional: Other skills this skill references or composes
---

# Skill Name

## When to Use
- Scenario 1
- Scenario 2

## Instructions
Detailed instructions for the AI to follow...

## Examples
Example usage patterns...
```

## Security

All curated skills are reviewed for:
- Prompt injection risks
- Sensitive data handling
- Tool usage safety
- Code execution patterns

**Never run skills from untrusted sources.**

## License

Individual skills contain their own LICENSE.txt files. The repository and all included skills are licensed under the GNU General Public License v3.0 (GPLv3).
