if SERVER then
    castVotes = {}
    nominatedMaps = {}
    approvedNominations = {}
    usableMaps = {}
    installedMaps = {}
    votedPlayers = {}
    mapchangeSent = false
    
    include('sv_network.lua')           -- network strings
    include('sv_universal.lua')         -- shared functions
    include('sv_rcvote.lua')            -- the actual voting functionality
    include('sv_clientinterface.lua')   -- talking to the client
    include('sv_rcmv.lua')              -- core functions
    include('sv_nominations.lua')       -- map nominations
    include('sv_setup.lua')              -- files, settings, hooks, & convars
    dbg("RCMV Autorun initiated")
    ServerLog("RCMV loaded.")
end