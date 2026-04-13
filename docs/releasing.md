# Releasing VaultWash

VaultWash ships desktop build artifacts for Linux, Windows, and macOS. Linux is the primary supported target, but the repository includes practical artifact builds for all three desktop platforms.

## Platform Prerequisites

- Linux:
  - Flutter stable with Linux desktop enabled
  - Native build dependencies installed on the host:

    ```bash
    sudo apt-get update
    sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
    ```
- Windows:
  - Flutter stable with Windows desktop enabled
  - Visual Studio C++ desktop workload
- macOS:
  - Flutter stable with macOS desktop enabled
  - Xcode and command line tools

Each desktop platform should generally be built on its own matching host or CI runner.
The GitHub Actions Linux jobs install the same Ubuntu packages before running `flutter build linux --release`.

## Local Build Commands

### Linux

```bash
flutter build linux --release
```

Primary output:

```text
build/linux/x64/release/bundle/
```

### Windows

```bash
flutter build windows
```

Primary output:

```text
build/windows/x64/runner/Release/
```

### macOS

```bash
flutter build macos
```

Primary output:

```text
build/macos/Build/Products/Release/VaultWash.app
```

## CI Release Workflow

The repository includes `.github/workflows/desktop-release.yml`, which:

- runs `dart analyze` and `flutter test` on Ubuntu
- builds Linux artifacts on `ubuntu-latest`
- builds Windows artifacts on `windows-latest`
- builds macOS artifacts on `macos-latest`
- archives the platform outputs
- uploads workflow artifacts for download
- attaches artifacts to GitHub Releases when version tags such as `v1.0.0` are pushed

## Artifact Formats

- Linux:
  - `vaultwash-linux-x64.tar.gz`
- Windows:
  - `vaultwash-windows-x64.zip`
- macOS:
  - `vaultwash-macos.zip`

These are practical MVP bundle archives. Installer-grade packaging can be layered on later.

## Future Packaging Notes

Planned packaging improvements include:

- `.deb`
- AppImage
- Snap
- Windows installer / MSIX
- signed macOS `.dmg`
- notarized macOS distribution
