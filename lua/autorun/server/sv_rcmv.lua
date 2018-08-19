function BeginMapChange(votes,maplist)
    dbg("BeginMapChange() Started")
    nextlevel = rcvote(votes,maplist)
    -- Attempting to unsuccessfully
    nextmap = nextlevel
    mapname = nextmap
    -- Neat, that didn't work, so let's do this instead!
    file.Write("rcmapvote/nextmap.txt",nextmap)
    dbg("Switching to " .. nextlevel)
    net.Start("RCMVmapwinner")
    net.WriteString(nextmap)
    net.Broadcast()
    timer.Simple(15, game.LoadNextMap)
end

function CheckIfReadyChange(votes,maplist)
    dbg("CheckIfReadyChange() Started")
    allPlayers = player.GetHumans()
    if #votes == #allPlayers then
        if not mapchangeSent then
            ServerLog("All votes submitted. Begin map change.")
            BeginMapChange(votes,maplist)
            mapchangeSent = true
        end
    end
end

function startVoting()
    updateMaps()
    local function shuffleTable(t)
        local n = #t -- gets the length of the table
        while n > 2 do -- only run if the table has more than 1 element
            local k = math.random(n) -- get a random number
            t[n], t[k] = t[k], t[n]
            n = n - 1
            end
        return t
    end

    local shuffledMaps = usableMaps
    shuffledMaps = shuffleTable(shuffledMaps)

    -- if the user was already connected when this file restarted
    broadcastAutofillMaps()

    -- Add random map that's not a nomination
    local finalMaplist = {}
    for _,map in ipairs(shuffledMaps) do
        if(#finalMaplist < getNumberRandomMaps()) then
            if not tableContains(approvedNominations, map) then
                table.insert(finalMaplist, map)
            end
        end
    end

    -- Add the nominated maps
    table.Add(finalMaplist, approvedNominations)

    -- Send to all players
    ServerLog("Map voting has started with the following maps: " .. table.ToString(finalMaplist))
    net.Start("RCMVmaplist")
    net.WriteTable(finalMaplist)
    net.Broadcast()

    -- Add countdown until the mamp is changed
    timer.Simple(getVotingDuration(), function()
        BeginMapChange(castVotes,finalMaplist)
    end)
    -- Check if all the votes are in in five second intervals
    timer.Create("allVotes", 5, 0, function()
        CheckIfReadyChange(castVotes,finalMaplist)
    end)
    -- Broadcast to all players the amount of time left
    net.Start("RCMVtimer")
    net.WriteInt(getVotingDuration(),32)
    net.Broadcast()
end

function forceVoting(ply, command, args)
    if (not IsValid(ply)) or ply:IsAdmin() or ply:IsSuperAdmin() or cvars.Bool("sv_cheats", 0) then
        PrintMessage(HUD_PRINTTALK, "Someone has forced a mapvote to occur!")
        startVoting()
        else
        ply:PrintMessage(HUD_PRINTCONSOLE, "Sorry! In order to do that, you have to be either an admin or a superadmin, or have sv_cheats enabled.")
    end
end