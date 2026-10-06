local AddonName = "LevelHistory"

local AchievementMilestoneIds = {
    ["6"] = 10, -- Level 10
    ["7"] = 20, -- Level 20
    ["8"] = 30, -- Level 30
    ["9"] = 40, -- Level 40
    ["14782"] = 50, -- Level 50
    ["14783"] = 60, -- Level 60
    ["15805"] = 70, -- Level 70
    ["19459"] = 80, -- Level 80
    ["10"] = 50, -- Level 50 legacy
    ["11"] = 60, -- Level 60 legacy
    ["12"] = 70, -- Level 70 legacy
    ["13"] = 80, -- Level 80 legacy
    ["4826"] = 85, -- Level 85 legacy
    ["6193"] = 90, -- Level 90 legacy
    ["9060"] = 100, -- Level 100 legacy
    ["10671"] = 110, -- Level 110 legacy
    ["12544"] = 120 -- Level 120 legacy
}

local characterGuid = UnitGUID("player")
local currentILvl
local XP_SNAPSHOT_INTERVAL = 120
local lastXpSnapshotTime = 0
local lastPartialLevel
local TIME_PLAYED_FALLBACK_DELAY = 10
local timePlayedRequested = false
local lastTimePlayed
local lastTimePlayedAt

local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

function f:PLAYER_LOGIN(event)
    if Characters == nil then
        Characters = {}
    end

    if Characters[characterGuid] == nil then
        print("New Character with GUID " .. characterGuid .. " detected... adding to database")
        self:AddCharacter()
    else
        self:UpdateCharacter()
    end

    -- Create snapshots for the character's current state
    -- Want to do this every login, so we know the last time they were at the prior level after a long time logged out
    self:RecordPartialLevelSnapshot()
    local _, iLvl = GetAverageItemLevel()
    self:RecordGearSnapshot(iLvl)

    -- The default UI never asks for time played on its own, so ask ourselves unless another addon already has
    C_Timer.After(TIME_PLAYED_FALLBACK_DELAY, function()
        if not timePlayedRequested then
            RequestTimePlayed()
        end
    end)
end

function f:PLAYER_LEVEL_UP(event, level)
    lastPartialLevel = level + 0.0
    self:RecordLevelSnapshot(lastPartialLevel)
end

function f:PLAYER_XP_UPDATE(event)
    local now = time()

    -- Kept current even when the snapshot itself is throttled, since logout writes this instead of asking the API
    self:UpdatePartialLevel()

    if now - lastXpSnapshotTime >= XP_SNAPSHOT_INTERVAL then
        self:RecordLevelSnapshot(lastPartialLevel)
        lastXpSnapshotTime = now
    end
end

function f:PLAYER_AVG_ITEM_LEVEL_UPDATE(event)
    local _, newILvl = GetAverageItemLevel()
    
    -- only create a snapshot if we actually gain item level
    if not currentILvl or newILvl > currentILvl then
        self:RecordGearSnapshot(newILvl)
    end
end

function f:TIME_PLAYED_MSG(event, totalTimePlayed, levelTimePlayed)
    timePlayedRequested = true
    lastTimePlayed = totalTimePlayed
    lastTimePlayedAt = time()
    self:RecordTimePlayedSnapshot(totalTimePlayed, lastTimePlayedAt)
end

-- Fires only on logout and /reload (PLAYER_LEAVING_WORLD also fires on every loading screen), right before
-- SavedVariables are written. The level API returns bad values this late, so write the last value seen instead.
function f:PLAYER_LOGOUT(event)
    local now = time()

    if lastPartialLevel then
        self:RecordLevelSnapshot(lastPartialLevel, now)
    end

    -- A reply to a fresh time played request can't arrive before the UI unloads, but played time keeps counting through
    -- loading screens and reloads, so the last reply plus the seconds since it arrived is the played total right now.
    if lastTimePlayed then
        self:RecordTimePlayedSnapshot(lastTimePlayed + (now - lastTimePlayedAt), now)
    end
end

function f:UpdateCharacter()
    local name = UnitName("player")
    local class, _, classId = UnitClass("player")
    local spec = GetSpecialization()

    if not spec then
        spec = 5
    end

    local specId, specName = GetSpecializationInfoForClassID(classId, spec)
    local race, _, raceId = UnitRace("player")
    local faction = UnitFactionGroup("player")

    Characters[characterGuid].Name = name
    Characters[characterGuid].Realm = GetRealmName()
    Characters[characterGuid].Class = class
    Characters[characterGuid].Specialization = specName
    Characters[characterGuid].Race = race
    Characters[characterGuid].Faction = faction
end

function f:AddCharacter()
    -- Create our character record with empty histories, then populate demographics
    Characters[characterGuid] = {
        Name = "",
        Realm = "",
        Class = "",
        Specialization = "",
        Race = "",
        Faction = "",
        LevelHistory = {},
        GearHistory = {},
        TimePlayedHistory = {}
    }

    self:UpdateCharacter()

    -- Go through Level Milestone Achievements and make snapshots of them
    for a, l in pairs(AchievementMilestoneIds) do        
        local _, _, _, _, month, day, year, _, _, _, _, _, earnedByMe = GetAchievementInfo(a)        
               
        if earnedByMe then
            year = year + 2000
            local timeStamp = time({year = year, month = month, day = day})
            
            self:RecordLevelSnapshot(l, timeStamp)
        end
    end

    
end

function f:RecordLevelSnapshot(level, timeStamp)
    timeStamp = timeStamp or time()

    --print("Recording level snapshot: level " .. level .. " at " .. timeStamp)

    table.insert(Characters[characterGuid].LevelHistory, {timeStamp, level})
end

function f:RecordPartialLevelSnapshot(timeStamp)
    self:UpdatePartialLevel()
    self:RecordLevelSnapshot(lastPartialLevel, timeStamp)
end

function f:UpdatePartialLevel()
    local level = UnitLevel("player")
    local currentXp = UnitXP("player")
    local maxXp = UnitXPMax("player")

    if maxXp and maxXp > 0 then
        lastPartialLevel = level + (currentXp / maxXp)
    else
        lastPartialLevel = level + 0.0
    end
end

function f:RecordGearSnapshot(ilvl, timeStamp)
    timeStamp = timeStamp or time()

    --print("Recording gear snapshot: ilvl " .. ilvl .. " at " .. timeStamp)

    table.insert(Characters[characterGuid].GearHistory, {timeStamp, ilvl})

    -- Updating our current item level now that we've recorded a new snapshot
    currentILvl = ilvl
end

function f:RecordTimePlayedSnapshot(timePlayed, timeStamp)
    timeStamp = timeStamp or time()

    if Characters[characterGuid].TimePlayedHistory == nil then
        Characters[characterGuid].TimePlayedHistory = {}
    end

    table.insert(Characters[characterGuid].TimePlayedHistory, {timeStamp, timePlayed})
end

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
f:RegisterEvent("TIME_PLAYED_MSG")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", f.OnEvent)

-- Counts another addon's request whose reply hasn't arrived yet when the fallback timer fires. Addons that cached
-- RequestTimePlayed in a local before this ran bypass the hook, which is why TIME_PLAYED_MSG sets the flag too.
hooksecurefunc("RequestTimePlayed", function()
    timePlayedRequested = true
end)

