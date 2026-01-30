# Remove legacy `cc` alias (migration) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Provide a safe migration for existing installs that previously created `~/.local/bin/cc`, keeping profile data intact and removing only the legacy `cc` alias that points to this tool.

**Architecture:** Profile data already lives under `CC_SWITCH_HOME` (default `~/.cc-switch`) and does not need conversion. Migration focuses on cleaning up the legacy `cc` executable in the default user prefix. Implement `cc-switch migrate` to remove `~/.local/bin/cc` only if it is a symlink pointing to this tool’s installed `cc` wrapper. Also have `install.sh` automatically remove that legacy symlink when `INSTALL_CC_ALIAS=0`.

**Tech Stack:** Bash scripts.

### Task 1: Add `cc-switch migrate`

**Files:**
- Modify: `cc-switch`

**Step 1: Implement `cmd_migrate`**
- Ensure init directories exist.
- Check `$HOME/.local/bin/cc`:
  - If it’s a symlink and its target equals `$(script_dir)/cc`, remove it and print an OK message.
  - Otherwise do nothing and print a note.
- Do not touch profile data on disk.

**Step 2: Wire `migrate` into usage + main**

**Step 3: Run syntax check**
- `bash -n cc-switch`

### Task 2: Update `install.sh` to remove legacy alias by default

**Files:**
- Modify: `install.sh`

**Step 1: After linking bins**
- If `INSTALL_CC_ALIAS != 1`, remove `$PREFIX/cc` only when it is a symlink whose target is exactly `$INSTALL_ROOT/cc`.

**Step 2: Update installer output**
- Mention if legacy alias was removed or how to opt back in.

### Task 3: Verification

**Step 1: Smoke test migrate in temp**
- Simulate install layout in a temp directory and ensure the migrate logic only deletes the intended symlink.

