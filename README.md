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
cc "hello"
```

## Install

```bash
./install.sh
```

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

cc-add <profile>    # interactive create
cc-edit <profile>   # interactive edit (in-terminal)
cc-del  <profile>   # delete (asks to confirm; add -y to skip)
cc-use  <profile>   # switch current profile

cc <claude args...> # run Claude with current profile (recommended)
cc-env              # print exports (leaks key to stdout)
```

## Release

```bash
./release.sh
ls -la dist/
```
