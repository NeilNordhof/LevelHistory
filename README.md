# Level History

A World of Warcraft addon that tracks character progression over time — levels reached, average item level, and time played — and stores it locally for the WLH desktop app to read.

## What it tracks

- **Level history** — records a snapshot on every level-up, on experience gains (minimum 2 minutes between snapshots), and backfills historical level milestones from Achievement data on first login
- **Gear history** — records a snapshot whenever average item level increases, and on every login
- **Time played** — records a snapshot on every logout via `TIME_PLAYED_MSG`

All data is stored in `LevelHistory.lua`, in the Account-level SavedVariables folder, under the `Characters` table, keyed by character GUID.

## Installation

1. Download `LevelHistory.zip` from the [latest release](../../releases/latest)
2. Extract the `LevelHistory` folder into your `World of Warcraft\_retail_\Interface\AddOns\` directory
3. Restart the game or reload your UI (`/reload`)

## WLH Ecosystem

This addon is one part of the broader WLH (WoW Level History) project:

| Component | Purpose |
|---|---|
| **LevelHistory** (this addon) | Writes progression data to SavedVariables |
| **wlh-app** | Tray-resident Windows desktop app — syncs progression data from SavedVariables into a local database and displays it in charts and tables |

## Requirements

- World of Warcraft Retail (Interface 120100+)
