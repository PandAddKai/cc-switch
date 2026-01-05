# Security Notes

This tool stores your Claude API key in plain text on disk:

- Location: `~/.cc-switch/profiles/<profile>/api_key`
- Permissions: files are written with mode `0600` and `umask 077`

Recommendations:

- Prefer `cc` / `cc-switch run` to avoid printing keys to stdout.
- Treat `cc-switch env` / `cc-env` output as sensitive (it prints your key).
- Ensure your home directory permissions are properly restricted.

