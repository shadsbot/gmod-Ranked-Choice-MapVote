-- Alternative Vote script
-- Written by Shadari, 1 Jul 2017

-- Debug function, really only there for my sake
function dbg(a) 
	if true then
		print(a)
	end
end
-- Votes must be input in a 2D array in the following format:
-- PLAYER > { vote1mapname, vote2mapname, vote3mapname, etc }
-- PLAYER > { etc, etc, etc }

-- Whitelist must exist as a 1D array consisting of maps

-- totalvotes is a 1D keyed array formatted as follows: ["mapname"] = votecount
-- e.g. totalvotes = { ["gm_construct"] = 12, ["ttt_goodmap"] = 2 }

-- Required function: isLegal(map, whitelist)
-- Returns if map in question is in the whitelist
function isLegal(map, whitelist)
	flag = false
	for i=1, #whitelist, 1 do
		if (map == whitelist[i]) then
			flag = true
		end
	end
	if (flag) then return true end
	return false
end
-- Function that actually goes through and decides which vote from the player
-- will be used in this drawing. Returns mapname or nil
function getMapVote(votes, wl)
	for i=1,#votes,1 do
		if isLegal(votes[i],wl) then return votes[i] end
	end
	-- Placeholder for now
	return "novote"
end

-- All of these are input with a keyed array that tells you how many votes
-- each one got. Returns array of {"key",howmanyvotes}
function getMaxVote(tv, wl)
	max = tv[wl[1]]
	index = wl[1]
	for k=1,#wl,1 do
		if tv[wl[k]] then
			if tv[wl[k]] > max then
				max = tv[wl[k]]
				index = wl[k]
			end
		end
	end
	return {index,max}
end
function getMinVote(tv, wl)
	min = tv[wl[1]]
	index = wl[1]
	for k=1,#wl,1 do
		if tv[wl[k]] then
			if tv[wl[k]] < min then
				min = tv[wl[k]]
				index = wl[k]
			end
		end
	end
	return {index,min}
end
-- Returns int
function getTotVote(tv, wl)
	tot = 0
	for k=1,#wl,1 do
		-- Check if it's not null
		if tv[wl[k]] then
			tot = tot + tv[wl[k]]
		end
	end
	return tot
end

-- Main function time. Returns mapname
function rcvote(votes, whitelist)
	-- In the event we don't find a majority, run through this until 
	-- there's only two left
	while #whitelist > 1 do
		totalvotes = {}
		for i=1,#whitelist,1 do
			totalvotes[whitelist[i]] = 0
		end
		-- Run through the votes array, find if each player's firstmost
		-- choice is a legal one. If it is, add it to totalvotes
		for i=1,#votes,1 do
			a = getMapVote(votes[i],whitelist)
			if not totalvotes[a] then totalvotes[a] = 0 end
			totalvotes[a] = totalvotes[a] + 1
		end
		-- Now that totalvotes is populated by legalmap -> votecount,
		-- populate some helpful values
		tot = getTotVote(totalvotes,whitelist)
		min = getMinVote(totalvotes,whitelist)
		max = getMaxVote(totalvotes,whitelist)
		-- Is there a majority? Return mapname
		if (tot/2) < max[2] then
			return max[1]
		-- There is not. Drop the lowest voted map from whitelist.
		else
			for k=1,#whitelist,1 do
				if min[1] == whitelist[k] then
					dbg("Striking: " .. whitelist[k])
					table.remove(whitelist,k)
				end
			end
		end
	end
	return whitelist[1]
end