-- All maps have been received from server
net.Receive("RCMVreqmaps", function(len)
	print("Recieved maps with len ".. len)
	nominationMaps = net.ReadTable()
	print(PrintTable(nominationMaps))
end)

-- Someone has nominated a map
net.Receive("RCMVchat", function(len)
	local info = net.ReadTable()
	timer.Create("delayedChatTimer", (1/30), 1, function()
		chat.AddText(
			Color(78, 196, 255), info.Nick,
			Color(255,255,255), " has nominated ",
			Color(255,246,167), info.Text
			)
	end )
end)

-- A map has been selected
net.Receive("RCMVmapwinner", function()
	stopCountdownTimer()
	surface.PlaySound("buttons/button19.wav")
	displayMessage("The next map is: " .. net.ReadString(), 10)
end)

-- We have received the final selection of maps to vote on
net.Receive("RCMVmaplist", function()
	votableMaps = net.ReadTable()
	local function shuffleTable(t)
		local n = #t -- gets the length of the table 
		while n > 2 do -- only run if the table has more than 1 element
			local k = math.random(n) -- get a random number
			t[n], t[k] = t[k], t[n]
			n = n - 1
			end
		return t
	end
	votableMaps = shuffleTable(votableMaps)
	PrintTable(votableMaps)
	voteWindow()
end)

-- Voting has begun, and we only have X seconds
net.Receive("RCMVtimer", function()
	startCountdownTimer(net.ReadInt(32))
end)

function sendVotes()
	net.Start("RCMVsendvote")
	net.WriteTable(votes)
	net.SendToServer()
end