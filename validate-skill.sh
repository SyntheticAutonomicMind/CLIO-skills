#!/bin/bash
# Validate a skill directory structure and content
# Exit codes:
#   0 = PASSED - Ready for human/AI review
#   1 = NEEDS CHANGES - Fixable issues (missing fields, format problems)
#   2 = REJECTED - Critical failures (security issues, missing required files)

# Fail on errors, undefined vars, and pipe failures (except where we expect failures)
set -uo pipefail

SKILL_DIR="$1"

if [ -z "${SKILL_DIR:-}" ]; then
    echo "Usage: $0 <skill-directory>"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    echo "ERROR: Directory not found: $SKILL_DIR"
    exit 1
fi

# Validation counters
CRITICAL_ERRORS=0  # Security issues, missing required files -> exit 2
FIXABLE_ERRORS=0   # Format issues, missing optional sections -> exit 1
WARNINGS=0         # Advisory only, doesn't block

echo "Validating skill: $SKILL_DIR"
echo "================================"

# ============================================================================
# CRITICAL CHECKS (will cause auto-reject)
# ============================================================================

echo ""
echo "CRITICAL CHECKS (Auto-Reject Failures)"
echo "---------------------------------------"

# Check for required files
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    echo "[FAIL] Missing SKILL.md (CRITICAL)"
    CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
    echo "[OK] SKILL.md exists"
fi

if [ ! -f "$SKILL_DIR/LICENSE.txt" ]; then
    echo "[FAIL] Missing LICENSE.txt (CRITICAL)"
    CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
    echo "[OK] LICENSE.txt exists"
fi

# Security checks (only if SKILL.md exists)
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    # Prompt injection patterns - covers common bypass variants
    if grep -qiE "(ignore|disregard|override|forget|discard)\s+(previous|prior|earlier|all|any|initial|original)\s*(instructions?|prompts?|commands?|rules?|guidance|directives|programming|training)?" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Prompt injection detected - instruction override pattern (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi
    
    # Broader injection patterns: jailbreak, role override, hidden instructions
    if grep -qiE "(you are now|you are free from|instead (follow|obey)|new directive|hidden instruction|override your (core|safety|security)|from now on|jailbreak|developer mode|dan mode)" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Prompt injection detected - role override or jailbreak pattern (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi
    
    if grep -qiE "(output|show|print|display|reveal|expose|leak).*(system prompt|system message|original prompt|internal instructions|base prompt|root prompt)" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Prompt leak attempt detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi
    
    # Dangerous shell commands - expanded pattern set
    # Note: We use [[:space:]] instead of \s and avoid ( and ) which cause
    # "parentheses not balanced" errors in GNU grep ERE mode.
    # Fork bomb patterns are detected in separate greps below.
    # Also note: we match command-like contexts only (line-start, prompt chars)
    # to avoid false positives in prose. The leading (^|[;|\\$'>])
    # ensures these are treated as commands, not prose mentions.
    if grep -qE "(^|[;|\\$'>])[[:space:]]*(sudo[[:space:]]+|doas[[:space:]]+)?(rm[[:space:]]+-rf[[:space:]]+[/~]|rm[[:space:]]+-rf[[:space:]]+\\\$\\\$HOME|eval[[:space:]]+\\\$\(|bash[[:space:]]+-i|sh[[:space:]]+-i|nc[[:space:]]+-e|curl.*\|[[:space:]]*(sh|bash)|wget.*\|[[:space:]]*(sh|bash)|dd[[:space:]]+if=.*of=/dev/(sd|nvme|disk)|chmod[[:space:]]+777|kill[[:space:]]+-9[[:space:]]+1|killall[[:space:]]+-9|systemctl[[:space:]]+(stop|disable|mask))" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Dangerous shell commands detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # Fork bomb detection (separate check - fork bomb patterns use ()
    # which conflict with ERE grouping syntax)
    # Match: :(){ :|:& };: or variants with different spacing
    if grep -qE ':[^a-zA-Z0-9()]{0,3}[[:space:]]*\(\)' "$SKILL_DIR/SKILL.md" 2>/dev/null; then
        echo "[FAIL] Security: Fork bomb pattern detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # mkfs detection (in command context only)
    if grep -qE "(^|[;|\\$'>])[[:space:]]*mkfs" "$SKILL_DIR/SKILL.md" 2>/dev/null; then
        echo "[FAIL] Security: mkfs command detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # shutdown / reboot detection (in command context only)
    if grep -qE "(^|[;|\\$'>])[[:space:]]*(shutdown|reboot|poweroff)" "$SKILL_DIR/SKILL.md" 2>/dev/null; then
        echo "[FAIL] Security: System shutdown/reboot command detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # Hardcoded credentials patterns
    if grep -qE "(password|api_key|secret|token)[[:space:]]*=[[:space:]]*['\"]?[a-zA-Z0-9_-]{20}" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Possible hardcoded credentials detected (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # Also check for YAML-style credential assignments
    if grep -qE "(api_key|secret|token|password):[[:space:]]+['\"]?[a-zA-Z0-9_-]{20}" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Security: Possible hardcoded credentials detected (YAML style) (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    # Executable code in skill files
    if head -1 "$SKILL_DIR/SKILL.md" | grep -q "^#!"; then
        echo "[FAIL] Security: Skill file has shebang (executable code not allowed) (CRITICAL)"
        CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
    fi

    if [ $CRITICAL_ERRORS -eq 0 ]; then
        echo "[OK] No security issues detected"
    fi
fi

# ============================================================================
# STRUCTURAL CHECKS (will request changes)
# ============================================================================

echo ""
echo "STRUCTURAL CHECKS (Fixable Issues)"
echo "-----------------------------------"

if [ -f "$SKILL_DIR/SKILL.md" ]; then
    # Check frontmatter exists
    if ! grep -q "^---" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] SKILL.md missing YAML frontmatter delimiters (---)"
        FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
    else
        echo "[OK] Frontmatter delimiters present"
        
        # Extract frontmatter (between first two ---)
        # Strip BOM if present, then extract first YAML block
        FRONTMATTER=$(sed '1s/^\xEF\xBB\xBF//' "$SKILL_DIR/SKILL.md" | awk '/^---/{if(++count==2)exit;next}count==1')

        # Check required fields (allow leading whitespace in frontmatter)
        if ! echo "$FRONTMATTER" | grep -qE "^\s*name:"; then
            echo "[FAIL] Missing required field: 'name:'"
            FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
        else
            echo "[OK] Field 'name:' present"
            
            # Validate name matches directory
            SKILL_NAME=$(echo "$FRONTMATTER" | grep -E "^\s*name:" | sed 's/^name:\s*//' | tr -d '"' | tr -d "'" | xargs)
            DIR_NAME=$(basename "$SKILL_DIR")
            if [ "$SKILL_NAME" != "$DIR_NAME" ]; then
                echo "[FAIL] Name mismatch: frontmatter='$SKILL_NAME', directory='$DIR_NAME'"
                FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
            else
                echo "[OK] Name matches directory"
            fi
        fi
        
        if ! echo "$FRONTMATTER" | grep -qE "^\s*description:"; then
            echo "[FAIL] Missing required field: 'description:'"
            FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
        else
            echo "[OK] Field 'description:' present"
        fi
        
        if ! echo "$FRONTMATTER" | grep -qE "^\s*version:"; then
            echo "[FAIL] Missing required field: 'version:'"
            FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
        else
            echo "[OK] Field 'version:' present"
            
            # Validate semantic versioning
            VERSION=$(echo "$FRONTMATTER" | grep -E "^\s*version:" | sed 's/^version:\s*//' | tr -d '"' | tr -d "'" | xargs)
            if ! echo "$VERSION" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+"; then
                echo "[FAIL] Invalid version format: '$VERSION' (expected semver: X.Y.Z)"
                FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
            else
                echo "[OK] Version format valid"
            fi
        fi
        
        if ! echo "$FRONTMATTER" | grep -qE "^\s*author:"; then
            echo "[FAIL] Missing required field: 'author:'"
            FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
        else
            echo "[OK] Field 'author:' present"
        fi
    fi
    
    # Check for required sections (case-insensitive headers)
    if ! grep -qiE "^##?\s+(When to Use|Usage|Use Cases)" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Missing 'When to Use' section"
        FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
    else
        echo "[OK] 'When to Use' section present"
    fi
    
    # For instructions, be flexible - look for instructional content sections.
    # Accept "Instructions", "Guidelines", "Standards", "Overview", "Principles",
    # numbered sections (## 1. ...), or any h2 header (## ...) which indicates
    # structured instructional content. The h1 title (# Skill Name) is excluded.
    if ! grep -qiE "^##\s" "$SKILL_DIR/SKILL.md"; then
        echo "[FAIL] Missing instructional content sections (no h2 sections found)"
        FIXABLE_ERRORS=$((FIXABLE_ERRORS + 1))
    else
        echo "[OK] Instructional content sections present"
    fi
fi

# ============================================================================
# QUALITY CHECKS (warnings only, don't block)
# ============================================================================

echo ""
echo "QUALITY CHECKS (Advisory Warnings)"
echo "-----------------------------------"

if [ -f "$SKILL_DIR/SKILL.md" ]; then
    # Check for examples
    if ! grep -qiE "^##?\s+Examples?" "$SKILL_DIR/SKILL.md"; then
        echo "[WARN] No 'Examples' section found (recommended)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "[OK] 'Examples' section present"
    fi
    
    # Check file size (too short might be incomplete)
    # Use grep -c '' instead of wc -l to correctly count the last line
    # even if the file does not end with a trailing newline
    LINES=$(grep -c '' "$SKILL_DIR/SKILL.md" 2>/dev/null || echo 0)
    if [ "$LINES" -lt 30 ]; then
        echo "[WARN] SKILL.md is very short ($LINES lines) - might be incomplete"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "[OK] SKILL.md has adequate content ($LINES lines)"
    fi
fi

# Check LICENSE.txt content
if [ -f "$SKILL_DIR/LICENSE.txt" ]; then
    if ! grep -q "Copyright\|LICENSE\|Permission" "$SKILL_DIR/LICENSE.txt"; then
        echo "[WARN] LICENSE.txt exists but doesn't look like a valid license"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "[OK] LICENSE.txt appears valid"
    fi
fi

# ============================================================================
# SUMMARY AND EXIT
# ============================================================================

echo ""
echo "================================"
echo "VALIDATION SUMMARY"
echo "================================"
echo "Critical Errors: $CRITICAL_ERRORS (security/missing files)"
echo "Fixable Errors:  $FIXABLE_ERRORS (format/structure)"
echo "Warnings:        $WARNINGS (advisory only)"
echo ""

if [ $CRITICAL_ERRORS -gt 0 ]; then
    echo "RESULT: REJECTED ❌"
    echo "Status: Auto-rejected due to critical failures"
    echo "Action: Fix critical issues before resubmitting"
    exit 2
elif [ $FIXABLE_ERRORS -gt 0 ]; then
    echo "RESULT: NEEDS CHANGES ⚠️"
    echo "Status: Validation failed with fixable issues"
    echo "Action: Fix structural/format errors and resubmit"
    exit 1
else
    echo "RESULT: PASSED ✅"
    if [ $WARNINGS -gt 0 ]; then
        echo "Status: Ready for review (with $WARNINGS advisory warnings)"
    else
        echo "Status: Ready for review"
    fi
    echo "Action: Approved for human/AI review"
    exit 0
fi
