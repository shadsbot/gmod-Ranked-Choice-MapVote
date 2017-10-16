util.AddNetworkString("RCMVsendvote")
util.AddNetworkString("RCMVmaplist")
util.AddNetworkString("RCMVmapwinner")
util.AddNetworkString("RCMVchat")
util.AddNetworkString("RCMVreqmaps")
util.AddNetworkString("RCMVtimer")

-- Include the main file
include("sv_init.lua")
include("sv_rcvote.lua")

if SERVER then
	-- Load settings
	cvars.RemoveChangeCallback("rcmv_whitelist")
	cvars.AddChangeCallback("rcmv_whitelist", function( convar_name, oldv, newv ) 
		if (oldv == '1') then 
			print("Maplist will be loaded from maps/ttt_*.bsp and use data/rcmapvote/maplist.txt as a blacklist.") 
		else 
			newv = '0' -- If it ain't 1 it's 0
			print("Maplist will be loaded from data/rcmapvote/maplist.txt") 
		end
	end )

	-- Send the maplist for autocomplete and nomination reasons when they connect
	-- May be deprecated, Shad: investigate this
	hook.Add("PlayerInitialSpawn", "playerconnectedbroadcastmaps", function(ply)
		net.Start("RCMVreqmaps")
		local ml = ""
		if (GetConVar("rcmv_whitelist"):GetInt() == 0) then
			local scanlist = file.Find("maps/ttt_*.bsp", "GAME")
			-- Remove file extensions before final list is sent
			for _,i in ipairs(scanlist) do
				scanlist[_] = string.gsub(i,".bsp","")
				ml = scanlist[_] .. " " .. ml
			end
		else
			ml = file.Read("rcmapvote/maplist.txt")
		end
		net.WriteString(ml)
		net.Send(ply)
	end)


	function BeginMapChange(v,w)
		print("BeginMapChange() Started")
		nextlevel = rcvote(v,w)
		-- Attempting to unsuccessfully
		nextmap = nextlevel
		mapname = nextmap
		-- Neat, that didn't work, so let's do this instead!
		file.Write("rcmapvote/nextmap.txt",nextmap)
		print("Switching to " .. nextlevel)
		-- We have a winner, tell everyone
		net.Start("RCMVmapwinner")
		net.WriteString(nextmap)
		net.Broadcast()
		--LANG.Msg("limit_round", {mapname = nextmap})
		timer.Simple(15, game.LoadNextMap)
		-- RunConsoleCommand("changelevel", newmap)
	end
	function CheckIfReadyChange(v,w)
		allPlayers = player.GetAll()
		if #v == #allPlayers then
			print("CheckIfReadyChange() Started")
			BeginMapChange(v,w)
		end
	end

	print("\nSV_RCMAPVOTE LOADED IN! O7")
	
	local castVotes = {}
	local nominatedMaps = {}

	-- Send the client the maplist
	function startVoting()
		local contents = file.Read("rcmapvote/maplist.txt")
		-- Scramble
		local function shuffle(t)
			local n = #t -- gets the length of the table
			while n > 2 do -- only run if the table has more than 1 element
				local k = math.random(n) -- get a random number
				t[n], t[k] = t[k], t[n]
				n = n - 1
				end
			return t
		end

		local maps = {}
		local nominate = {}
		if (GetConVar("rcmv_whitelist"):GetInt() == 1) then
			for map in contents:gmatch("%S+") do table.insert(maps, map) end
		else
			local scanlist = file.Find("maps/ttt_*.bsp", "GAME")
			-- Remove file extensions before final list is sent
			for _,i in ipairs(scanlist) do
				scanlist[_] = string.gsub(i,".bsp","")
			end
			for index,map in ipairs(scanlist) do table.insert(maps,map) end
			local saveTable = {}
			local indexTable = {}
			-- For map "m" in the list of scanned maps with index "_"
			for _,m in ipairs(scanlist) do
				-- For map in blacklist file
				for bmap in contents:gmatch("%S+") do
					if (m == bmap) then table.insert(indexTable, _) end
				end
			end
			-- Remove indexes in reverse to be safe!
			indexTable = table.Reverse(indexTable)
			for _,i in ipairs(indexTable) do
				table.remove(maps,i)
			end
		end
		local whitelist = maps
		-- scramble the whitelist
		whitelist = shuffle(whitelist)

		-- This exists if we restart this file while clients are connected
		net.Start("RCMVreqmaps")
	--	net.WriteString(contents)
		local mapString = ""
		for _,m in ipairs(maps) do mapString = mapString .. "\n" .. m end
		net.WriteString(mapString)
		net.Broadcast()

		local toClient = whitelist[1] .. " " .. whitelist[2] .. " " .. whitelist[3]

		-- Check nominated maps if they actually exist and for duplicates
		local approvedNominations = {}
		local function validMap(m,maplist)
			for _,v in ipairs(maplist) do
				if m == v then return true end
			end
			return false
		end
		local function duplicateMap(m,maplist)
			for _,v in ipairs(maplist) do 
				if m== v then return true end
			end
			return false
		end

		for _,m in ipairs(nominatedMaps) do
			if validMap(m,whitelist) then
				if not duplicateMap(m,approvedNominations) then
					if not (m == whitelist[1]) then
						if not (m == whitelist[2]) then
							if not (m == whitelist[3]) then
								table.insert(approvedNominations,m)
							end
						end
					end
				end
			end
		end

		-- Add the nominated maps
		for i=1,#approvedNominations do
			if i < 5 then
				toClient = toClient .. " " .. approvedNominations[i]
			end
		end

		net.Start("RCMVmaplist")
		net.WriteString(toClient)
		net.Broadcast()
		-- You can't wait forever! Get your votes sent in!
		timer.Simple(GetConVar("rcmv_votingduration"):GetInt(), function() BeginMapChange(castVotes,whitelist) end)
		timer.Create("allVotes", 5, 0, function()
			CheckIfReadyChange(castVotes,whitelist)
			end)
		-- Let them know they can't take forever
		net.Start("RCMVtimer")
		net.WriteInt(GetConVar("rcmv_votingduration"):GetInt(),32)
		net.Broadcast()
	end

	-- Get their votes
	net.Receive("RCMVsendvote", function(len,ply)
		local votes = net.ReadTable()
		table.insert(castVotes,votes)	-- Insert it into the master table
	end )
	
	print(GetGlobalInt("ttt_rounds_left") .. " rounds remaining")

	-- Adapted from default TTT code and MapSwitch by Willox (github.com/willox/gmod-mapvote)
	-- (CC0 1.0)
	hook.Add( "Initialize", "TTTmapvoteTrigger", function()
      if GAMEMODE_NAME == "terrortown" then
      	-- Override default TTT function
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
	end )

	-- The function to be called when someone attempts to force voting via concommand rcmv_forcevoting
	local function forceVoting(ply, command, args)
		if (not IsValid(ply)) or ply:IsAdmin() or ply:IsSuperAdmin() or cvars.Bool("sv_cheats", 0) then
			PrintMessage( HUD_PRINTTALK, "Someone has forced a mapvote to occur!" )

			startVoting()
			else
			ply:PrintMessage( HUD_PRINTCONSOLE, "Sorry! In order to do that, you have to be either an admin or a superadmin. Or have sv_cheats enabled." )
		end
	end
	concommand.Add( "rcmv_forcevoting", forceVoting )

	-- Player nominates
	hook.Add ("PlayerSay", "PlayerSayNominate", function (ply, text, team )
		if ( string.sub( text, 1, 9 ) == "!nominate" ) then
			-- if they only send !nominate
			if #text == 9 or #text == 10 then
				timer.Create("respondNominateChat", (1/30), 1, function()
					ply:PrintMessage(HUD_PRINTTALK, "!nominate <map> : Adds a map to the mapvote queue")
				end )
			else
				if text == "!nominate list" then
					timer.Create("respondNominateChatList", (1/30), 1, function()
						if #nominatedMaps > 1 then
								ply:PrintMessage(HUD_PRINTTALK,"Nominated maps:")
							for i=1,#nominatedMaps do
								ply:PrintMessage(HUD_PRINTTALK,nominatedMaps[i])
							end
						else
							ply:PrintMessage(HUD_PRINTTALK,"No maps have been nominated yet! Why not add one?")
						end
					end )
				else
					-- remove "!nominate "
					text = string.sub( text, 11 )
					dbg(text)
					-- If variable is in table
					local function contains(table, val)
						for i=1,#table do
							if table[i] == val then
								return true
							end
						end
						return false
					end
					table.insert(nominatedMaps,text)
					timer.Create("thisNoMapTimer", (1/30), 1, function() 
							ply:PrintMessage(HUD_PRINTTALK, text .. " has been added to the nomination queue for processing.")
							end)
						end
			end
		end
	end )
end
