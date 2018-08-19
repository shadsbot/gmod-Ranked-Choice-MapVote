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
    for blacklistedMap in localMapList:gmatch("%S+") do 
        if (map == blacklistedMap) then
            return true
        end
        return false   
    end 
end

function updateMaps()
    dbg("updateMaps() has run")
    usableMaps = {} -- global, "update" is really a re-write from scratch
    local localMapList = file.Read("rcmapvote/maplist.txt")
    if isWhitelistMode() then
        for map in localMapList:gmatch("%S+") do 
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