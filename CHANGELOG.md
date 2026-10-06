# Changelog

All notable changes to the LevelHistory addon are documented here.

## [1.4.2] - 2026-10-05

### Added
- Time played is requested 10 seconds after login if no other addon has requested it by then, since the default UI never requests it on its own.

### Fixed
- The end-of-session level snapshot is now recorded on `PLAYER_LOGOUT` from the last partial level seen while playing. It was recorded on `PLAYER_LEAVING_WORLD`, which also fires on every loading screen, and queried the level API during logout, which returns bad values (e.g. level 1).
- Time played is now recorded at logout by adding the seconds since the last time played reply to that reply's total, since played time keeps counting through loading screens and reloads. This replaces the time played request on logout, whose reply could never arrive before the game unloads the UI.

## [1.4.1] - 2026-08-12

### Added
- Release workflow now validates that the tag, `LevelHistory.toc`, and `CHANGELOG.md` versions all match, and that each release's version is greater than the previous one.

### Fixed
- Removed Debug log for TimePlayed Snapshots
- GitHub Actions release workflow now triggers on push after renaming the default branch from `master` to `main`.
- Misc Typos in LevelHistory.toc fixed.

## [1.4] - 2026-06-30

### Changed
- Record character's realm on login
- Record partial level progress. This is triggered on player xp updates, but only if it has been 2 minutes since the last xp updates. The player leveling up ignores this timer.

## [1.3] - 2026-06-29

### Changed
- Character information (name, class, specialization, race, faction) is now refreshed on every login, not just when a new character is first detected. This ensures the addon reflects changes from race changes, faction transfers, and spec swaps without needing to wipe saved data.

## [Unreleased]

