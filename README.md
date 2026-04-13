# VaultWash

> Linux-first Flutter desktop app for scanning and cleaning broken citation artifacts in Obsidian vaults.

VaultWash is a Linux-first Flutter desktop app for cleaning broken citation artifacts inside Obsidian vaults.

It scans markdown files recursively, detects junk patterns such as:

```text
:contentReference[oaicite:10]{index=10}
```

and lets you preview changes before cleaning anything.

VaultWash is built for a safe, review-first workflow:
- select an Obsidian vault
- scan markdown files
- inspect affected files
- preview before/after changes
- clean selected files or clean all
- optionally create `.bak` backups before writing

The goal is simple: keep your vault clean without risking the rest of your notes.

## Features

- Linux-first desktop workflow with Windows and macOS build targets scaffolded for distribution
- Recursive markdown scanning with default exclusions for `.obsidian/` and `.trash/`
- Fast preview of affected files before any write occurs
- Safe cleanup flow with optional `.bak` backups and hash checks before overwrite
- Extensible cleanup rule engine designed for more artifact rules over time
- Calm, compact desktop UI tuned for large vault review sessions

## Why VaultWash?

- Obsidian vaults are real working knowledge bases, so cleanup should be reviewable and reversible.
- Broken citation artifacts often appear in batches, which makes manual cleanup tedious and error-prone.
- VaultWash keeps the workflow simple: scan, review, clean, and rescan to confirm the result.

## Current MVP Scope

- Select a vault folder and remember the last used location locally
- Scan `.md` files recursively with basic exclusion settings
- Detect broken `oaicite`-style `contentReference` artifacts
- Preview excerpt-level before/after cleanup for affected files
- Clean selected files or all affected files with optional backups
- Surface unreadable files and failed writes without crashing the app

## Running the App

```bash
flutter pub get
flutter run -d linux
```

## Build Commands

```bash
flutter build linux
flutter build windows
flutter build macos
```

Build outputs are generated under `build/linux/`, `build/windows/`, and `build/macos/` respectively.

## Release / Download Notes

- Linux is the primary supported target today.
- GitHub Releases are set up to publish desktop artifacts for Linux, Windows, and macOS.
- Release artifacts are currently bundle archives rather than installer-grade packages:
  - Linux: `.tar.gz`
  - Windows: `.zip`
  - macOS: `.zip`
- Each desktop target generally needs to be built on its own host or CI runner.

Detailed release steps and artifact paths are documented in [docs/releasing.md](docs/releasing.md).

## Roadmap / Next Steps

- Watch mode and vault-change notifications
- Additional cleanup rules beyond `oaicite` artifacts
- Richer batch diff and full-file preview modes
- Undo/history support with cleanup session restore
- Packaging upgrades such as `.deb`, AppImage, Snap, Windows installer/MSIX, and signed macOS distribution

## Repository Notes

- Recommended GitHub repository description: `Linux-first Flutter desktop app for scanning and cleaning broken citation artifacts in Obsidian vaults.`
- A project license has not been selected yet. Add a `LICENSE` file before publishing public binaries.
- Change history starts in [CHANGELOG.md](CHANGELOG.md).
