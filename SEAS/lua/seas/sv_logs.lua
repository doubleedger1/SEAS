// sv_logs.lua
// Player connections, steamIDs, admin commands, chatting etc.

if (SEAS.MISC.UseLogs) then
	// Used to keep track of the number of logs.
	SEAS.LogCount = SEAS.LogCount or 0

	function SEAS:Log(str, logtype)
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
		
		print(server)
		SEAS:Query([[INSERT INTO seas_logs(server, timestamp, details, type)
			VALUES("]]..sql_server..[[", "]]..sql_time..[[", "]]..str..[[", "]]..logtype..[[")]])
	end 
end