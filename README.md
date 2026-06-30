# Level History

A World of Warcraft addon that tracks character progression over time — levels reached, average item level, and time played — and stores it locally for consumption by the WLH sync tool.

## What it tracks

- **Level history** — records a snapshot on every level-up, on experience gains (minimum 2 minutes betweeen snapshots), and backfills historical level milestones from Achievement data on first login
- **Gear history** — records a snapshot whenever average item level increases, and on every login
- **Time played** — records a snapshot on every logout via `TIME_PLAYED_MSG`

All data is stored in the `Characters` SavedVariables file, keyed by character GUID.

## Installation

1. Download `LevelHistory.zip` from the [latest release](../../releases/latest)
2. Extract the `LevelHistory` folder into your `World of Warcraft\_retail_\Interface\AddOns\` directory
3. Restart the game or reload your UI (`/reload`)

## WLH Ecosystem

This addon is one part of the broader WLH (WoW Level History) project:

| Component | Purpose |
|---|---|
| **LevelHistory** (this addon) | Writes progression data to SavedVariables |
| **wlh-sync** | Watches the SavedVariables file, parses it, and uploads to the API |
| **wlh-api** | Web API that stores and serves character progression data |
| **wlh-web** | Frontend dashboard with progression charts |

## Requirements

- World of Warcraft Retail (Interface 120007+)
