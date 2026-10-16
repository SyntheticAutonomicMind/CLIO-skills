---
name: "incremental-upstream-merge"
description: "Cherry-pick upstream commits into a fork in small groups with a fast automated test after each group, isolating regressions to a known commit range. Use when integrating a large batch of upstream commits, when previous full-merge attempts caused regressions, or when the fork has divergent subsystems."
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["version_control", "terminal_operations", "todo_operations", "memory_operations"]
tags:
  - git
  - merge
  - fork
  - incremental
  - upstream
  - vcs
lens: git
authority_tier: 1
---

# Incremental Upstream Merge

This skill captures the procedure for bringing a batch of upstream commits into a
divergent fork **without losing any downstream features, functionality, or bug
fixes**. The single-shot merge of a large batch is high-risk: one bad commit
among 100 is hard to find, and bisecting through a half-broken tree is slow.
The incremental approach isolates failure to a known group of commits, narrows
to a single commit, and the test loop is fast enough to be iterative.

**Key invariant: every downstream commit that survived before the merge
must survive after it.** Upstream commits can be reverted, adapted, or
skipped, but fork-only code is never discarded unless the user explicitly
agrees.

## When to Use

- A fork is behind the upstream project by 50+ commits and both have diverged.
- A previous full-merge produced a regression no one could isolate.
- The fork has divergent subsystems (custom build paths, extra modules, vendored
  code, performance rewrites) that may conflict with upstream changes in
  non-obvious ways.
- A simple `git merge upstream/master` is impractical because the conflict
  surface is too large to reason about.
- You have a fast automated test (sub-minute) that gives a clear GOOD/BAD
  signal on each commit.

## When Not to Use

- The fork has no divergent subsystems (just a few patches on top). Use
  `git merge upstream/master` directly.
- The bug is in a single upstream commit you can identify without bisecting.
- The fork and upstream are essentially identical (lag < 5 commits).
- The merge is "we have a fix, you have it too" — just cherry-pick the one commit.
- You do not have a fast automated test. The incremental approach depends on
  testing after each small group; without it, you gain nothing over a full merge.

## End State

When the merge is complete, the working branch has all upstream commits plus
any necessary adaptation fixes, verified at HEAD by the test. The skill does
NOT require a clean linear history — the final integration into the main
branch can be a real `git merge` that collapses the cherry-pick chain into a
single merge commit and gives a clean `--first-parent` view.

## Inputs

- **fork_repo** (required): Path to the fork's git working tree.
- **upstream** (required): The upstream remote to pull from (e.g., `upstream`).
- **upstream_branch** (required): The branch on upstream to merge from (e.g., `master`).
- **test_script** (required): Path to a fast (sub-minute) automated test script
  that gives a deterministic GOOD/BAD verdict.
- **baseline_commit** (optional): The fork's HEAD before starting. Defaults to
  current HEAD.
- **branch_name** (optional): Working branch name. Defaults to
  `incremental-merge-<date>`.

## Prerequisites

1. **Verified test script.** The project must have a fast (sub-minute) automated
   test that gives a clear GOOD/BAD signal on the current commit.
   - The test must rebuild the fork before running so the binary matches HEAD.
   - The test must give a deterministic, parseable GOOD/BAD verdict.
   - The test must work on the baseline commit BEFORE you start. If it doesn't,
     fix the test first — do not start the merge.
   - Treat the test as suspect, not gospel. If the test was flaky in a previous
     session, re-verify the baseline 3 times before starting. A flaky test is
     worse than no test because it produces false positives.

2. **Backup tag.** Tag the baseline commit so you can `git reset --hard <tag>`
   and start over if everything goes wrong.

3. **Backup branch.** Branch off a `backup-before-merge-...` branch for fast
   recovery if the working branch becomes unfixable.

4. **Commit count.** Know exactly how many commits you are merging. Write down
   the number so you can track progress.

## Generic Test Script Template

For projects that don't have a test script yet, use this template:

1. `REBUILD_CMD` — command that rebuilds the project
2. `START_CMD` — command that starts the test service
3. `READINESS_CHECK` — shell command that exits 0 when the service is ready
4. `TEST_PROMPT` — command that runs the actual test
5. `EXPECTED_OUTPUT` — substring to grep for in the test response

The template handles: build, kill leftover processes, start service with
line-buffered output, poll for readiness, run the test prompt, parse response,
exit GOOD/BAD. Customize the 5 variables for your project.

## Group Sizing Strategy

The group size is the most important dial:

- Start at 5 commits per group.
- Bump to 10 once you've had 3-4 clean groups in a row.
- Halve the group size when a group fails.
- Drop to 1 commit per group when bisecting within a failed group.
- For the final batch, you can use a larger group (10-15) if you're confident.

The pattern that emerges in practice: start at 5, bump to 10 once a few groups
are clean, halve when BAD. Behavioral regressions typically surface in the
middle-to-late groups once the batch size is at 10.

## Workflow Per Group

1. **Pick the next `group_size` commits from upstream, oldest first:**

   ```bash
   git log "${baseline_commit}..${upstream}/${upstream_branch}" --first-parent --reverse \
     | head -n "${group_size}"
   ```

   Look at each commit's subject and files-touched. Note any that look like deep
   changes to subsystems the fork has diverged on — those are high-risk commits.

2. **Cherry-pick the group:**

   ```bash
   git cherry-pick <hash1> <hash2> ... <hashN>
   ```

3. **Resolve conflicts.** The general rule: keep the fork's version when the fork
   has a divergent carry on this subsystem, and keep upstream's version when the
   fork is clean. The fork's carry is usually more advanced but may need
   adjustment to compile against upstream's new neighbors.
   - Auto-resolved conflicts — re-check the resulting file. Git's auto-merge can
     "succeed" but produce a file with a leftover conflict marker you need to grep for.
   - Conflicts in subsystems the fork has diverged on — keep the fork's version
     and document why in the commit message.
   - Conflicts in code the fork hasn't touched — take upstream's version.

4. **Apply build fixes.** Build conflicts that surface after cherry-pick
   (uncommented references, missing includes, missing struct fields) are part
   of the same cherry-pick commit. Don't defer them to a separate "fix" commit
   unless they're large enough to need their own commit message.
   - Cherry-pick, then fix back to the fork's version.
   - **Struct-field additions:** add the upstream field to the struct, populate
     it, but keep the fork's existing usage. Both paths can coexist; runtime
     selects based on a gate (env var, feature flag, version check).
   - **Identifier renames** (field-to-method, function rename, type rename):
     see the [Identifier Rename Procedure](#identifier-rename-procedure) below.
     A bare grep is not enough — you also need to know what patterns indicate a
     missed callsite.

5. **Run the test:**

   ```bash
   bash "${test_script}"
   ```

6. **Interpret result.** Distinguish three outcomes:

   - **GOOD** → continue to the next group. Commit the cherry-pick with
     `--amend` if you made build fixes.
   - **BAD (build fail)** → fix the build, re-test. If the test passes after the
     build fix, the fix is good — continue. Build failures are routine and
     usually auto-fixable; do not panic on them.
   - **BAD (test fail)** → you have a real behavioral regression. Halve the group
     size for this region and narrow to the specific bad commit. The test was
     passing on the baseline, so the regression is in one of the commits you
     just added.

7. **Document the group.** Record in the session log:
   - Group number, commit range, result, HEAD hash, notes
   - For BAD groups: symptom, root cause, fix

8. **Don't trust flaky results.** If the test was flaky in a previous session,
   re-verify the baseline before each session.

## Parallelizing the Build/Test Loop

The bottleneck is build time, not thinking time. For a 30s test and a 60-180s
rebuild, the wall-clock per group is 90-210s. To compress this:

- **Kick off the rebuild in the background** immediately after the cherry-pick
  finishes. While the build runs, do conflict resolution and build-fix work in
  the source tree. The next iteration's build can start as soon as the previous
  build completes.
- **Pre-stage the next group's cherry-pick** while the test is running. Cherry-
  picking 5 commits is cheap (seconds) compared to the test duration.
- **Run multiple test invocations in parallel** only if the test is read-only
  (no shared state, no servers, no ports). If the test starts a service or
  touches shared resources, don't parallelize.

## When to Stop and Ask

The skill assumes the agent can resolve all conflicts and build fixes autonomously.
Stop and ask the user when:

- The same file has 20+ conflict hunks in a single group.
- A conflict requires understanding the project's domain logic (e.g., "which of
  these two implementations of a core algorithm is correct for this
  architecture?").
- The build fails for a reason that isn't in the cherry-pick (e.g., a header
  that was supposed to exist doesn't, or a dependency that was supposed to be
  available isn't).
- The test is flaky — 2 GOOD then 1 BAD at the same commit is a flaky test, not a
  real regression. Re-verify 3 times before drawing conclusions.

## Identifier Rename Procedure

When upstream renames a symbol, the cherry-pick auto-merges most references but
silently misses others. A bare grep for the old name is not enough because:

- It matches the declaration site, which may have been updated already.
- It doesn't distinguish between the old accessor and the new one (both may be
  spelled the same in source).
- It misses call sites that need syntax changes (adding parens for a method call,
  changing `field` to `obj.field`, etc.).

The procedure:

```bash
# Find all references to the old identifier
grep -rn '<old_name>\b' <source_dirs> \
  | grep -v '\.h:' \
  | grep -v '<old_name_max>\|<old_name_arr>'
```

For each match, classify it:

- **Declaration site** (e.g., `<type> <old_name>;` in a struct): leave it — the
  cherry-pick already updated it.
- **Assignment** (`<old_name> = ...` or `obj-><old_name> = ...`): if the new API
  uses an accessor, change to `obj.set_<new_name>(...)` or `obj.<new_name> = ...`.
  Check the upstream diff for the new API shape.
- **Read** (`<old_name>` or `obj-><old_name>`): if the new API is a method, add
  parens. If the new API still has a public field, leave it.
- **Comment or string**: leave it.

**Common miss patterns:**

- **Loop body access.** When the identifier is accessed inside a loop over layers
  or batches, the loop variable is fine but the body may have a missed call site.
- **Macro/template expansion.** Macros that expand to field access may have been
  updated upstream but callsites use the old spelling.
- **Helper functions.** If a helper reads `<old_name>`, the helper signature is
  fine but the body may need updating.

## Reverting an Upstream Commit Mid-Group

When a cherry-picked commit breaks the build or the test, and the cleanest fix
is to not have the commit at all:

```bash
git revert <upstream_hash> --no-commit
git commit -m "Revert upstream <hash> because <reason>"
```

This preserves the upstream commit's author and message in history, and is
reversible if you later find a way to make the commit work.

**When to use revert vs. fix-in-place:**

- **Revert** when the upstream commit fundamentally conflicts with the fork's
  carry on the same subsystem (e.g., both implement the same feature differently).
- **Fix-in-place** when the upstream commit is mostly right but has a small bug
  (missed callsite, missing field).
- **Revert + reapply with follow-up** when upstream ships a bad commit and the
  fix is in the next group. Revert the bad commit, then in the next group apply
  both the original commit and its fix together.

## Bisection Within a Failed Group

When the test fails, narrow within the group. Two patterns:

**Pattern A: Reset and reapply (clean history)**

```bash
git reset --hard <baseline_before_group>
# Cherry-pick commits one at a time, testing after each.
```

**Pattern B: Selective revert (preserve progress)**

```bash
# Revert all commits in the failed group (in reverse order)
for commit in <hashN> <hashN-1> ... <hash1>; do
  git revert $commit --no-commit
done
git commit -m "Revert group N commits after test failure"
# Re-apply commits one at a time from the baseline
```

Pattern A is simpler and gives a clean history. Pattern B preserves any
auto-merge conflicts that git may have resolved correctly during the original
cherry-pick, but is more complex.

## Session Log Template

Track progress in a markdown log file:

```markdown
| Group | Range | Result | HEAD | Notes | Downstream Preserved |
|-------|-------|--------|------|-------|---------------------|
| 1     | A..B  | GOOD   | abc123 | 5 commits, clean | feature-X: OK, feature-Y: OK |
| 2     | B..C  | BAD    | def456 | build error, fixed in group | feature-X: OK (ported to types.h) |
```

## Post-Merge Downstream Audit

After the final group passes and the merge branch is at a verified HEAD,
audit that downstream features survived:

1. **Compare feature branches.** If the fork has named branches for
   downstream features, verify they still merge cleanly into the merged
   HEAD (they may need rebase, but should not be broken).

2. **Diff against the backup tag.** Compare the merged HEAD to the
   `backup-before-merge-...` tag. Every file/directory that existed in the
   fork before the merge should still exist, unless an upstream commit
   intentionally removed it (and you agreed to that removal).

3. **Check downstream-only symbols.** If the fork added functions, classes,
   CLI flags, config options, or API endpoints, verify they are present at
   HEAD:

   ```bash
   git diff <backup_tag> HEAD --name-only | head
   ```

   Walk through added/modified files to confirm downstream additions survive
   the restructure. The cherry-pick conflict resolution step (keep fork's
   version on divergent subsystems) handles this per-group, but a final
   sweep catches anything auto-merged incorrectly.

4. **Run the downstream test suite.** If the fork has additional tests for
   its downstream features, run them against the merged HEAD. These tests
   may not be part of the fast per-group test script.

## Composition

- This skill is the **incremental** approach to upstream integration. For
  a single conflict-heavy merge with no test loop, see `merge-conflict-resolution`.
- For verifying cross-language interface consistency (when the fork has
  bindings to C, Swift, or other languages that touch upstream-changed symbols),
  hand off to `cross-language-interface-consistency`.
- For post-merge code quality review, use `review-code` or `review-compose`.
- For verifying the merged result works correctly, use `review-qa`.

## Examples

**User:** "We're 156 commits behind upstream master on our llama.cpp fork.
The last full merge introduced a regression in batch processing that we
couldn't isolate. We have a bisect-echo-test.sh that takes 30 seconds and
gives GOOD/BAD."

**Agent:**
1. Tags the baseline: `git tag backup-before-merge-2025-05-14`
2. Creates a working branch: `git checkout -b incremental-merge`
3. Runs the test once at baseline — GOOD
4. Estimates group size: starts at 5
5. Cherry-picks first group of 5 commits, resolves conflicts (keeps fork's
   divergent carry in subsystem configs), builds, tests — GOOD
6. Groups 2-4: all GOOD, bumps group size to 10
7. Group 5: BAD (test failure, not build). Halves to 5.
8. Groups 6-7 (size 5): GOOD
9. Group 8: BAD. Bisects within the group, finds commit `b3f7a92` introduced
   the regression. Reverts it, reapplies with the follow-up fix from group 9.
10. Groups 9-30: mixed GOOD/BAD, adjusts group size dynamically.
11. Final merge into the fork's main branch via `git merge --no-ff`.
