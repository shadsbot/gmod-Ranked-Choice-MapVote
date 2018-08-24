-- Allows debug messages to be toggled
function dbg(msg)
    if(GetConVar("rcmv_debug"):GetInt() == 1) then
        print(msg)
    end
end

function tableContains(table, value)
    for i=1, #table do
        if table[i] == value then
            return true
        end
    end
    return false
end

function isWhitelistMode()
    if (GetConVar("rcmv_whitelist"):GetInt() == 1) then
        return true
    end
    return false
end

function getMaxNominations()
    return GetConVar("rcmv_maxnominations"):GetInt()
end

function getNumberRandomMaps()
    return GetConVar("rcmv_numberofrandommaps"):GetInt()
end

function getVotingDuration()
    return GetConVar("rcmv_votingduration"):GetInt()
end

function nominationsAllowed()
    if(GetConVar("rcmv_nominations"):GetInt() == 1) then
        return true
    end
    return false
end

function insertScannedMaps()
    installedMaps = file.Find("maps/ttt_*.bsp", "GAME")
    -- Remove file extensions before final list is sent
    for index,map in ipairs(installedMaps) do
        installedMaps[index] = string.gsub(map,".bsp","")
    end
    
    for index,map in ipairs(installedMaps) do 
        table.insert(usableMaps,map) 
    end
end

function isBlackListed(map, localMapList)
    for _,blacklistedMap in ipairs(localMapList) do 
        if (map == blacklistedMap) then
            return true
        end
        return false   
    end 
end

function getMapData()
    local localMapList = file.Read("rcmapvote/maplist.txt")
    local processed = {}
    local namesOnly = {}
    
    -- Split by newline, make array by delimiter " "
    for map in localMapList:gmatch("([^\n]*)\n?") do
        if (string.len(map) > 0) then -- may be a newline at end of file
            table.insert(processed, string.Explode(" ",map))
        end
    end
    for _,map in ipairs(processed) do
            table.insert(namesOnly, map[1])
    end
    return processed,namesOnly
end

function getMapMinPlayers(map)
    for _,mapName in ipairs(mapData) do 
        if (mapName[1] == map) then
            return tonumber(mapName[2]) or 0
        end
    end
    -- Map not found, tell the user and default to a safe number
    ServerLog("RCMV:sv_universal.lua:getMapMaxPlayers(): Map " .. map .. " not found.")
    return 0
end
function getMapMaxPlayers(map)
    for _,mapName in ipairs(mapData) do 
        if (mapName[1] == map) then
            return tonumber(mapName[3]) or 999
        end
    end
    ServerLog("RCMV:sv_universal.lua:getMapMaxPlayers(): Map " .. map .. " not found.")
    return 999
end

function playerMapRatioEnabled()
    if(GetConVar("rcmv_nominate_ignore_playerlimit"):GetInt() == 0) then
        return true
    end
    return false
end

function determineMapRatioLegal(map)
    if playerMapRatioEnabled() then 
        if player.GetCount() >= getMapMinPlayers(map) then
            if player.GetCount() <= getMapMaxPlayers(map) then
                dbg("enough players " .. map .. player.GetCount() .. " " .. getMapMinPlayers(map) .. " " .. getMapMaxPlayers(map))
                return true
            end
            dbg("too many players for map")
            return false, "there are too many players for this map"
        end
        dbg("not enough players for map")
        return false, "there are not enough players for this map"
    end
    return true
end

function updateMaps()
    dbg("updateMaps() has run")
    usableMaps = {} -- global, "update" is really a re-write from scratch
    processed,localMapList = getMapData()
    mapData = processed;
    if isWhitelistMode() then
        for _,map in ipairs(localMapList) do 
            table.insert(usableMaps, map) 
        end
    else
        insertScannedMaps()
        local blacklistIndexes = {}
        -- Iterate through the maps to see if any are blacklisted
        for _,m in ipairs(installedMaps) do
            if (isBlackListed(m, localMapList)) then
                table.insert(blacklistIndexes, _)
            end            
        end
        
        -- Reverse blacklistIndexes because popping in sequential would
        -- shift the indexes of the other maps
        blacklistIndexes = table.Reverse(blacklistIndexes)
        for _,i in ipairs(blacklistIndexes) do
            table.remove(usableMaps,i)
        end
    end
end