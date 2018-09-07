// sv_logs.lua
// Player connections, steamIDs, admin commands, chatting etc.

if (SEAS.MISC.UseLogs) then
	// Used to keep track of the number of logs.
	SEAS.LogCount = SEAS.LogCount or 0

	function SEAS:Log(str, logtype)
		if (!SEAS.MISC.UseLogs) then return end
	
		// If you're not logging chat logs then it won't log anything.
		// Useful for high player count servers and prevents potential issues.
		if (logtype == "CHAT" && !SEAS.MISC.SaveChatLogs) then return end
		
		local sql_server = "<"..GetHostName().."> "
		local sql_time = os.date( "[%d/%m/%Y - %H:%M:%S]")
		local server = ""
		
		if (SEAS.MISC.UseServerName) then
			server = "<"..GetHostName().."> "
		else
			server = "<"..game.GetIPAddress().."> "
		end
		
		server = server..str
		
		if (logtype == "") then
			logtype = "UNKNOWN"
		end
		
		SEAS:Query([[INSERT INTO seas_logs(server, timestamp, details, type)
			VALUES("]]..sql_server..[[", "]]..sql_time..[[", "]]..str..[[", "]]..logtype..[[")]])
	end 
end

hook.Add("PlayerInitialSpawn", "SEAS_LogPlayerSpawning", function(ply)
	SEAS:Log("[PLAYER SPAWNED] ("..ply:SteamID()..") "..ply:Nick(), "SPAWNED")
end)

hook.Add("PlayerDeath", "SEAS_LogPlayerDeath", function(v, w, k)
	if ( v == k ) or ( !k:IsPlayer() ) then
		SEAS:Log("[DEATH LOG] ("..v:SteamID()..") " ..v:Nick().. " KILLED THEMSELVES.", "DEATH")
		return
	end
	
	SEAS:Log("[DEATH LOG] ("..v:SteamID()..") " ..v:Nick().. " was KILLED by ("..k:SteamID()..") " ..k:Nick().. " using " ..w:GetClass(), "DEATH")
end)