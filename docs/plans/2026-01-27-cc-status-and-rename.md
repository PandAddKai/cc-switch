# `cc-status` and interactive rename in `cc-edit` Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `cc-status` (with `--full`) to report the current profile and effective `ANTHROPIC_*` settings, and allow renaming a profile during `cc-switch edit <profile> --prompt`.

**Architecture:** Implement both features in `cc-switch` (single source of truth), then add a small wrapper script `cc-status` and wire it into install/uninstall/release/docs.

**Tech Stack:** Bash scripts.

### Task 1: Add `status` subcommand in `cc-switch`

**Files:**
- Modify: `cc-switch`

**Step 1: Implement `cmd_status`**
- Behavior:
  - Requires a current profile (same as `cmd_env`/`cmd_run`).
  - Prints:
    - `CC_SWITCH_HOME=...`
    - `profile=...`
    - `ANTHROPIC_BASE_URL=...`
    - `ANTHROPIC_API_KEY=...` (redacted unless `--full`)
- Flags:
  - Accept `--full` to print the full key.

**Step 2: Wire into `usage()` and `main()`**
- Add `cc-switch status [--full]` to help text.
- Add a `status)` case in the dispatcher.

**Step 3: Manual verification**
- Run: `./cc-switch status`
- Expected: Fails with “no current profile selected” if none is set.

### Task 2: Add `cc-status` wrapper script

**Files:**
- Create: `cc-status`
- Modify: `install.sh`
- Modify: `uninstall.sh`
- Modify: `release.sh`
- Modify: `README.md`

**Step 1: Create wrapper**
- Follow pattern of `cc-current`/`cc-list`:
  - `cc-status` → `cc-switch status "$@"`

**Step 2: Install/uninstall/release wiring**
- Ensure `install.sh` installs and links `cc-status`.
- Ensure `uninstall.sh` removes `$PREFIX/cc-status`.
- Ensure `release.sh` includes `cc-status` in the tarball.

**Step 3: README update**
- Mention `cc-status` and its `--full` flag (warning about secret output).

### Task 3: Add interactive rename to `cc-switch edit --prompt`

**Files:**
- Modify: `cc-switch`

**Step 1: Prompt for new name**
- Add: `new_name="$(read_line "name" "$old_name")"`
- Validate `new_name`.
- If `new_name` differs from `old_name`, ensure the target profile does not exist.

**Step 2: Persist edits under the new name**
- Write edited `base_url`/`api_key` to a temp dir.
- Replace/create the new profile directory atomically.

**Step 3: Clean up old name**
- If renamed:
  - If old was current, update current file to `new_name`.
  - Delete the old profile directory (same delete semantics as `cmd_del`, without prompting).

### Task 4: Verification

**Step 1: Syntax check**
- Run: `bash -n cc-switch install.sh uninstall.sh release.sh cc-status`
- Expected: exit 0

**Step 2: Help output**
- Run: `./cc-switch --help | grep -E 'status|cc-switch \\[claude args'`
- Expected: shows `status` and runner shorthand.

