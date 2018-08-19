-- Network strings
util.AddNetworkString("RCMVsendvote")
util.AddNetworkString("RCMVmaplist")
util.AddNetworkString("RCMVmapwinner")
util.AddNetworkString("RCMVchat")
util.AddNetworkString("RCMVreqmaps")
util.AddNetworkString("RCMVtimer")

-- Receiving votes
net.Receive("RCMVsendvote", function(len,ply)
    local votes = net.ReadTable()
    dbg(ply:SteamID64())
    dbg(table.ToString(votes))
    if not (tableContains(votedPlayers,ply:SteamID64())) then
        table.insert(castVotes,votes)
        table.insert(votedPlayers,ply:SteamID64())
    else
        dbg(ply:SteamID64() .. " has already voted")
    end
end)