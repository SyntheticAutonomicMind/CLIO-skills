---
name: "audit-ui"
description: "Adversarial audit of a UI/interface system — feature matrix, control-to-backend tracing, state sync, responsiveness, and discoverability"
version: "1.0.0"
author: "Andrew Wyatt (Fewtarius)"
tools: ["file_operations", "code_intelligence", "terminal_operations"]
tags:
  - audit
  - ui
  - systematic
  - adversarial
lens: methodology
authority_tier: 1
---

# Adversarial UI Audit & Remediation

## When to Use

- Auditing a user interface for functional correctness, state synchronization, discoverability, and layout integrity
- When UI controls may appear correct but apply wrong configuration
- Before a major release where UI quality matters
- When investigating reports of settings not persisting, controls being hidden, or layout breaking on certain devices
- Any scenario where the question is "does this UI actually work correctly across all conditions?"

## When Not to Use

- Reviewing a single component for quality (use `review-code` on the component)
- When you only need to find security vulnerabilities in the UI (use `review-redteam`)
- When the UI is purely static with no interactive state

## Inputs

- **repository_path** (required): Path to the repository root.
- **ui_entrypoint** (optional): The main UI entry point file or directory (e.g., `src/renderer.tsx`, `ui/src/`). If omitted, the auditor must locate it.
- **runtime_context** (optional): Description of the target runtime environment (e.g., "Steam Deck Decky overlay, 1280x800, controller navigation", "web app on desktop browsers", "mobile app iOS/Android"). This constrains viewport and interaction testing.
- **known_ui_issues** (optional): UI issues already identified that can be cross-checked.

## Instructions

You are performing a **rigorous, adversarial audit of a user interface and its supporting frontend/backend behavior.** This is not a superficial visual review, a list of generic UX recommendations, or an indiscriminate redesign. Treat the interface as a system whose correctness must be established through evidence.

### Phase 1: Repository Inspection

Before making changes, inspect the repository:

- Read `AGENTS.md`, `STYLE_GUIDE.md`, `README.md`, `package.json`, and the relevant project instructions.
- Inspect the actual repository state, current branch, uncommitted changes, and recent history.
- Map the frontend entry point, UI components, state management, backend RPC handlers, profile/configuration code, and device-specific capability detection.
- Identify the supported runtime environment, particularly any overlay/desktop/handheld configurations supported by the project.
- Determine which build, test, lint, type-check, and development tools are actually available.
- Establish a baseline build and run existing tests where practical.

Do not overwrite user changes, reset the working tree, or perform destructive operations without explicit authorization. Do not infer functionality solely from README descriptions or comments. Verify the implementation.

### Phase 2: Feature Matrix Construction

Enumerate all user-facing features and controls, including those that are conditionally rendered or accessible only through secondary views. For each capability, record:

| Capability | Implementation Location | UI Location | How Users Reach It | Visibility/Availability Conditions | Frontend State / Backend RPC | Persistence/Application Semantics | Device/Power-Source Dependencies | Test Coverage | Verified Defects |
|---|---|---|---|---|---|---|---|---|---|---|

Trace each feature from the visible control through its state transitions and backend call to its resulting effect. For read-only information, trace the data source and refresh mechanism.

**Assume that apparently working controls may contain subtle defects.**

### Phase 3: Control Correctness Audit

For every interactive control, verify:

1. The displayed value corresponds to the intended setting.
2. The control uses the correct units, range, step size, and permitted values.
3. Minimum and maximum values are derived from actual capabilities where required, not arbitrary assumptions.
4. The correct backend method receives the correct arguments.
5. The returned result is checked and interpreted correctly.
6. Failed operations do not silently appear successful.
7. The UI reflects the actual outcome rather than merely echoing the requested value.
8. The setting is persisted when expected and survives reloads or navigation.
9. Reset, cancel, and restore operations have well-defined semantics.
10. Rapid interactions, repeated clicks, and overlapping requests do not corrupt state.

Investigate mismatches between sliders, numeric labels, profile values, backend responses, and hardware readings.

### Phase 4: State Synchronization Audit

Exercise important transitions, not just isolated controls:

- AC connected -> battery operation -> AC reconnected
- Global profile -> game-specific override -> inherited default
- Open settings -> modify value -> navigate away -> return
- Change a setting -> save -> reload the plugin
- Begin a request -> change views or profiles before the request completes
- Receive stale data after a newer request has already completed
- Encounter an RPC failure, unsupported hardware feature, or missing sysfs interface
- Change device capability or availability conditions, where reproducible
- Open and close dialogs, expand and collapse sections, rapidly navigate between views

Look for stale closures, race conditions, incomplete effects, incorrect dependencies, uncontrolled inputs, optimistic updates without rollback, and conflicting sources of truth. Do not assume every transition is defective. Establish whether each failure can actually occur.

### Phase 5: Profile and Configuration Audit

Treat profiles as a particularly high-risk area because the UI can look correct while applying the wrong configuration.

Verify:

1. Correct identification and selection of the active context (game, device, profile).
2. Correct precedence between global defaults, inherited values, and explicit overrides.
3. Correct separation of AC and battery settings.
4. Correct handling of missing, partial, and malformed profiles.
5. Correct creation, editing, reset, and persistence behavior.
6. Correct behavior when switching contexts or when context detection changes.
7. No accidental mutation of another profile.
8. No silent loss of unsaved changes.
9. No confusing presentation of inherited values as explicit overrides.

Confirm actual backend semantics before proposing changes to inheritance or profile behavior.

### Phase 6: Error Handling and Edge Case Audit

Investigate empty states, missing capabilities, invalid values, unavailable hardware interfaces, permission problems, backend exceptions, malformed responses, and partial failures.

Check whether users can distinguish:

- A setting that is unsupported.
- A setting that is temporarily unavailable.
- A setting that is available but not currently applied.
- A setting that has been saved but has not taken effect.
- A request that failed.
- A value that is inherited rather than explicitly configured.

Do not introduce false success indicators or fabricate hardware state when data is unavailable.

### Phase 7: Feature Exposure and Discoverability Audit

A feature that exists in the backend but cannot reasonably be discovered or operated through the UI is a functional product defect.

For every implemented capability, ask:

1. Is the feature exposed anywhere in the interface?
2. Is it reachable using the actual navigation available to the user?
3. Is it hidden behind an unnecessary interaction or ambiguous label?
4. Is its visibility controlled by the wrong capability flag or stale state?
5. Does a feature disappear because of a failed detection request rather than a genuine hardware limitation?
6. Is it shown on devices where it cannot work?
7. Are relevant controls hidden when an alternative implementation is available?
8. Are advanced capabilities unnecessarily buried alongside unrelated settings?
9. Are users told why a control is unavailable?
10. Does the interface distinguish unsupported hardware from temporary detection failures?
11. Are labels, units, tooltips, and descriptions sufficient to understand a control?
12. Are related settings grouped according to the user's task rather than internal implementation details?
13. Are important actions needlessly difficult to reach or repeatedly require navigation?

Inspect conditional rendering and capability detection all the way back to the backend. Do not fix a hidden control by simply making it visible unconditionally.

Distinguish between:

1. A missing UI for an existing feature.
2. A feature that is implemented but unreachable.
3. A feature that is incorrectly hidden.
4. A feature that is correctly unavailable on the current device.
5. A genuinely missing backend capability.

Recommend new functionality only when evidence shows that it is needed. Do not expand scope merely to make the UI look more comprehensive.

### Phase 8: Responsiveness and Layout Audit

Evaluate the interface in its actual runtime context, not just as a desktop webpage.

Test or inspect, where supported:

- Narrow handheld overlay dimensions.
- Different overlay heights and widths.
- Expanded and constrained plugin panels.
- Long game names, device names, profile names, and setting descriptions.
- Long numbers, unusual values, and unavailable-data placeholders.
- Large numbers of settings or profile entries.
- Expanded sections combined with dialogs and notifications.
- Content near the top and bottom of a scrollable panel.
- Rapid changes in content height.
- Text wrapping, truncation, overflow, clipping, and horizontal scrolling.

Check whether users can reach every control without content being obscured or clipped.

Inspect:

- Fixed widths, heights, margins, and positioning.
- Flexbox/grid constraints and nested scrolling.
- Incorrect assumptions about the available viewport.
- Elements extending beyond their parent containers.
- Overlapping controls and insufficient spacing.
- Sliders, toggles, buttons, and dialogs that become difficult to operate.
- Scroll containers that trap scrolling or prevent access to lower controls.
- Focus indicators and keyboard/controller navigation where supported.
- Conditional sections that destabilize layout.
- Excessive re-rendering or expensive work that makes interaction feel unresponsive.

Use actual screenshots, browser inspection, or runtime testing when available. If no runtime is available, perform static analysis and clearly distinguish verified defects from hypotheses.

Do not blindly add CSS media queries. Determine whether the problem comes from the component structure, the UI primitives, parent constraints, scrolling behavior, or the available viewport.

### Phase 9: Performance and Interaction Quality Audit

Investigate:

- Slow initial rendering.
- Controls that block while backend operations are running.
- Duplicate RPC calls.
- Excessive polling or repeated hardware reads triggered by rendering.
- Unnecessary component re-renders.
- Large synchronous calculations.
- Requests that never clear loading indicators.
- Interactions that provide no immediate feedback.
- Rapid slider movement generating excessive backend operations.
- Slow operations that freeze unrelated controls.

Distinguish rendering problems from hardware or backend latency. Preserve correct hardware application semantics when optimizing request frequency or debouncing interactions.

### Phase 10: Root Cause Analysis and Systemic Patterns

Do not stop after finding individual symptoms. Determine whether multiple defects share a common cause.

Inspect for:

- Duplicated components with inconsistent behavior.
- Repeated or contradictory capability checks.
- Multiple sources of truth for the same setting.
- State derived inconsistently from props, RPC responses, and local state.
- Incorrect effect dependencies.
- Stale closures and asynchronous updates after unmounting or view changes.
- Missing cancellation, request ordering, or stale-response protection.
- Overly broad error handling that hides real failures.
- Backend handlers whose return contracts do not match frontend assumptions.
- Inconsistent naming or units between frontend and backend.
- Device-specific logic embedded in unrelated presentation components.
- Overloaded components with too many independent responsibilities.
- CSS rules that accidentally affect unrelated sections.
- Dead code, unreachable controls, obsolete feature flags, and duplicated configuration.
- Tests that validate implementation details without validating user-visible behavior.

Refactor shared logic when it is demonstrably responsible for defects or when a small, well-scoped abstraction prevents repeated errors. Avoid broad rewrites without evidence. Preserve working behavior and existing project conventions unless those conventions are themselves causing the problem.

### Phase 11: Remediation

For every confirmed defect:

1. Identify the root cause before modifying code.
2. Keep the patch as small as practical.
3. Preserve unrelated functionality and compatibility.
4. Add regression tests.
5. Update types and contracts when necessary.
6. Follow `STYLE_GUIDE.md` and `AGENTS.md` unless the audit establishes that a convention needs correction.
7. Run relevant tests, frontend builds, and syntax/type checks.
8. Inspect the final diff for accidental changes, dead code, and regressions.
9. Do not change hardware safety limits or device-specific behavior without establishing the correct underlying semantics.
10. Do not commit or push changes unless explicitly authorized.

If runtime validation is unavailable, report exactly what was and was not verified.

### Phase 12: Self-Audit Pass

After remediation, conduct a second pass targeting your own changes. Ask:

- Did the original failure scenario now work correctly?
- Did the fix introduce contradictions with other components?
- Are the fixes scoped to the root cause?
- Do the regression tests actually exercise the corrected behavior?
- Does the change preserve behavior outside the affected area?
- Did I move the bug somewhere else?

### Defect Reporting Format

Every reported defect must contain:

```
ID: stable identifier
Category: Functional, Exposure, Responsiveness, State, Performance, or Architecture
Severity: Critical, High, Medium, or Low
Location: relevant files, components, functions, and line numbers where available
Evidence: reproducible behavior, failing test, incorrect state transition, or concrete code path
Expected behavior: what should happen
Actual behavior: what demonstrably happens
Root cause: why the defect occurs
Fix: the smallest reliable correction
Regression coverage: the test or verification procedure that prevents recurrence
Confidence: Confirmed, Strongly Supported, or Unverified Hypothesis
```

Use severity based on real impact, not aesthetic preference. Do not report a speculative concern as a confirmed bug. Do not inflate findings by splitting one root cause into many superficial issues. Group related symptoms when they share a systemic cause.

Also record important areas that were examined and found to work correctly. This prevents unnecessary changes to already-correct behavior.

### Output Format

Produce a single markdown document with the following sections:

**Section 1: Feature Matrix**
- The complete feature-to-UI mapping table with verification status.

**Section 2: Defects Found and Remediated**
- For each confirmed defect, the full reporting format above.

**Section 3: Areas Working Correctly**
- Components, controls, or transitions that were examined and found to work correctly.

**Section 4: Responsive Layout and Viewport Coverage**
- Tested viewport conditions, observed layout failures, and any conditions that could not be tested.

**Section 5: Fixes Applied**
- List of fixes made, the rationale for each fix, and the regression tests added or updated.

**Section 6: Verification Report**
- Commands executed, build/test results, failures, environmental limitations, and remaining risks.

**Section 7: Unresolved Problems**
- Prioritized list of unresolved problems, distinguishing confirmed defects from unverified hypotheses and enhancements that are not necessary to fix existing defects.

### Constraints

- Do not perform a superficial visual review or generic UX recommendations.
- Do not infer functionality solely from documentation or comments.
- Do not overwrite user changes or perform destructive operations without authorization.
- Do not blindly add media queries without diagnosing the root cause.
- Do not introduce false success indicators when data is unavailable.
- Do not change hardware safety limits or device-specific behavior without establishing correct semantics.
- Do not commit or push changes unless explicitly authorized.
- Do not recommend new functionality unless evidence shows it is needed.

### Anti-Patterns

- Spot-checking a few controls and extrapolating to the entire UI
- Recommending CSS media queries without diagnosing root cause
- Reporting aesthetic preferences as functional defects
- Making hidden controls visible unconditionally ignoring capability detection
- Fabricating hardware state when data is unavailable
- Treating implementation details as public contracts
- Claiming tests pass that do not verify user-visible behavior
- Splitting one root cause into many superficial issues
- Ignoring device-specific or platform-specific constraints

## Composition

- **Complements:** `review-code` (for reviewing the implementation of specific UI components), `review-redteam` (for security-focused UI review), `review-stakeholder` (for human impact and journey analysis)
- **Uses internally:** `review-code` as a lens for component-level deep dives during the systematic pass
- **Trigger:** This skill is the top-level methodology for UI system auditing; it orchestrates the lens skills but is not itself composed into larger workflows
- **Followed by:** `review-qa` (to verify UI fixes)

## Examples

**User:** "Audit the UI in this React plugin for correctness."

**Agent:**
1. Reads package.json, AGENTS.md, STYLE_GUIDE.md, README.md — establishes build uses Vite + React + TypeScript, Decky UI framework
2. Maps entry point: `src/renderer.tsx` -> `App` -> `Dashboard`, `ProfileEditor`, `GlobalSettings`
3. Traces TDP control: `Dashboard.tdpSlider` -> `useState(tdpValue)` -> `applyTdp(value)` -> `ServerAPI.call("set_tdp", {value})` -> backend writes to `/sys/class/powercap/...` -> reads back via `get_tdp()`
4. Discovers: the slider's `max` is hardcoded to 25W, but `probeCapabilities()` reads `maxTdp` from sysfs and returns 30W on some devices — the slider silently caps at 25W on 30W devices
5. Discovers: after saving a profile, the `get_tdp()` response is received but the component has unmounted — stale closure in the async handler causes a crash
6. Builds feature matrix: 47 controls across 3 views, 5 have no test coverage
7. Writes regression tests for the TDP max value and the stale closure
8. Fixes: dynamic `max` from capabilities, guard async calls with `mounted` ref
9. Self-audit pass: verifies fix doesn't break the 25W device case
10. Final report: 2 Critical, 3 High, 5 Medium defects, 5 untested controls
