# Ranked Choice Map Vote for Garry's Mod

[See it in action!](https://www.youtube.com/watch?v=MJ0SV3D3SEs)

Right now this addon only works for TTT, but that may change in the near future.

This addon utilizes ranked choice (runoff) voting methods to find the least unfavourable map to play on. You rank a list of at least three and at most seven maps from most preferable to least preferable. 

For more information about Ranked Choice voting systems and how they work, [check out CGP Grey's explanation](https://www.youtube.com/watch?v=3Y3jE3B8HsE).

## Structure

RCMV will use a file, `maplist.txt`, located in `garrysmod/data/rcmapvote`, as a blacklist. It can be changed to act as a whitelist depending on the value of the `rcmv_whitelist` convar.

|rcmv_whitelist|maplist.txt|
|---|---|
|0|blacklist|
|1|whitelist|

When acting as a whitelist, it will only draw from the maps in `maplist.txt`, while acting as a blacklist it will scan the `maps` folder for any `.bsp` that contains the `ttt_` prefix, and exclude the maps in `maplist.txt`. Each map should be on its own line, and without the `.bsp` extension.

You can configure the amount of time players have to vote by changing the  `rcmv_votingduration` convar (seconds), defaults to `120`.

Force the mapvote to start by running the concommand `rcmv_forcevoting`.

Players can also nominate up to four maps of their choosing. The map must be in the whitelist if in whitelist mode, and not blacklisted if in blacklist mode. They can nominate by using the `!nominate <map>` chat command. 