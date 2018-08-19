function sendAutofillMaps(ply)
    if (#usableMaps == 0) then
        dbg("Maps were empty? Updating...")
        updateMaps()
    end
    dbg(table.ToString(usableMaps))
    net.Start("RCMVreqmaps")
    net.WriteTable(usableMaps)
    net.Send(ply)
    dbg("Maps have been sent")
end

function broadcastAutofillMaps()
    for _,ply in ipairs(player.GetHumans()) do 
        dbg("Broadcasting maps")
        sendAutofillMaps(ply)
    end
end