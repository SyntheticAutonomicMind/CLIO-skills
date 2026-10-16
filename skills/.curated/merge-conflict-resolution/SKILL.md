---
name: "merge-conflict-resolution"
description: "Resolve git merge conflicts by investigating both sides, preserving local additions, and integrating upstream restructuring"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["version_control", "file_operations", "terminal_operations", "code_intelligence", "todo_operations", "interact"]
tags:
  - git
  - merge
  - conflict-resolution
  - vcs
lens: git
authority_tier: 1
---

# Merge Conflict Resolution

## When to Use

- A `git merge` or `git pull` reports conflict markers in one or more files
- Merging one branch into another where both sides have substantive changes
- Resolving conflicts in C/C++ source files where one side has refactored code into new files
- Conflicts where local (HEAD) additions must be preserved but need to be relocated to match upstream's file structure

## When Not to Use

- Trivial text conflicts with no semantic overlap
- Conflicts that can be resolved with a simple "take theirs" or "take ours"
- Merge conflicts in generated/build artifact files

## Inputs

- **base_branch** (required): The branch being merged into (e.g., `unstable`)
- **upstream_branch** (required): The branch being merged from (e.g., `origin/master`)
- **conflict_files** (optional): List of files with conflicts. If not provided, extracted from `git status`.

## Instructions

You are resolving a merge conflict between a base branch and an upstream branch. The base branch (HEAD) has local modifications that must be preserved. The upstream branch may have restructured code (moving functions, types, or sections into different files). Your task is to reconcile both sides without losing any functionality from either.

### Procedure

1. **Survey the conflict.** Run `git status --short` to see which files are conflicted (status `UU`). Run `git log --oneline --graph origin/master...HEAD` to understand the divergence.

2. **For each conflicted file, identify the conflict regions.** Search for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`). Count them — expect multiple if the file was substantially restructured.

3. **For each conflict region:**
   a. **Read the HEAD side** (between `<<<<<<< HEAD` and `=======`). This is what your branch (e.g., unstable) had.
   b. **Read the upstream side** (between `=======` and `>>>>>>>`). This is what the branch you're merging in has.
   c. **Compare against the merge base.** Use `git show <merge-base>:<file>` to see what the common ancestor had. This tells you whether both sides changed the same lines or whether one side simply moved code.

4. **Classify each conflict region** as one of:
   - **Restructuring move:** Upstream moved code to a different file (e.g., types/structs moved from `foo.cpp` to `foo_types.h`). Accept upstream's version (the code now lives in the new file). You may need to port local additions (new functions, new fields) into the appropriate new file.
   - **Semantic change:** Both sides changed the same logic. Merge the changes by reading both and keeping the correct combined behavior. Prefer the upstream version for bug fixes, but preserve local-only additions.
   - **Pure addition on one side:** One side added code the other didn't touch. Keep the addition, adapting it to the destination side's structure (e.g., if upstream made a function non-static but your side added a new static helper, keep both).

5. **Resolve the file:** Edit the conflicted file to remove all conflict markers, producing a single coherent version. If local additions need to go to a different file (because upstream moved similar code), apply them there as separate edits.

6. **Stage the resolved file** with `git add <file>`. Verify no conflict markers remain with `grep -n '^(<<<<<<<|=======|>>>>>>>' <file>`.

7. **For relocated additions:** If upstream moved type definitions to `types.h` and your branch added a new field to a struct that now lives in `types.h`, add that field to the struct's definition in `types.h`. If your branch added a new function that calls upstream's moved helper, ensure the helper is still visible (check `extern` declarations or `static` visibility).

8. **Build and test.** After resolving all conflicts, build the project (`cmake -B build && cmake --build build -j`) and run relevant tests (`ctest -L main`). The merge is not complete until it builds and tests pass.

9. **Commit the merge.** Use `--no-ff` to preserve the merge topology: `git commit --no-edit` after staging all resolved files. If you need to write the merge message, use a summary of what was merged and how conflicts were resolved.

### Key Principles

- **Never silently drop local changes.** If your branch added a function, a struct field, a shader pipeline, or an environment variable, it must survive the merge in the correct location.
- **Trust upstream's restructure.** If upstream moved code into a new file for architectural reasons, don't fight it — port your additions to the new structure.
- **Check call sites.** After relocating an addition, verify that existing code (auto-merged from upstream) still references it correctly. Use `code_intelligence` to search for caller references.
- **Build early, build often.** A compile error tells you immediately which side won the semantic battle for a given block.
- **Preserve both parents.** After committing, verify with `git log --graph` that the merge commit has two parents.

### Pattern: Upstream File Split, Local Inline Additions

This is the most complex pattern and occurs when upstream splits a monolithic `.cpp` into multiple files, while a local branch kept additions inline.

**Detection:** Upstream's version of the file starts with `#include "new-header.h"` instead of the old includes, and the local version has the same code inline.

**Resolution:**
1. Accept upstream's version (includes moved to the new header file).
2. Extract local-only additions (new functions, new struct fields, new pipeline registrations) from the conflict region.
3. Place each addition in the correct new file:
   - Struct fields -> `types.h` (or wherever the struct definition now lives)
   - Standalone helper functions -> keep in the `.cpp` if they're not called from other TUs, or move to the appropriate new `.cpp` if they are called elsewhere
   - Template specializations -> the header where other specializations live
   - Shader pipeline registrations -> the `.cpp` that loads shaders (typically the same file)

## Anti-Patterns

- Accepting upstream's version and forgetting to port local additions
- Keeping local code in the old location when upstream moved the struct/function it depends on — it won't compile
- Leaving `static` linkage on a function that upstream made non-static (breaks callers in other TUs)
- Creating duplicate definitions (same function/field in both old and new file)
- Not building after resolving — conflicts can leave subtle inconsistencies
- Committing without `--no-ff` when the user asked to preserve history
- Not verifying the merge preserved all local commit history (`git log --first-parent`)
- Pushing when the user said not to

## Composition

- Hands off to: `review-code` (if merge introduces code quality concerns), `review-qa` (to verify the merged result)
- Related: standard git workflow (small incremental merges preserve history more easily than large conflict resolutions)

## Examples

**User:** "Let's carefully pull the changes from master into unstable, preserve commit history and markers. master -> unstable - don't push."

**Agent:**
1. Runs `git fetch origin && git merge --no-ff origin/master` on the `unstable` branch
2. Finds 1 file conflicted: `ggml-vulkan.cpp` with 6 conflict regions
3. For conflict 1 (includes/setup): accepts upstream's version (moved to `ggml-vulkan-types.h`), keeps only the `host-ram.h` include that was added locally
4. For conflict 2 (helper function declarations): keeps local's `ggml_vk_lightning_indexer_k_type_supported` (not in upstream base, used by local code) but uses upstream's non-static declaration for `ggml_vk_print_device_fault_info`
5. For conflict 3 (struct definitions): keeps local's `vk_op_lightning_indexer_cm_push_constants` struct (porting it to push-constants.h), uses upstream's non-static `ggml_vk_get_node_flops`, keeps local's `ggml_vk_get_node_bytes` helper
6. For conflict 4 (function definitions): keeps local's `ggml_vk_concat_is_transposed` helper, uses upstream's non-static `ggml_vk_concat_supported`
7. For conflict 5 (large block of moved code): accepts upstream's version (code moved to new files) since there are no local-only additions in this region
8. For conflict 6 (FA K/V type lists): keeps local's `ggml_vk_fa_kv_native` helper (used by local code to check K/V types), uses upstream's non-static `ggml_vk_flash_attn_coopmat_shmem_support`
9. Ports struct field additions to `ggml-vulkan-types.h`, struct + specialization to `ggml-vulkan-push-constants.h`
10. Builds successfully with `GGML_VULKAN=ON`, 52/53 tests pass
11. Commits merge with `--no-ff`, does not push
