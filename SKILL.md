---
name: cc-switch-patterns
description: Coding patterns and conventions from cc-switch repository
version: 1.0.0
source: local-git-analysis
analyzed_commits: 2
repository: cc-switch
---

# cc-switch Development Patterns

This skill captures the coding patterns, conventions, and workflows extracted from the cc-switch repository - a bash-based CLI tool for managing Claude Code relay profiles.

## Commit Conventions

**Version-prefixed commits**: All commits use semantic versioning in the message format:

```
v{MAJOR}.{MINOR}.{PATCH}: {description}
{tool-name} v{MAJOR}.{MINOR}.{PATCH}
```

Examples:
- `v0.1.1: improve interactive input`
- `cc-switch v0.1.0`

## Code Architecture

### File Organization

```
cc-switch/                   # Root repo
├── cc-switch               # Main executable (600+ lines)
├── cc-{cmd}                # Wrapper scripts for each subcommand
│   ├── cc-add              # Wrapper for 'cc-switch add'
│   ├── cc-edit             # Wrapper for 'cc-switch edit'
│   ├── cc-del              # Wrapper for 'cc-switch del'
│   ├── cc-use              # Wrapper for 'cc-switch use'
│   ├── cc-list             # Wrapper for 'cc-switch list'
│   ├── cc-current          # Wrapper for 'cc-switch current'
│   ├── cc-status           # Wrapper for 'cc-switch status'
│   ├── cc-env              # Wrapper for 'cc-switch env'
│   └── cc                  # Optional alias wrapper
├── cc-lib.sh               # Shared utility functions
├── install.sh              # Installation script
├── uninstall.sh            # Uninstallation script
├── release.sh              # Release automation
├── README.md               # Documentation
├── CHANGELOG.md            # Version history
├── SECURITY.md             # Security policy
├── LICENSE                 # MIT license
└── VERSION                 # Current version number
```

### Bash Script Patterns

**1. Strict Error Handling**
```bash
#!/usr/bin/env bash
set -euo pipefail
```
- Always use `set -euo pipefail` at the top of every script
- `-e`: Exit on error
- `-u`: Exit on undefined variable
- `-o pipefail`: Fail on any command in pipe

**2. Consistent die() Function**
```bash
die() {
  echo "error: $*" >&2
  exit 1
}
```
- Always define a `die()` helper for error messages
- Output to stderr (`>&2`)
- Exit with non-zero code

**3. Atomic File Operations**
```bash
atomic_write_file() {
  local path="$1"
  local content="$2"
  local mode="${3:-600}"

  local dir tmp
  dir="$(dirname "$path")"
  mkdir -p "$dir"
  tmp="$(mktemp "$dir/.tmp.${PROG}.XXXXXX")"
  umask 077
  printf "%s" "$content" >"$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$path"
}
```
- Write to temp file first
- Set permissions with umask 077 (secure by default)
- Atomic rename with `mv -f`

**4. Security: Sensitive Data Handling**
```bash
read_secret() {
  local prompt="$1"
  local input=""
  printf "%s: " "$prompt" >&2
  bracketed_paste_off
  IFS= read -r -s input  # -s for silent (no echo)
  bracketed_paste_on
  printf "\n" >&2
  input="$(strip_bracketed_paste_markers "$input")"
  echo "$input"
}
```
- Always use `read -s` for passwords/API keys
- Never echo secrets to stdout without explicit flags (e.g., `--full`)
- Redact keys in display with `redact_key()`

**5. Terminal Input Handling**
```bash
strip_bracketed_paste_markers() {
  # When bracketed paste is enabled, some terminals wrap pasted text with:
  #   ESC [ 200 ~   ...   ESC [ 201 ~
  # Plain `read` will capture these bytes. Strip them if present.
  local value="$1"
  local esc=$'\e'
  value="${value#"${esc}[200~"}"
  value="${value%"${esc}[201~"}"
  echo "$value"
}
```
- Always strip bracketed paste markers from user input
- Use `bracketed_paste_off()` before reading input
- Use `bracketed_paste_on()` after reading input

**6. Function Naming Conventions**
- `cmd_*`: Command handlers (e.g., `cmd_add`, `cmd_edit`, `cmd_use`)
- `*_dir()`: Path construction functions (e.g., `profiles_dir`, `trash_dir`)
- `*_file()`: File path construction (e.g., `current_file`)
- `validate_*`: Input validation (e.g., `validate_profile_name`, `validate_base_url`)
- `read_*`: Data reading functions (e.g., `read_current_profile`, `read_secret`)
- `atomic_*`: Atomic operations (e.g., `atomic_write_file`, `atomic_replace_dir`)

## Workflows

### Adding a New Command

1. **Add subcommand to main switch statement** in `cc-switch`:
   ```bash
   case "$cmd" in
     # ... existing commands ...
     new-command)
       shift
       cmd_new_command "$@"
       ;;
   ```

2. **Implement `cmd_new_command()` function** in `cc-switch`

3. **Create wrapper script** `cc-new-command`:
   ```bash
   #!/usr/bin/env bash
   # Load shared library
   . "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/cc-lib.sh"
   exec cc-switch new-command "$@"
   ```

4. **Update `install.sh`**:
   ```bash
   install_file cc-new-command
   link_bin cc-new-command
   ```

5. **Update usage documentation** in `cmd_help()` or README

### Release Process

1. **Update VERSION file**:
   ```bash
   echo "0.1.2" > VERSION
   ```

2. **Update CHANGELOG.md**:
   ```markdown
   ## 0.1.2

   - Feature or fix description
   ```

3. **Commit changes**:
   ```bash
   git commit -am "v0.1.2: description"
   ```

4. **Run release script**:
   ```bash
   ./release.sh
   ```

5. **Verify dist/**:
   ```bash
   ls -la dist/
   ```

### Installation & Distribution

**User-facing installation**:
```bash
./install.sh                      # Default: no cc alias
INSTALL_CC_ALIAS=1 ./install.sh   # With cc alias
```

**Installation locations**:
- `INSTALL_ROOT` (default: `~/.local/share/cc-switch`) - actual files
- `PREFIX` (default: `~/.local/bin`) - symlinks pointing to INSTALL_ROOT

**Why this pattern?**
- Users can delete the git repo after install
- Symlinks remain valid even if repo moves
- Easy uninstall via `uninstall.sh`

## Testing Patterns

**Manual testing checklist**:
- Test all subcommands: `init`, `add`, `edit`, `del`, `use`, `list`, `current`, `status`, `env`, `run`
- Test interactive input (readline, paste, default values)
- Test atomic operations (verify temp files cleaned up)
- Test error cases (missing profile, invalid names, etc.)
- Test security (file permissions = 600, no key leaks)

**No automated tests**: This is a simple bash tool relying on manual verification.

## Security Patterns

**1. Secure File Permissions**
```bash
umask 077                    # Before creating sensitive files
chmod 600 "$file"            # For API keys and secrets
chmod 755 "$file"            # For executables
```

**2. Secret Redaction**
```bash
redact_key() {
  local key="$1"
  if [[ ${#key} -le 8 ]]; then
    echo "***"
  else
    echo "${key:0:6}..."
  fi
}
```
- Always redact secrets in output unless `--full` flag is used
- Show prefix only (first 6 chars)

**3. Auth Conflict Prevention**
```bash
# Unset token-based auth to avoid conflicts
exec env -u ANTHROPIC_AUTH_TOKEN \
  ANTHROPIC_BASE_URL="$base_url" \
  ANTHROPIC_API_KEY="$api_key" \
  "$claude" "$@"
```

## Coding Standards

### Variable Naming
- `SCREAMING_SNAKE_CASE`: Environment variables, constants
- `snake_case`: Local variables, function parameters
- `cmd`: Reserved for main command name

### Error Messages
```bash
die "profile not found: $name"           # ✓ Clear, actionable
die "current profile not found on disk: $cur"  # ✓ Detailed context
```
- Always include context (what was being looked for)
- User-facing, not developer-facing

### Validation Pattern
```bash
validate_profile_name() {
  local name="$1"
  [[ -n "$name" ]] || die "profile name required"
  [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || die "invalid profile name (allowed: A-Za-z0-9._-): $name"
}

# Usage:
validate_profile_name "$name"
profile_exists "$name" || die "profile not found: $name"
```
- Validate inputs before use
- Use regex for format checking
- Provide clear error messages with allowed formats

### Command Dispatch Pattern
```bash
main() {
  local cmd="${1:-}"
  case "$cmd" in
    ""|-h|--help|help)
      usage
      ;;
    command-name|alias-name)
      shift
      cmd_command_name "$@"
      ;;
    *)
      # Default fallback
      cmd_run -- "$@"
      ;;
  esac
}

main "$@"
```

## Documentation Patterns

**Always include**:
- `README.md`: Usage, quickstart, installation
- `CHANGELOG.md`: Version history with bullets
- `SECURITY.md`: Security policy and contact
- `LICENSE`: MIT license
- `VERSION`: Single-line version number

**README structure**:
1. One-line description
2. Design goals
3. Quickstart
4. Installation
5. Commands reference
6. Optional features
7. Migration notes

## Design Principles

### SSOT (Single Source of Truth)
- Profile data lives ONLY in `~/.cc-switch/profiles/<profile>/`
- No duplicate config files
- Current profile pointer stored in `~/.cc-switch/current`

### Atomic Operations
- All writes use temp + rename pattern
- Never partial writes that could corrupt state
- Automatic rollback on failure

### Shell Integration
- Optional, not required
- Enable via `eval "$(cc-switch shell-init)"`
- Makes environment changes affect current shell

### Safe Defaults
- No `cc` alias by default (avoids shadowing system `cc`)
- Secrets never printed unless `--full` flag used
- Confirmation prompts for destructive operations (unless `-y`)

## Anti-Patterns to Avoid

- **Don't** use `echo` for writing secrets (use `printf`)
- **Don't** use global variables without declaring them with `local`
- **Don't** skip validation of user input
- **Don't** write directly to target files (always use atomic operations)
- **Don't** expose secrets in error messages or default output
- **Don't** create files with insecure permissions (always use umask 077)

## Keywords for Future Reference

- Bash CLI development
- Profile management
- Atomic file operations
- Secret handling in bash
- Terminal input (readline, bracketed paste)
- Shell integration patterns
- User-friendly error messages
- Installation via symlinks (relocatable)

---

*Generated by local git analysis of cc-switch repository*
