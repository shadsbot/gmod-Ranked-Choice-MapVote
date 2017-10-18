-- Fix it to use our nextmap
RunConsoleCommand("mapcyclefile", "data/rcmapvote/nextmap.txt")
CreateConVar("rcmv_whitelist", 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Decides if maplist.txt is used as a whitelist or a blacklist.")
CreateConVar("rcmv_votingduration", "120", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }) -- Make the voting duration alterable.
CreateConVar("rcmv_debug", 0, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Enable debugging messages in console for RCMV. Recommended to keep disabled.")

-- Check if anything exists, if not, create it
if not file.Exists('rcmapvote/nextmap.txt','data') then
	file.Write("rcmapvote/nextmap.txt", "ttt_rooftops_2016_v1")
end
if not file.Exists('rcmapvote/maplist.txt','data') then
	file.Write('rcmapvote/maplist.txt', "gm_flatgrass\r\ngm_construct\r\nttt_terrortownexamplemap") -- Example of how to add maps
end