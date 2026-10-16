# Changelog

All notable changes to the LevelHistory addon are documented here.

## [Unreleased]

### Changed
- Release zips are now named `LevelHistory-<version>.zip` instead of `LevelHistory.zip`. The `LevelHistory` folder inside is unchanged.

## [1.5.0] - 2026-10-13

### Added
- Support for World of Warcraft: Forever (Interface 16001). Forever runs the Retail API, so the same addon works on both clients.

### Changed
- Updated for Retail patch 12.1.5 (Interface 120105).
- The character's specialization is now read with `C_SpecializationInfo.GetSpecialization()` instead of the deprecated `GetSpecialization()` alias. Forever doesn't define that alias, so the login handler stopped before recording the character's details, the login level and gear snapshots, and the time played request. Blizzard will also remove the alias from Retail at the next expansion.

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
