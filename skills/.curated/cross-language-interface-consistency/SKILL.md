---
name: "cross-language-interface-consistency"
description: "Ensure symbols crossing language boundaries (FFI, XS, pybind11) stay in sync across implementations"
version: "1.0.1"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence", "terminal_operations"]
tags:
  - architecture
  - safety
  - boundaries
lens: consistency
authority_tier: 1
---

# Cross-Language Interface Consistency

## When to Use

- Editing a symbol that crosses a language boundary (FFI, XS, pybind11, C ABI shim)
- Understanding how CLIO/SAM/ALICE coordinate across Perl, Swift, C++, and Python
- Adding a new boundary crossing between two languages
- Debugging a runtime failure that occurs only at a boundary
- Auditing whether a boundary is still in sync

A tool cannot solve this because the tool cannot know *which* symbols are
meant to cross a boundary. That intent is domain knowledge. This skill encodes it.

## When Not to Use

- Editing within a single language with no boundary crossing
- Making purely cosmetic changes (whitespace, comments) to boundary code

## The Boundary Manifest

The manifest at `.clio/cross-language-symbols.json` is the single source
of truth. Every symbol that crosses a language boundary MUST be listed.
Format:

```json
{
  "version": 1,
  "boundaries": [
    {
      "id": "perl-swift-ffi-example",
      "from": { "language": "perl", "symbol": "CLIO::Memory::recall_sessions" },
      "to":   { "language": "swift", "symbol": "CLIOMemory.recallSessions" },
      "mechanism": "ffi",
      "abi_stable": false,
      "verified_at": "2026-01-15",
      "notes": "Returns hashref; Swift side decodes as Dictionary"
    }
  ]
}
```

## Instructions

This skill activates before any edit that touches a symbol listed in the
manifest. If you cannot find the manifest, ask the user where boundary
definitions live rather than guessing.

### Step 1: Identify the boundary

Name the exact symbol being edited: `Package::sub_name`, `Module.ClassName.method`,
or the C++/Swift equivalent. Look it up in the manifest.

- If the manifest file (`.clio/cross-language-symbols.json`) does not exist,
  ask the user where boundary definitions live rather than guessing. If no
  manifest is available and no boundaries are known, this skill cannot
  activate — report that the project has no known cross-language boundaries.
- If the symbol is not in the manifest but crosses a boundary: STOP. Add it
  to the manifest first. An unmapped boundary is worse than a mapped one.
- If in the manifest: load the full boundary record.

### Step 2: Read both sides

Read the source side and the target side of the boundary.

```
SOURCE: <language> <file>:<line> — current signature, return shape
TARGET: <language> <file>:<line> — current usage, expected shape
```

### Step 3: Verify the compatibility matrix

```
ASPECT         | SOURCE (current) | TARGET (expects) | MATCH?
---------------|------------------|------------------|--------
arity          | 3                | 3                | yes
param types    | (str, str, int)  | (str, str, int)  | yes
return shape   | hashref          | Dictionary       | yes
error contract | dies on missing  | returns nil      | NO
ownership      | caller frees     | callee frees     | NO
abi_stable     | false            | —                | n/a
```

Any NO in the MATCH column requires both sides to be updated in the
same change set.

### Step 4: Handle ABI stability

If `abi_stable` is `true`:
- Do NOT change the signature. Add a new versioned symbol instead.
- Update the manifest to add the new symbol; keep the old one.
- Deprecate the old symbol with a `deprecated_at` field.

If `abi_stable` is `false`:
- Signature changes are permitted, but both sides must change together.

### Step 5: Assemble an atomic change set

A single commit containing:

1. Source-side edit
2. Target-side edit
3. Test updates on both sides
4. Documentation update referencing the boundary id
5. Manifest update: new signature, new `verified_at` date

Nothing partial. Nothing "I'll update the Swift side next session."

### Step 6: Run tests and record verification

Run, at minimum:

- Source-language unit test for the symbol
- Target-language unit test that calls across the boundary
- A round-trip test: source -> target -> source returns equal values

If no round-trip test exists, write one. It becomes part of the
boundary's `verified_at` evidence.

Update the manifest:

```
verified_at: <today>
last_change_commit: <sha>
```

If verification could not be completed (e.g., target language toolchain
unavailable), set:

```
verification_status: "pending"
verification_note: "<what could not be run>"
```

### Step 7: Record outcomes

Log to `.clio/boundary-verifications/<boundary-id>.log` (appended).
Add long-term memory entry: "boundary <id> changed; both sides updated."

## Anti-Patterns

- Editing only the source side "because the target still compiles"
- Casting at the boundary to hide a shape mismatch
- Treating FFI/XS/pybind11 bindings as generated code that "someone else"
  will regenerate
- Adding a boundary symbol without adding it to the manifest
- Changing an `abi_stable: true` symbol without versioning it
- Skipping round-trip tests because "the unit tests pass on both sides"

## Examples

**User:** "I'm renaming `CLIO::Memory::recall_sessions` to `recall` in the Perl side. The Swift FFI binding calls it too."

**Agent:**
1. Checks `.clio/cross-language-symbols.json` — finds boundary id `perl-swift-ffi-001`
2. Reads both sides: Perl `Memory.pm:210` and Swift `CLIO.swift:340`
3. Builds compatibility matrix — arity matches, return shape differs (Perl returns hashref, Swift expects named tuple)
4. Both sides must change. Writes both edits, updates both test files, updates the manifest with new `verified_at` date
5. Runs round-trip test: Perl calls Swift via FFI, Swift returns, Perl receives — values match
6. Logs to `.clio/boundary-verifications/perl-swift-ffi-001.log`
