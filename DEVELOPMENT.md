# ReSkate development

This is an independent Git checkout for editing and testing ReSkate and its modding code. The baseline is [ReSkate v2.0.7](https://github.com/Dingo-Shenanigans/ReSkate/tree/v2.0.7), matching the installed ReSkate.dll inspected on October 16, 2026. The initial branch is `codex/workflow-setup`.

## Verified setup results

On October 16, 2026, the configured test programs compiled successfully with Visual Studio 2022 Build Tools and CMake 3.31.6. CTest reported **10 passed, 0 failed**, with a test execution time of 1.75 seconds. The build and test log is saved locally at `artifacts/setup-build.log`.

MSBuild emitted nonfatal `MSB8064` warnings about upstream asset-directory dependencies. The directories are present; the checks still compiled and passed. Parallel builds failed in this session, so the helper defaults to one worker.

The full launcher/runtime/server build and in-game behavior were not tested during setup. No live game files or installed mods were changed. GitHub CLI 2.102.0 was downloaded from its official release and its SHA-256 matched GitHub's published digest. GitHub account access and administrator permission to the user's fork were verified after sign-in.

## Commands

Run these from this folder in PowerShell 7:

```powershell
.\dev.ps1 Doctor     # Locate Git, Visual Studio CMake, and CTest
.\dev.ps1 Check      # Configure, compile 10 regression-test programs, and run them
.\dev.ps1 Build      # Build the full launcher, runtime, server, and configured tests
.\dev.ps1 Test       # Rerun already-built tests
.\dev.ps1 Status     # Show local branch, edits, remotes, and commit
```

The helper finds the installed Visual Studio 2022 C++ tools automatically. It defaults to one build worker because parallel MSBuild workers could not run reliably in this session. Outside this session, `-Jobs 4` is available. Build products stay in `build/codex/Release`. Local binaries are marked `2.0.7-dev`, with the upstream auto-update option off. No command here installs the resulting binaries into the game.

The 10 default checks cover park randomization, park editing, editor UI, editor transactions, profile migration, profile changes, music favorites, object categories, board break, and road rash. They use test fixtures, not live game data. Other upstream test suites can be enabled for changes that need them. Mesh visibility, collision, animations, particles, and gameplay still require an in-game test.

## GitHub

The connected account is **hgenosky33-commits**. Its public project copy is [hgenosky33-commits/ReSkate](https://github.com/hgenosky33-commits/ReSkate). Both the GitHub connector and the local CLI can access it.

| Name | Purpose |
| --- | --- |
| `origin` | Your copy: `https://github.com/hgenosky33-commits/ReSkate.git` |
| `upstream` | Original project: `https://github.com/Dingo-Shenanigans/ReSkate.git` |
| `reskate-2.0.7` | Base branch matching the installed game runtime |
| `codex/workflow-setup` | Initial workflow changes proposed for review |

Your fork's `main` branch retains the upstream default. Work for the installed 2.0.7 runtime targets `reskate-2.0.7` explicitly. Do not merge newer upstream code into that branch without a compatibility task.

The GitHub app connection and local CLI sign-in were verified. These commands remain available:

```powershell
.\github.ps1 Status
.\github.ps1 Login          # Only needed if a future sign-in expires
.\github.ps1 Repositories   # List repositories owned by the authenticated account
```

The local CLI/config directory is `.local/`, excluded from Git. GitHub CLI normally uses the Windows credential store; check `auth status` after login to confirm where credentials are stored. Do not copy credentials into source files or chat.

For a task, branch from the current `reskate-2.0.7` base, edit and test locally, then publish the task branch and open a draft pull request **inside your fork**. The GitHub connector can publish changes and create pull requests directly; the CLI is available for GitHub operations as well. Keep `upstream` as the original project. Review changes and tests before merging.

`.github/workflows/reskate-checks.yml` defines the same 10 regression checks on a Windows GitHub runner for pull requests targeting `reskate-2.0.7`. It uses read-only repository permissions and a pinned checkout action. Local checks remain available independently of GitHub Actions.

In a restricted agent session, allow network access before checking CLI authentication. A failed network request can be reported by the CLI as an invalid token even when the saved sign-in works.

## Existing mod work

Your existing game and mod work remains separate. Local paths and the earlier modding workspaces are recorded in the ignored `.local/context.json`. The current yellow-cube work is an existing task; this setup does not modify its packages.

Useful source areas:

| Area | Source |
| --- | --- |
| Custom Lua scripts | `Engine/Scripting/` |
| Mod loading and asset merging | `Engine/Vfs/` |
| Frostbite EBX, CAS, and bundles | `Engine/Resource/` |
| Park editor and placed objects | `Extension/Objects/` |
| Board break behavior | `Extension/BoardBreak/` |
| Road rash behavior | `Extension/RoadRash/` |
| Launcher | `Launcher/` |

For a normal task: inspect the relevant source and prior mod evidence, create a feature branch, edit, run the appropriate checks, review the diff, and package a test build. Deploy and test in game as a separate step, recording the result before publishing changes.
