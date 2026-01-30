# cc-switch

Switch Claude Code relay profiles by managing only:
- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_API_KEY`

Profiles are stored in `~/.cc-switch` (override with `CC_SWITCH_HOME`).

## Design goals

- SSOT: profile data lives only in `~/.cc-switch/profiles/<profile>/`
- Atomic writes: add/edit/use are done via temp + rename

## Quickstart

```bash
./install.sh
cc-switch init
cc-add myrelay
cc-use myrelay
cc-switch "hello"
```

## Install

```bash
./install.sh
```

This installs files into `~/.local/share/cc-switch` and symlinks into `~/.local/bin`,
so you can move the repo directory later without breaking `cc-*` commands.

## Make `cc-use` affect current shell

By default, `cc-use` only switches the stored “current profile”. To make it also
export env vars in your current shell session, enable shell integration:

```bash
eval "$(cc-switch shell-init)"
```

Persist it (bash):

```bash
echo 'eval "$(cc-switch shell-init)"' >> ~/.bashrc
```

## Commands

```bash
cc-list
cc-current
cc-status [--full]  # show current profile; --full prints API key (unsafe)

cc-add <profile>    # interactive create
cc-edit <profile>   # interactive edit (in-terminal; can rename in prompt)
cc-del  <profile>   # delete (asks to confirm; add -y to skip)
cc-use  <profile>   # switch current profile

cc-switch [args...] # run Claude with current profile (recommended)
cc-switch env       # print exports (leaks key to stdout)
```

## Optional: install `cc` alias

If you want the `cc` convenience command (note: it may shadow system `cc` on some machines):

```bash
INSTALL_CC_ALIAS=1 ./install.sh
```

## Migration: remove legacy `cc`

If you previously installed a version that created `~/.local/bin/cc`, reinstalling will remove that symlink by default. You can also run:

```bash
cc-switch migrate
```

## Release

```bash
./release.sh
ls -la dist/
```
