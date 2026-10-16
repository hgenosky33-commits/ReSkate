# ReSkate development workspace

This checkout starts from upstream `v2.0.7` (`0f8af627105c1079ef25f36ad83b159ae9d1df1f`), matching the installed runtime at setup. Keep that compatibility baseline until a task calls for an upgrade.

- Read `DEVELOPMENT.md` before working. Use feature branches and review `git status` before edits.
- Run `pwsh -File ./dev.ps1 Check` for the configured park/editor, profile, board-break, and road-rash regression checks. Run `Build` for a complete launcher/runtime/server build when the change requires it.
- The default tests use temporary fixtures in `build/codex`; they do not start the game or use the live profile.
- Preserve existing source edits. Keep game binaries, caches, credentials, saves, extracted game data, and local assets out of commits.
- Make game deployment an explicit task step with a backup and a closed game. Do not change installed mods or replace runtime files as a side effect of development setup or automated checks.
- `origin` is `hgenosky33-commits/ReSkate`; `upstream` is `Dingo-Shenanigans/ReSkate`. Use `reskate-2.0.7` as the base for this installed-version workflow. Publish task branches and draft pull requests to the user's fork, keeping upstream contribution a separate explicit task.
- The GitHub connector and local CLI are authorized for this fork. When using the portable CLI, set `GH_CONFIG_DIR` to this checkout's `.local/github-auth` directory. Network permission is still required for shell commands that contact GitHub; a blocked network check does not prove the saved sign-in is invalid.
- Report automated test results separately from in-game observations. Passing fixture tests does not establish mesh visibility, collision, animations, particles, or runtime compatibility.
