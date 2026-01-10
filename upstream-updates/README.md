Purpose

- Store individual upstream merge bundles (changelog + scripts) for manual application.
- You should only apply the update(s) if you already have a running system after the before the listed date.

Folder layout

- `upstream-updates/` contains one or more subfolders named `YYYYMMDD.n` where:
  - `YYYYMMDD` is the date of the last commit merged from upstream.
  - `.n` is a counter starting at `1` if there are multiple merges the same day.

Each `YYYYMMDD.n` subfolder must contain exactly:

1. `changes.md` — the changelog for that merge (see format below).
2. `apply-changes.sh` — script that applies the files to `$HOME` (must support `--dry-run` and `--restart`).
3. `restore-backup.sh` — rollback script that restores backups created by `apply-changes.sh`.

`changes.md` formatting rules

- Use a short top-level title describing the merge.
- Include the commit range (start and end commit-ish).
- List commits in chronological order (oldest → newest). For each commit include:

  - `- **<commit-hash>** (YYYY-MM-DD): <short summary>`

  - Under that, list changed files with repo-relative paths under a `Files changed:` bullet, e.g.:
    - `- [dots/.config/quickshell/ii/modules/ii/lock/Lock.qml](dots/.config/quickshell/ii/modules/ii/lock/Lock.qml)`

- Files referenced in `changes.md` should be repository-relative paths. For dotfile changes prefer paths under `dots/` only.
- Do NOT include repository maintenance scripts (e.g., `sdata/...`) in the list of files to install to `$HOME` unless you intentionally want them copied to a user location — the `apply-changes.sh` logic assumes `dots/` entries map to `$HOME/` by stripping `dots/`.

`apply-changes.sh` requirements

- Must resolve `REPO_ROOT` relative to the script location (so it still works when executed from inside the `YYYYMMDD.n` folder).
- Must only operate on the files listed in its internal `paths` list (or read `changes.md` if implemented) and treat paths as repo-relative.
- Behavior expected:
  - `--dry-run`/`-n`: show intended actions without changing files.
  - Backup any existing destination file/dir by renaming to `<dest>.bak.<TIMESTAMP>` before replacing.
  - For directories use `rsync -a --delete` to mirror contents.
  - For files use `cp -a`.
  - `--restart`/`-r`: optionally restart the running UI (`systemctl --user restart quickshell.service` or `pkill -f quickshell`).
- Fail-safe: skip any `paths` entries that do not exist in the repo; log skipped entries.

`restore-backup.sh` requirements

- When run without arguments, list available backups found under expected base paths (e.g., `$HOME/.config/quickshell`).
- When given a timestamp argument, restore all `<file>.bak.<TIMESTAMP>` files by moving them back to their original path (removing the current one first).

How to add a new upstream bundle

1. Create a new directory: `mkdir -p upstream-updates/20260104.1`
2. Add `changes.md` following the format above.
3. Add `apply-changes.sh` and `restore-backup.sh` (copy the templates from other folders and update the `paths` list).
4. Make the scripts executable:

```bash
chmod +x upstream-updates/20260104.1/apply-changes.sh \
  upstream-updates/20260104.1/restore-backup.sh
```

5. Test with a dry-run:

```bash
bash upstream-updates/20260104.1/apply-changes.sh --dry-run
```

Notes & cautions

- The `apply-changes.sh` implementation provided in this repo strips a leading `dots/` from each path and installs the remainder under `$HOME/`. If you need the script to handle other path prefixes, update the script deliberately — accidental copying of non-dotfile repo paths to `$HOME` can break a running system.
- Keep `changes.md` human-readable; automated parsing is possible but not enforced here.

Contact / maintenance

- When creating multiple bundles on the same date, increment the counter suffix (.1 → .2).
