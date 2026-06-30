# Changelog

All notable changes to the LevelHistory addon are documented here.

## [1.4] - 2026-06-30
- Record character's realm on login
- Record partial level progress. This is triggered on player xp updates, but only if it has been 2 minutes since the last xp updates. The player leveling up ignores this timer.

## [1.3] - 2026-06-29

### Changed
- Character information (name, class, specialization, race, faction) is now refreshed on every login, not just when a new character is first detected. This ensures the addon reflects changes from race changes, faction transfers, and spec swaps without needing to wipe saved data.

## [Unreleased]
