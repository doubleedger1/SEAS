// sh_funcs.lua
// Contains content to be used on both server and client.

// Converts seconds into a formatted time string.
function SEAS:ConvertTimestamp(secs)   
	local timestring = {"year", "month", "week", "day", "hour", "minute"}
	local timeinseconds = {31536000, 2628000, 604800, 86400, 3600, 60}
	local duration = ""
	local broke = false
	
	if (secs >= 305360000) then
		return "PERMANENT"
	end
	
	// We want to make sure it's a number...
	if (type(secs) != "number") then
		return print("SEAS:ConvertTimestamp attempted to convert a non-number value: "..secs)
	end
	
	if (secs < 0) then
		return print("SEAS:ConvertTimestamp only converts positive values.")
	end
	
	for k, v in pairs(timeinseconds) do
		if (secs > v) then
			if (secs % v > 0 || secs / v > 0) then
				if (secs / v > 1.9999 ) then
					timestring[k] = timestring[k].."s"
				end
			end
			
			if (secs % v == 0) then
				duration = duration ..math.abs(math.floor(secs/v)).." "..timestring[k]..". "
				broke = true
				break
			else
				duration = duration ..math.abs(math.floor(secs/v)).." "..timestring[k]..", "
				secs = math.floor(secs % v)
			end
		end
	end 
	
	if (!broke) then
		if (secs > 1) then
			duration = duration .. secs .. " seconds."
		elseif !(secs < 1) then
			duration = duration .. secs .. " second." 
			duration = string.Trim(duration, ", ")
		end
	end
	
	return duration
end

// Checks for permissions based on power.
// Returns true or false.
function SEAS:PermissionChecks(ply, rank)

	local power = SEAS:ConvertToPowerlevel(rank)
	
	if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < power) then
		return false
	end
	
	return true
end

// Converts the string permissions to power levels.
// If you add any groups, add to this list to get powers.
function SEAS:ConvertToPowerlevel(str)
	if (type(str) != "string") then 
		return 0
	end
	
	if (str == "owner") then 
		return 100
	elseif (str == "superadmin") then
		return 75
	elseif (str == "admin") then
		return 50
	elseif (str == "mod") then
		return 25
	else
		return 0
	end
end

// Prints a message to all players.
function SEAS:PrintAll(...) 
	for k, v in pairs(player.GetAll()) do
		SEAS:AddText(v, unpack(...))
	end
end

// Used to print to an admin using a command gone wrong.
function SEAS:ShowAdminMessage(ply, message)
	SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, message)
end

// Prints a message to administration only.
function SEAS:AdminPrint(...)
	for k, v in pairs(player.GetAll()) do
		if (SEAS:PermissionChecks(v, "mod")) then
			SEAS:AddText(v, unpack(...))
		end
	end
end

// Server specific functions.
if SERVER then	
	util.AddNetworkString("SEAS_AddText")
	util.AddNetworkString("SEAS_UserSetPowerLevel")
	util.AddNetworkString("SEAS_PowerLevelSetServer")
	
	// Make sure to set the power level of the user on client.
	net.Receive("SEAS_PowerLevelSetServer", function(len)
		local power = net.ReadInt(16)
		local ply = net.ReadEntity()
		
		ply.SEAS_PowerLevel = power
	end)
	
	// Alows for a serverside chat.AddText.
	// Credits to Overv for how to do this using usermessages: https://gmod.facepunch.com/f/gmoddev/lscb/Serverside-chat-AddText/1/
	function SEAS:AddText(...)
		local arg = {...}
		if (type(arg[1]) == "Player") then ply = arg[1] end
					
		net.Start("SEAS_AddText")
			net.WriteInt(#arg, 16)
			for _, v in pairs(arg) do
				if (type(v) == "string") then
					net.WriteString( v )	
				elseif (type(v) == "table") then
					net.WriteInt(v.r, 16)	
					net.WriteInt(v.g, 16)	
					net.WriteInt(v.b, 16)	
					net.WriteInt(v.a, 16)	
				end
			end
		net.Send(ply)
	end
else
	net.Receive("SEAS_AddText", function()
		local argc = net.ReadInt(16)
		local args = {}
		for i=1, argc/2, 1 do
			table.insert(args, Color( net.ReadInt(16), net.ReadInt(16), net.ReadInt(16), net.ReadInt(16) ))	
			table.insert(args, net.ReadString())
		end
			 		
		chat.AddText(unpack(args))
	end)
end 