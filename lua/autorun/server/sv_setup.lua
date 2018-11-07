-- Setup
print("running setup")
RunConsoleCommand("mapcyclefile", "data/rcmapvote/nextmap.txt")
CreateConVar("rcmv_whitelist", 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Decides if maplist.txt is used as a whitelist or a blacklist.")
CreateConVar("rcmv_votingduration", "120", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }) -- Make the voting duration alterable.
CreateConVar("rcmv_debug", 0, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Enable debugging messages in console for RCMV. Recommended to keep disabled.")
CreateConVar("rcmv_nomination_limit", 4, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "The maximum number of maps that can be nominated per round.")
CreateConVar("rcmv_nomination_enabled", 1, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Allow players to nominate maps to play on.")
-- CreateConVar("rcmv_nomination_playerlimit", "UNSET", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Legacy convar replaced by rcmv_playerlimits")
CreateConVar("rcmv_playerlimits", 1, {FCVAR_ARCHIVE, FCVAR_ARCHIVE}, "Only allow maps that there are enough players for.")
CreateConVar("rcmv_mapcount", 3, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Number of maps to randomly select each time.")
concommand.Add("rcmv_forcevoting", forceVoting)

-- Convert old convars to new ones
if ConVarExists("rcmv_nomination_playerlimit") then
    if not (GetConVar("rcmv_nomination_playerlimit"):GetString() == "UNSET") then
        GetConVar("rcmv_playerlimits"):SetBool(GetConVar("rcmv_nomination_playerlimit"):GetBool())
        GetConVar("rcmv_nomination_playerlimit"):SetString("UNSET")
    end
end

-- Check if anything exists, if not, create it
if not file.Exists("rcmapvote","data") then
	file.CreateDir("rcmapvote")
end
if not file.Exists('rcmapvote/nextmap.txt','data') then
	file.Write("rcmapvote/nextmap.txt", "ttt_rooftops_2016_v2") -- This is a temporary throwaway map just to populate the file
end
if not file.Exists('rcmapvote/maplist.txt','data') then
	file.Write('rcmapvote/maplist.txt', "gm_flatgrass\r\ngm_construct\r\nttt_terrortownexamplemap") -- Example of how to add maps
end

-- Load settings
cvars.RemoveChangeCallback("rcmv_whitelist")
cvars.AddChangeCallback("rcmv_whitelist", function( convar_name, oldv, newv)
    if (oldv == '1') then
        print("The map list will be loaded from maps/ttt_*.bsp. data/rcmapvote/maplist.txt will be used as a blacklist.")
    else
        newv = '0'
        print("The map list will be loaded from data/rcmapvote/maplist.txt. If you have not configured this file to contain your desired map list, please do so now as it contains example map names.")
    end
    -- Clear out any nominations that may have been approved as they may no longer be valid
    for k in pairs(approvedNominations) do 
        approvedNominations[k] = nil
    end
    updateMaps()
    broadcastAutofillMaps()
end)

-- Initialize hooks
hook.Add("Initialize", "TTTMapvoteTrigger", function()
    if GAMEMODE_NAME == "terrortown" then
        -- Overload default TTT function
        function CheckForMapSwitch()
        	-- Remaining rounds has to be minus 1 because if it's the last
        	-- round left we want it to run at the end of that round. Pull
        	-- 0 if it's a negative number in order to trigger this
            local rounds = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
            SetGlobalInt("ttt_rounds_left", rounds)
            local time = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
            local cont = false
            -- Sends an array with key mapname to pop up in a little bubble in
            -- the corner. We don't know the map yet so just say "The Community
            -- picked map" instead.
            local mapmsg = "The community picked map"
            if rounds <= 0 then
                LANG.Msg("limit_round", {mapname = mapmsg})
                cont = true
            elseif time <= 0 then
                LANG.Msg("limit_time", {mapname = mapmsg})
                cont = true
            end
            if cont then
            	-- TTT timer
                timer.Stop("end2prep")
                startVoting()
            end
        end
    end
end)

-- Sending the list of maps they can nominate when they spawn
hook.Add("PlayerInitialSpawn", "RCMVPlayerConnectedBroadcastMaps", function(ply)
    -- This should be a reference to sendAutofillMaps(ply) but for some reason
    -- that's not working...
    dbg("Sending maps to " .. ply:Nick())
    if (#usableMaps == 0) then
        dbg("Maps were empty? Updating...")
        updateMaps()
    end
    dbg(table.ToString(usableMaps))
    net.Start("RCMVreqmaps")
    net.WriteTable(usableMaps)
    net.Send(ply)
    dbg("Maps have been sent")
end)
-- Checking to see if they say !nominate mapname
hook.Add("PlayerSay", "RCMVPlayerSayNominate", function (ply, text, team)
    checkPlayerNomination(ply,text,team)
end)

dbg("Updating maps and broadcasting")
updateMaps()
broadcastAutofillMaps()