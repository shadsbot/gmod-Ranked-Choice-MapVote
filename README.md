# Ranked Choice Map Vote for Garry's Mod

[See it in action!](https://www.youtube.com/watch?v=MJ0SV3D3SEs)

Right now this addon only works for TTT, but that may change in the near future.

This addon utilizes ranked choice (runoff) voting methods to find the least unfavourable map to play on. You rank a list of at least three and at most seven maps from most preferable to least preferable. 

For more information about Ranked Choice voting systems and how they work, [check out CGP Grey's explanation](https://www.youtube.com/watch?v=3Y3jE3B8HsE).

## Structure

RCMV will use a file, `maplist.txt`, located in `garrysmod/data/rcmapvote`, as a blacklist. It can be changed to act as a whitelist depending on the value of the `rcmv_whitelist` convar.

|rcmv_whitelist|maplist.txt|function|
|---|---|---|
|0|blacklist|exclude maps in maplist.txt|
|1|whitelist|only use what's in maplist.txt|

When acting as a whitelist, it will only draw from the maps in `maplist.txt`, while acting as a blacklist it will scan the `maps` folder for any `.bsp` that contains the `ttt_` prefix, and exclude the maps in `maplist.txt`. Each map should be on its own line, and without the `.bsp` extension.

You can configure the amount of time players have to vote by changing the  `rcmv_votingduration` convar (seconds), defaults to `120`.

Force the mapvote to start by running the concommand `rcmv_forcevoting`.

Players can also nominate up to four maps of their choosing by default. More can be allowed based on the `rcmv_nomination_limit` ConVar. The map must be in the whitelist if in whitelist mode, and not blacklisted if in blacklist mode. They can nominate by using the `!nominate <map>` chat command. 

## ConVars and Config

|ConVar|Default|Description|Notes|
|------|-------|-----------|-----|
|rcmv_whitelist|0|Decides if maplist.txt is used as a whitelist or a blacklist.|See above|
|rcmv_votingduration|120||The amount of time that players have to submit their votes (in seconds).|
|rcmv_debug|0|Enable debugging messages in console for RCMV. Recommended to keep disabled.|Hark, thy manifold is fraught with perils|
|rcmv_nomination_limit|4|The maximum number of maps that can be nominated per round.|Shared among all players.|
|rcmv_nomination_enabled|1|Allow players to nominate maps to play on.|If this is off then they can't use `!nominate`|
|rcmv_nomination_playerlimit|1|Only allow maps to be nominated that there are enough players for.|If 1: nominations are rejected if not enough players present. If 0: any map can be nominated regardless of how many players are on.|
|rcmv_mapcount|3|Number of maps to randomly select each time.|RCMV will randomly select this number of maps for players to vote for each round.|
