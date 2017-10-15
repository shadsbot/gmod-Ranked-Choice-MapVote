if CLIENT then
	function dbg(a)
		if true then
			print(a)
		end
	end
	print("CL_RCMAPVOTE LOADED IN O7!")

	-- Let's display a message
	function rcmvMsg(a, time)
		local msgFrame = vgui.Create("DNotify")
		msgFrame:SetSize(300,60)
		msgFrame:SetPos(ScrW() /2, ScrH() / 24) -- ScrH() /2 )
		local bg = vgui.Create("DPanel", msgFrame)
		bg:Dock( FILL )
		bg:SetBackgroundColor( ( Color(64,64,64, 150) ) )

--		msgFrame:SetVisible(true)
--		msgFrame:MakePopup()
		

		local DLabel = vgui.Create("DLabel", bg)
		DLabel:SetPos(10,20)
		DLabel:SetSize(250,20)
		DLabel:SetText(a)
		DLabel:SetTextColor( Color( 255, 255, 255 ) )
		DLabel:SetFont( "GModNotify" )

		DLabel:SetContentAlignment(5)		

		msgFrame:CenterHorizontal()

		msgFrame:SetLife(time)
		msgFrame:AddItem(bg)
	end

	-- Nominate message received
	net.Receive("RCMVchat", function() 
		print("Made it this far: Nominate Edition: This time, It's Client")
		message = net.ReadTable()
		timer.Create("delayedChatTimer", (1/30), 1, function()
			chat.AddText(
				-- Set Colour: Red, print nick
				Color(255, 151, 11), message.Nick,
				-- Set Colour: White, print text "has nominated"
				Color(255,255,255), " has nominated ",
				-- Set Colour: Blue, print map
				Color(37, 37, 200), message.Text
				)
		end )
	end )

	-- Tick tock, we have a timer
	net.Receive("RCMVtimer", function()
		time = net.ReadInt(32)
		print("RCMV: you have " .. time .. " seconds to get your vote in.")
		timer.Create("TimerCountDownHUDTimer", 1, 0, function()
			hook.Add( "HUDPaint", "HUDTimerCountDown", function()
				draw.SimpleTextOutlined("Voting ends in " .. time .. " seconds.", "DermaDefault", ScrW() / 2, 50, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
			end )
			time = time - 1
			if (time < 1) then
			 	timer.Remove("TimerCountDownHUDTimer")
 				hook.Remove("HUDPaint","HUDTimerCountDown")
			end
		end )
			hook.Remove("HUDPaint","HUDTimerCountDown")
	end )

	-- MAP WINNER, TELL EVERYONE
	local rcmvmapwinnerfired = false
	net.Receive("RCMVmapwinner", function() 
		if not rcmvmapwinnerfired then 
		 	timer.Remove("TimerCountDownHUDTimer")
			hook.Remove("HUDPaint","HUDTimerCountDown")
			
			surface.PlaySound("buttons/button19.wav")
			a = net.ReadString()
			print(a)
			rcmvMsg("Next Map: " .. a,10) 
			rcmvmapwinnerfired = true
		end
	end )

	-- POPULATE THE MAPLIST
	net.Receive("RCMVmaplist", function()

	INTERNAL_DARK = Color(56,56,56)
	EXTERNAL_DARK = Color(108, 111, 114)
	BUTTON_DARK   = Color(160,160,160)
		local Frame = vgui.Create( "DFrame" )
		Frame:SetPos( 5, 150 )
		Frame:SetSize( 170, 400 )
		Frame:SetTitle( "Map Vote" )
		Frame:SetVisible( true )
		Frame:SetDraggable( true )
		Frame:ShowCloseButton( true )
		Frame:MakePopup()

		local votenum = 1
		local votelist = {}

		local chooseNum = { "First","Second","Third","Fourth","Fifth","Sixth","Seventh","Eighth", "Ninth" }
		local maplist = net.ReadString()
		local buttons = {}
		local maps = {}

		local DPanel = vgui.Create("DPanel", Frame)
		DPanel:SetPos(10,50)
		DPanel:SetSize(145,300)
		DPanel:SetBackgroundColor(INTERNAL_DARK)

		local DLabel = vgui.Create("DLabel", Frame)
		DLabel:SetText("Pick your " .. chooseNum[votenum] .. " choice")
		DLabel:SetPos(55,22)
		DLabel:SetSize(100,30)

		local mapVoteSize = 0;

		-- Separate into an array
		for map in maplist:gmatch("%S+") do table.insert(maps, map) end

		local function shuffle(t)
			local n = #t -- gets the length of the table 
			while n > 2 do -- only run if the table has more than 1 element
				local k = math.random(n) -- get a random number
				t[n], t[k] = t[k], t[n]
				n = n - 1
				end
			return t
		end
		maps = shuffle(maps)

		Frame:SetSize( 170, 90 + (40*#maps) )
		mapVoteSize = 40 * #maps
		DPanel:SetSize(145, mapVoteSize)

		local lastloc = 0
		for index,map in ipairs(maps) do
			dbg(index .. ": " .. map)
			maps[index] = vgui.Create("DButton", DPanel)
			maps[index]:SetText(map)
			maps[index]:SetSize(125,30)
			maps[index]:SetPos(10,lastloc+10)
			lastloc = lastloc + 35
			maps[index].DoClick = function()
				maps[index]:SetEnabled(false)
				maps[index]:SetText(votenum..": "..map)
				votelist[votenum] = map
				votenum = votenum+1
				DLabel:SetText("" .. chooseNum[votenum] .. " choice")
				if votenum == #maps then 
					DLabel:SetText("Submit!")
				end
			end
		end

		-- Back button, to undo stuff
		local BackButton = vgui.Create("DButton", Frame)
		BackButton:SetText("")
		BackButton:SetSize(24,20)
		BackButton:SetImage("icon16/arrow_rotate_clockwise.png")
		BackButton:SetPos(10,27)
		BackButton.DoClick = function()
			temp = {}
			-- Put it into temp
			for k,a in ipairs(maps) do
			   table.insert(temp,a:GetText())
			end
			-- Get the maplist without numbers
			for k=1,#temp do
			    temp[k] = string.gsub(temp[k],".: ","")
			end
			-- Search for the index that it appears at
			local ind = -1
			for k=1,#temp do
			    if temp[k] == votelist[#votelist] then ind = k end
			end
			-- Now that we know the "index", we need to remove it
			for i,a in ipairs(maps) do
				if i == ind then
					a:SetEnabled(true)
					a:SetText(temp[i])
					table.remove(votelist)
					votenum = votenum - 1
					DLabel:SetText("" .. chooseNum[votenum] .. " choice")
				end
			end
		end

		-- Add the forfeit(sp?) button
		index = table.getn(maps)+1
		maps[index] = vgui.Create("DButton", Frame)
		maps[index]:SetText("Done Voting")
		maps[index]:SetSize(125,30)
		lastloc = lastloc + 30
		maps[index]:SetPos(20, mapVoteSize + 55)
		maps[index]:SetIcon( "icon16/tick.png" )
		maps[index].DoClick = function()
			Frame:Close()
			-- Send it back to the server
			net.Start("RCMVsendvote")
			net.WriteTable(votelist)
			net.SendToServer()
		end
	end)

end