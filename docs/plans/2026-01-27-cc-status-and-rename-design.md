# `cc-status` + `cc-edit` rename Design

**Goal:** Add a `cc-status` convenience command to show the current selected profile and its effective `ANTHROPIC_*` values, and enhance `cc-edit --prompt` to optionally rename the profile interactively.

## `cc-status`

- Output fields (minimal):
  - `CC_SWITCH_HOME`
  - `profile`
  - `ANTHROPIC_BASE_URL`
  - `ANTHROPIC_API_KEY` (redacted by default)
- Flags:
  - `--full`: show the API key in full (unsafe; prints secret to stdout)

Implementation approach:
- Add `status` subcommand to `cc-switch` (like `current`/`env`).
- Add a `cc-status` wrapper script similar to `cc-current`, forwarding to `cc-switch status`.

## Rename in `cc-edit --prompt`

- Add an interactive prompt at the start: `name [<current>]`
- If name changes:
  - Validate new profile name (same rules as creation)
  - Refuse to overwrite an existing profile directory
  - Write edited credentials to the new profile directory
  - Delete the old profile directory
  - If the old profile was current, update `~/.cc-switch/current` to the new name

Non-goals:
- No non-interactive rename flag in this iteration.
- No cross-profile merge/overwrite semantics.

