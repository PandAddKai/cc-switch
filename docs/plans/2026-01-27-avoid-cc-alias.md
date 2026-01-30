# Avoid Installing `cc` Alias Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Stop installing `~/.local/bin/cc` by default (to avoid shadowing system `cc`), while keeping an easy way to run Claude with the selected profile via `cc-switch`.

**Architecture:** Make `cc-switch` fall back to `run` when the first argument is not a management subcommand. Update `install.sh` so installing the `cc` alias is opt-in via an environment variable, and update `README.md` accordingly.

**Tech Stack:** Bash scripts only.

### Task 1: Plan baseline + repo checks

**Files:**
- Modify: `cc-switch`
- Modify: `install.sh`
- Modify: `README.md`

**Step 1: Confirm existing behavior**
- `./install.sh` installs symlinks into `~/.local/bin`, including `cc`.
- `cc` runs `cc-switch run -- ...`.

**Step 2: Decide compatibility approach**
- Default: do not install `cc`.
- Optional: allow installing `cc` via `INSTALL_CC_ALIAS=1`.

### Task 2: Make `cc-switch` act as runner fallback

**Files:**
- Modify: `cc-switch`

**Step 1: Update command dispatch**
- If `$1` is a known subcommand, behave as before.
- Otherwise (non-empty and not help), treat as `run` and forward all args to Claude.

**Step 2: Update `--help` text**
- Add a usage line indicating direct `cc-switch [claude args...]` is supported.

**Step 3: Quick manual check**
- `./cc-switch --help` still prints usage.
- `./cc-switch run -- --help` still forwards args to `claude` (if present).

### Task 3: Make installing `cc` alias optional

**Files:**
- Modify: `install.sh`
- Modify: `README.md`

**Step 1: Gate `cc` install/link**
- Default `INSTALL_CC_ALIAS=0`.
- Only `install_file cc` and `link_bin cc` when `INSTALL_CC_ALIAS=1`.

**Step 2: Update README**
- Quickstart uses `cc-switch` (not `cc`).
- Document `INSTALL_CC_ALIAS=1 ./install.sh` for users who still want `cc`.

### Task 4: Verification

**Step 1: Shellcheck basic execution**
- Run `bash -n cc-switch install.sh uninstall.sh cc` and confirm no syntax errors.

**Step 2: Smoke-run help**
- Run `./cc-switch --help` and confirm it prints usage.

