util.AddNetworkString("SEAS_CommandHelp")
util.AddNetworkString("SEAS_OpenPunishmentsMenu")
util.AddNetworkString("SEAS_OpenAdminMenu")
util.AddNetworkString("SEAS_SentCommandsToClient")

SEAS.ChatCommands = {}

// You can add commands easily using this function.
// It adds both a concommand and a chat command for you.
// Look at the commands below for an example on how to do it properly. 
// Make sure to make use of config settings when doing so.
function SEAS:AddNewCommand(name, chatcommand, usage, power, func, hasargs, quickcmd) 
	local tbl = SEAS.ChatCommands 
	hasargs = hasargs or false
	quickcmd = quickcmd or false
	table.insert(tbl, {chatcommand, name, usage, power, hasargs, quickcmd})  
	
	concommand.Add(name, func, FCVAR_PROTECTED)
end	

// Suggests commands closest to the given argument.
function SEAS:SuggestedCommands(command, ply)
	// Too short to check..
	if (string.len(command) < 3) then return end
	
	local splitstring = string.Split(command, "")
	local newstring = ""
	local matchedcommands = {}
	for i = 1, 3 do	newstring = newstring ..splitstring[i] end
	
	for k, v in SortedPairsByMemberValue(SEAS.ChatCommands) do
		if (string.StartWith(v[1], newstring) || string.find(v[1], command)) then	
			table.insert(matchedcommands, v)
		end
	end 
	
	if (#matchedcommands > 0) then 
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Suggested commands below: ")
		for k, v in pairs (matchedcommands) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v[3])
		end
	else
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Get a list in your console by typing: ", SEAS.Chat.Target, "help")
	end
end

// Takes arguments and a position to start from.
// Returns a completed string.
function SEAS:ConcatString(args, pos)
	local str = ""
	
	for k, v in pairs (args) do
		if !(k < pos) then
			if (v == "'" || string.EndsWith(str, "'") || str == "") then
				str = str..v
			else
				str = str.." "..v
			end
		end
	end
	
	return str
end

// Checks for any users that start with that name.
// Accepts partials for names too.
function SEAS:MultipleUserCheck(name)
	local tbl = {} 
	for k, v in pairs(player.GetAll()) do
		if (string.StartWith(v:Nick():lower(),name:lower())) then
			table.insert(tbl, v)
		end
	end
	
	local num = #tbl
	if (num > 0) then
		if (num > 1) then
			return tbl
		else
			return tbl[1]:UserID()
		end
		
	end
	return tbl
end

// Helper function for time checking.
// Accepts the string to check and identifier to use.
function SEAS:CheckIdentifier(str, i)
	local value = 0
	local stringsearch = string.sub(str, string.find(str, i) -1, string.find(str, i) -1)
	if (stringsearch == "0" || tonumber(string.sub(str, string.find(str, i) -2, string.find(str, i) -2)) == 0) then
		local append = "0"
		
		if (tonumber(string.sub(str, string.find(str, i) -2, string.find(str, i) -2))) then
			append = string.sub(str, string.find(str, i) -2, string.find(str, i) -2) ..stringsearch
			if (append == "00") then
				return "Can't use 0 for time identifier. Either enter a higher value or use 0 without identifiers for permanent."
			else 
				value = tonumber(append)
			end
		else
			return "Can't use 0 for time identifier. Either enter a higher value or use 0 without identifiers for permanent."
		end
	else
		value = tonumber(stringsearch)
	end
	
	if (!value) then
		return "Arguments provided were invalid. Make sure you use the correct format.\nFormat(h(Hours) d(Days) w(Weeks) m(Months) y(Years))"
	end
	
	print("Type for identifier check: "..type(value))
	return value
end

// Checks for multiple time specifiers
// Accepts hours, days, weeks, months and years.
function SEAS:TimeCheck(str)

	local hoursfound = 0
	local daysfound = 0
	local weeksfound = 0
	local monthsfound = 0
	local yearsfound = 0
	local timevalues = {["h"] = 3600, ["d"] = 86400, ["w"] = 604800, ["m"] = 2628000, ["y"] = 31536000}
	local value = 0
	
	// Years
	if (string.find(str, "y")) then
		if (type(SEAS:CheckIdentifier(str, "y")) == "number") then
			yearsfound = SEAS:CheckIdentifier(str, "y")
		else
			return SEAS:CheckIdentifier(str, "y")
		end
	end
	
	// Months
	if (string.find(str, "m")) then
		if (type(SEAS:CheckIdentifier(str, "m")) == "number") then
			monthsfound = SEAS:CheckIdentifier(str, "m")
		else
			return SEAS:CheckIdentifier(str, "m")
		end
	end
	
	// Weeks
	if (string.find(str, "w")) then
		if (type(SEAS:CheckIdentifier(str, "w")) == "number") then
			weeksfound = SEAS:CheckIdentifier(str, "w")
		else
			return SEAS:CheckIdentifier(str, "w")
		end
	end
	
	// Days
	if (string.find(str, "d")) then
		if (type(SEAS:CheckIdentifier(str, "d")) == "number") then
			daysfound = SEAS:CheckIdentifier(str, "d")
		else
			return SEAS:CheckIdentifier(str, "d")
		end
		
	end
	
	// Hours
	if (string.find(str, "h")) then
		if (type(SEAS:CheckIdentifier(str, "h")) == "number") then
			hoursfound = SEAS:CheckIdentifier(str, "h")
		else
			return SEAS:CheckIdentifier(str, "h")
		end
	end
	
	// Add all the values together.
	value = value + (timevalues["y"] * yearsfound) + (timevalues["m"] * monthsfound) +
		(timevalues["w"] * weeksfound) + (timevalues["d"] * daysfound) + 
			(timevalues["h"] * hoursfound)
	
	// Return either false or a time if we don't find any relevant chars.
	if (value == 0) then
		// If it can be converted to a number we can return a proper value.
		// Otherwise, we return false and the command should handle and return a message.
		if (tonumber(str)) then
			value = tonumber(str) * 60 // Return minutes as that's the default chatcommand time.
		else
			value = false
		end
	end
	
	return value
end

// Checks for admin immunity
// Returns true or false
function SEAS:CheckImmunity(ply, target)
	local plypower = SEAS:ConvertToPowerlevel(ply:GetUserGroup())
	local targetpower = SEAS:ConvertToPowerlevel(target:GetUserGroup())
	
	// They can target themselves if they wish.
	if (ply:Nick() == target:Nick()) then
		return false
	end
	
	// Owners can't be touched.
	if (targetpower == SEAS.MISC.OwnerPowerLevel) then
		return true
	end
	
	// Same ranked individuals cannot target each other.
	if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) <= SEAS:ConvertToPowerlevel(target:GetUserGroup())) then
		return true
	end
	
	return false
end

// Splits the string into command and args if applicable.
function SEAS:ProcessCommand(ply, cmd)
	local trimText = string.Trim(cmd)
	local afterPrefix = string.sub(trimText, 2)
	local found = false
	local args = string.Explode(" ", afterPrefix)
	local command = args[1]
	
	table.remove(args, 1)
	for k, v in SortedPairsByMemberValue(SEAS.ChatCommands) do
		if (v[1] == string.lower(command)) then
			found = true
			local cmdArgs = ""
			for k2, v2 in pairs(args) do
				if (k2 > 1) then
					cmdArgs = cmdArgs..v2.." "
				else
					cmdArgs = cmdArgs .." "..v2.." "
				end
			end
					
			if (cmdArgs) then
				ply:ConCommand(v[2]..cmdArgs)
			else
				ply:ConCommand(v[2])
			end
			break
		end
	end
	
	if (!found) then
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Unknown chat command: ", Color(0, 255, 0, 255), command)
		if (SEAS.Chat.SuggestCommands) then
			SEAS:SuggestedCommands(command, ply)
		end
		return ""
	end
	
	return cmd
end

// Checks for a prefix
function SEAS:CheckForPrefix(prefix)
	if (SEAS.Chat.Prefix == "! or /") then
		if (prefix == "/" || prefix == "!") then  
			return true
		end
	elseif (prefix == SEAS.Chat.Prefix) then
		return true
	end
	
	return false
end

// This is where it checks for any chat commands
function SEAS:CheckChatCommands(ply, cmd, teamchat)
	local prefix = string.sub(cmd, 1, 1)
	if (SEAS:CheckForPrefix(prefix)) then
		SEAS:ProcessCommand(ply, cmd)
	end
end

-- Moderator commands --

// Help command.
SEAS:AddNewCommand("seas_help", "help", "help: - Provides help!", "mod", function(ply, cmd, args) 
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return 
	end
	
	if (SEAS.MISC.PrintInConsole) then
		ply:SendLua("SEAS:PrintHelp()")
	else
		ply:SendLua("SEAS:DrawAdminHelpMenu()")
	end
		
end)

// Logs command
SEAS:AddNewCommand("seas_logs", "logs", "logs: - Opens the logs for viewing.", "mod", function(ply, cmd, args)
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	ply:SendLua("SEAS:ShowLogs()")
end)

// Toggles freeze on the player.
SEAS:AddNewCommand("seas_freeze", "freeze", "freeze: <targetname> - Toggles freeze on the target player.", "mod", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	if (type(args[1] == "string")) then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage(ply, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot punish a staff member equivalent to or higher than you.")
		end
		if (Player(args[1]):IsFrozen()) then
			Player(args[1]):Freeze(false)
			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has UNFROZEN " ..Player(args[1]):Nick()})
			SEAS:Log("[ADMIN CMD] Admin ("..ply:SteamID()..") "..ply:Nick().." UNFROZE ("..Player(args[1]):SteamID()..") "..Player(args[1]):Nick()..".", "ADMIN CMD")
		else
			Player(args[1]):Freeze(true)
			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has FROZEN " ..Player(args[1]):Nick()})
			SEAS:Log("[ADMIN CMD] Admin ("..ply:SteamID()..") "..ply:Nick().." FROZE ("..Player(args[1]):SteamID()..") "..Player(args[1]):Nick()..".", "ADMIN CMD")
		end
	end
end, false, true)


// Slay command
SEAS:AddNewCommand("seas_slay", "slay", "slay: <targetname> - Slays specified player. ", "mod", function(ply, cmd, args) 
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	if (type(args[1]) == "string") then  
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage(ply, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		Player(args[1]):Kill()
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has SLAIN " .. Player(args[1]):Nick().."."})
		SEAS:Log("[ADMIN CMD] Admin ("..ply:SteamID()..") "..ply:Nick().." SLAYED ("..Player(args[1]):SteamID()..") "..Player(args[1]):Nick()..".", "ADMIN CMD")
	end
	
end, false, true)

// Kick command.
SEAS:AddNewCommand("seas_kick", "kick", "kick: <targetname> <reason:optional> - Kick's the specified player.", "mod", function(ply, cmd, args)

	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	local reason = ""
	
	if (args[2]) then
		reason = SEAS:ConcatString(args, 2)
	else
		reason = SEAS.Punishments.DefaultReason
	end
	
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		Player(args[1]):Kick(reason)
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has KICKED " .. Player(args[1]):Nick().." with reason: " .. reason})
		SEAS:Log("[ADMIN CMD] Admin ("..ply:SteamID()..") "..ply:Nick().." KICKED ("..Player(args[1]):SteamID()..") "..Player(args[1]):Nick().." with reason: "..reason, "ADMIN CMD")
	end
end, true)

// Ban command 
SEAS:AddNewCommand("seas_ban", "ban", "ban: <targetname> <duration:mins> <reason:optional> - Bans the player for specified minutes.", "mod", function(ply, cmd, args)
	local limits = 0 // 0 = PERMANENT.
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
		
	// Compares limited power.
	if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
		if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) == SEAS.MISC.AdminPowerLevel) then
			limits = SEAS.Punishments.MaxAdminLength
		else
			limits = SEAS.Punishments.MaxModLength
		end
	end	

	// Need a target.
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player.")
	end
	
	// If no time is provided, a default time is applied.
	if (!args[2]) then
		args[2] = SEAS.Punishments.DefaultTime * 60
	end
	
	// If no reason is provided, a default reason is applied.
	if (args[3]) then
		args[3] = SEAS:ConcatString(args, 3)
	else
		args[3] = SEAS.Punishments.DefaultReason
	end
	
	// Need to ensure you're providing a number..
	if (type(args[2]) == "string") then
		args[2] = SEAS:TimeCheck(args[2])
	end
	
	// If it's a string again then there was an error.
	if (type(args[2]) == "string") then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, args[2])
	end
	
	// Check for multiple users and return multiple users if there are.
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	// If there's multiple users or no users found then return.
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		// Multiple users.
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	// Can't let them punish longer than their limits.
	if (limits > 0) then
		if (args[2] > limits) then
			args[2] = limits * 60
			SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Your time has been changed to " ..tostring(limits))
		end
	end
	
	
	// Let's allow the staff to provide minutes easily.
	if (args[2] == 0 || args[2] > 315576000 ) then
		args[2] = 315576000
	else
		args[2] = args[2]
	end
	
	// Check the database is connected.
	local status = SEAS.DB:status()
	
	// If it is then commence with banning.
	if (status == 0) then
		if (player.GetByID(args[1])) then
			if (SEAS:CheckImmunity(ply, Player(args[1]))) then
				return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
			end
			local vic = Player(args[1])
			local dur = os.time() + args[2]
			local reason = args[3]
			SEAS:Query([[INSERT INTO seas_punishments(steamid, name, type, duration, admin, reason, adminsteamid) 
			VALUES("]]..vic:SteamID()..[[", "]]..vic:Nick()..[[", "BAN", ]]..dur..[[, "]]..ply:Nick()..[[", "]]..reason..[[", "]]..ply:SteamID()..[[")]])
			
			if (dur >= 315360000 + os.time()) then
				dur = "PERMANENT"
			else
				dur = SEAS:ConvertTimestamp(dur - os.time())
			end
			
			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has BANNED " .. Player(args[1]):Nick().." with reason: " ..args[3]..".\nThe duration is: " ..dur})
			Player(args[1]):Kick("You have been banned.\nReason: " ..reason.."\nThe duration is: " ..dur)
			SEAS:Log("[ADMIN CMD] - Admin "..ply:Nick().." BANNED "..Player(args[1]):Nick().." with reason '"..reason.."'. Duration: "..dur, "ADMIN CMD")
		end
	else
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No connection to database. \nPlease contact the owner if issue persists.")
		SEAS:Log("[DB ERROR] - Database connection error. Code: " ..status, "ERROR")
	end
	
end)

// Mute command
SEAS:AddNewCommand("seas_mute", "mute", "mute: <targetname> <duration:mins> <reason:optional> - Mutes the player for specified minutes.", "mod", function(ply, cmd, args)
	
	local limits = 0 // 0 = PERMANENT.
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
		
	// Compares limited power.
	if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
		if (ply:SEAS_GetPowerLevel() == SEAS.MISC.AdminPowerLevel) then
			limits = SEAS.Punishments.MaxAdminLength
		else
			limits = SEAS.Punishments.MaxModLength
		end
	end	

	// Need a target.
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player.")
	end
	
	// If no time is provided, a default time is applied.
	if (!args[2]) then
		args[2] = SEAS.Punishments.DefaultTime * 60
	end
	
	// If no reason is provided, a default reason is applied.
	if (args[3]) then
		args[3] = SEAS:ConcatString(args, 3)
	else
		args[3] = SEAS.Punishments.DefaultReason
	end
	
	// Need to ensure you're providing a number..
	if (type(args[2]) == "string") then
		args[2] = SEAS:TimeCheck(args[2])
	end
	
	// If it's a string again then there was an error.
	if (type(args[2]) == "string") then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, args[2])
	end
	
	// Check for multiple users and return multiple users if there are.
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	// If there's multiple users or no users found then return.
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		// Multiple users.
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	// Can't let them punish longer than their limits.
	if (limits > 0) then
		if (args[2] > limits) then
			args[2] = limits * 60
			SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Your time has been changed to " ..tostring(limits))
		end
	end
	
	
	// Let's allow the staff to provide minutes easily.
	if (args[2] == 0 || args[2] > 315576000 ) then
		args[2] = 315576000
	else
		args[2] = args[2]
	end
	
	// Check the database is connected.
	local status = SEAS.DB:status()
	
	// If it is then commence with muting.
	if (status == 0) then
		if (player.GetByID(args[1])) then
			if (SEAS:CheckImmunity(ply, Player(args[1]))) then
				return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
			end
			local vic = Player(args[1])
			local dur = os.time() + args[2]
			local reason = args[3]
			SEAS:Query([[INSERT INTO seas_punishments(steamid, name, type, duration, admin, reason, adminsteamid) 
			VALUES("]]..vic:SteamID()..[[", "]]..vic:Nick()..[[", "MUTE", ]]..dur..[[, "]]..ply:Nick()..[[", "]]..reason..[[", "]]..ply:SteamID()..[[")]])
			
			if (dur >= 315360000 + os.time()) then
				dur = "PERMANENT"
			else
				dur = SEAS:ConvertTimestamp(dur - os.time())
			end
			
			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has MUTED " .. Player(args[1]):Nick().." with reason: " ..args[3]..".\nThe duration is: " ..dur})
			Player(args[1]):SEAS_Mute()
			SEAS:Log("[ADMIN CMD] - Admin "..ply:Nick().." MUTED "..Player(args[1]):Nick().." with reason '"..reason.."'. Duration: "..dur, "ADMIN CMD")
		end
	else
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No connection to database. \nPlease contact the owner if issue persists.")
		SEAS:Log("[DB ERROR] - Database connection error. Code: " ..status, "ERROR")
	end
	
end)

// Voicemute command
SEAS:AddNewCommand("seas_voicemute", "vmute", "vmute: <targetname> <duration:mins> <reason:optional> - Voicemutes the player for specified minutes.", "mod", function(ply, cmd, args)

		local limits = 0 // 0 = PERMANENT.
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
		
	// Compares limited power.
	if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
		if (ply:SEAS_GetPowerLevel() == SEAS.MISC.AdminPowerLevel) then
			limits = SEAS.Punishments.MaxAdminLength
		else
			limits = SEAS.Punishments.MaxModLength
		end
	end	

	// Need a target.
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player.")
	end
	
	// If no time is provided, a default time is applied.
	if (!args[2]) then
		args[2] = SEAS.Punishments.DefaultTime * 60
	end
	
	// If no reason is provided, a default reason is applied.
	if (args[3]) then
		args[3] = SEAS:ConcatString(args, 3)
	else
		args[3] = SEAS.Punishments.DefaultReason
	end
	
	// Need to ensure you're providing a number..
	if (type(args[2]) == "string") then
		args[2] = SEAS:TimeCheck(args[2])
	end
	
	// If it's a string again then there was an error.
	if (type(args[2]) == "string") then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, args[2])
	end
	
	// Check for multiple users and return multiple users if there are.
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	// If there's multiple users or no users found then return.
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		// Multiple users.
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	// Can't let them punish longer than their limits.
	if (limits > 0) then
		if (args[2] > limits) then
			args[2] = limits * 60
			SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Your time has been changed to " ..tostring(limits))
		end
	end
	
	
	// Let's allow the staff to provide minutes easily.
	if (args[2] == 0 || args[2] > 315576000 ) then
		args[2] = 315576000
	else
		args[2] = args[2]
	end
	
	// Check the database is connected.
	local status = SEAS.DB:status()
	
	// If it is then commence with voicemuting.
	if (status == 0) then
		if (player.GetByID(args[1])) then
			if (SEAS:CheckImmunity(ply, Player(args[1]))) then
				return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
			end
			local vic = Player(args[1])
			local dur = os.time() + args[2]
			local reason = args[3]
			SEAS:Query([[INSERT INTO seas_punishments(steamid, name, type, duration, admin, reason, adminsteamid) 
			VALUES("]]..vic:SteamID()..[[", "]]..vic:Nick()..[[", "VOICEMUTE", ]]..dur..[[, "]]..ply:Nick()..[[", "]]..reason..[[", "]]..ply:SteamID()..[[")]])
			
			if (dur >= 315360000 + os.time()) then
				dur = "PERMANENT"
			else
				dur = SEAS:ConvertTimestamp(dur - os.time())
			end
			
			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has VOICEMUTED " .. Player(args[1]):Nick().." with reason: " ..args[3]..".\nThe duration is: " ..dur})
			Player(args[1]):SEAS_Voicemute()
			SEAS:Log("[ADMIN CMD] - Admin "..ply:Nick().." VOICEMUTED "..Player(args[1]):Nick().." with reason '"..reason.."'. Duration: "..dur, "ADMIN CMD")
		end
	else
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No connection to database. \nPlease contact the owner if issue persists.")
		SEAS:Log("[DB ERROR] - Database connection error. Code: " ..status, "ERROR")
	end
	
end)

// Main admin menu.
SEAS:AddNewCommand("seas_admin", "admin", "admin: - Opens up the admin menu.", "mod", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	net.Start("SEAS_OpenAdminMenu")
		net.WriteEntity(ply)
	net.Send(ply)
end)

// Punishments admin menu.
SEAS:AddNewCommand("seas_punishments", "punishments", "punishments: - Opens up the punishments menu.", "mod", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	net.Start("SEAS_OpenPunishmentsMenu")
		net.WriteEntity(ply)
	net.Send(ply)
end)

// Warns the target player.
SEAS:AddNewCommand("seas_warn", "warn", "warn: <playername> <message> - Warns the target player.", "mod", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "mod")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You need to provide a player.")
	end

	
	if (!args[2]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You need to provide a message.")
	end
	
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	// Let's concat the reason.
	args[2] = SEAS:ConcatString(args, 2)
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		Player(args[1]):SendLua([[SEAS:ErrorMsg("Warning from ]]..ply:Nick()..[[: ]]..args[2]..[[", "warn")]])
		SEAS:Log("[ADMIN CMD] Admin ("..ply:SteamID()..") "..ply:Nick().." WARNED ("..Player(args[1]):SteamID()..") "..Player(args[1]):Nick()..". Warning: "..args[2], "ADMIN CMD")
	end

	
end)

-- End of Moderator commands --

-- Admin Commands --

// Goto command.
SEAS:AddNewCommand("seas_goto", "goto", "goto: <targetname> - Goes to specified player.", "admin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "admin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	if (type(args[1] == "string")) then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage("Multiple users found: ", ply)
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	local oldpos = ply:GetPos()
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
	
		ply:SetPos(Player(args[1]):GetPos() + Vector(0, 40, 0))
		if (!ply:IsOnGround()) then
			ply:SetPos(oldpos)
			return SEAS:ShowAdminMessage(ply, "Position was not valid to teleport to. ")
		end
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has TELEPORTED to " .. Player(args[1]):Nick().."'s position."})
	end
end, false, true)

// Bring command
SEAS:AddNewCommand("seas_bring", "bring", "bring: <targetname> - Brings specified player.", "admin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "admin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	if (type(args[1] == "string")) then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage("Multiple users found: ", ply)
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		
		local oldpos = Player(args[1]):GetPos()
		Player(args[1]):SetPos(ply:GetPos() + Vector(0, 40, 0))
		if (!ply:IsOnGround()) then
			Player(args[1]):SetPos(oldpos)
			return SEAS:ShowAdminMessage(ply, "Position was not valid to teleport to. ")
		end
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has BROUGHT " .. Player(args[1]):Nick().." to their position."})
	end
end, false, true)

// Unspectate command
SEAS:AddNewCommand("seas_unspec", "unspectate", "unspectate: - Unspectates if you're spectating someone.", "admin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "admin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (ply:GetObserverTarget() == NULL) then
		return SEAS:ShowAdminMessage(ply, "You are not spectating anyone right now.")
	end
	
	SEAS:ShowAdminMessage(ply, "You have stopped spectating: " ..ply:GetObserverTarget():Nick())
	ply:UnSpectate()
	
end, false, true)

// Spectate command
SEAS:AddNewCommand("seas_spec", "spectate", "spectate: <targetname> - Spectates a player", "admin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "admin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player name.")
	end
	
	if (args[1] == ply:Nick()) then	
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot spectate yourself..")
	end
	
	if (type(args[1] == "string")) then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage(ply, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		ply:SpectateEntity(Player(args[1]))
		ply:SetObserverMode(OBS_MODE_IN_EYE)
		SEAS:ShowAdminMessage(ply, "You have begun spectating " ..Player(args[1]):Nick())
		
		if (SEAS.Chat.Prefix == "! or /") then
			SEAS:ShowAdminMessage(ply, "Type !unspectate or /unspectate to stop spectating.")
		else
			SEAS:ShowAdminMessage(ply, "Type "..SEAS.Chat.Prefix.."unspectate to stop spectating.")
		end
	end
end, false, true)

// Restarts the current map.
SEAS:AddNewCommand("seas_restart", "restartmap", "restartmap: - Restarts the current map.", "admin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "admin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has restarted the map.\n The map will restart in: " ..SEAS.MISC.RestartmapDelay.. " seconds."})
	
	timer.Simple(SEAS.MISC.RestartmapDelay, function()
		RunConsoleCommand("changelevel", game.GetMap())
	end)
end)

-- End of Admin commands --
 
// Change map command.
SEAS:AddNewCommand("seas_map", "map", "map: <mapname> - Changes to the specified map.", "superadmin", function(ply, cmd, args) 
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "superadmin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must supply a map to change to.")
	end
	
	// Need to get all the maps..
	local maplist = file.Find("maps/*.bsp", "GAME")
	
	local mapfound = false 
	for k, v in pairs(maplist) do
		if (v == args[1]..".bsp") then
			mapfound = true 
			break
		end
	end
	
	if (mapfound) then
		local str = "second"
		local delay = SEAS.MISC.ChangemapDelay
		if (delay > 1) then
			str = str.."s"
		end
		
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Admin " ..ply:Nick() .. " has changed the map to " .. args[1].."."})
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "The map will change in ", Color(255, 2, 2, 255), tostring(delay), Color(255, 255, 255, 255), " "..str.."."})
		timer.Simple(delay, function()
			RunConsoleCommand("changelevel", args[1])
		end)
	else
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Could not find map: " ..args[1]..".bsp")
	end
end, true)

// Toggles god mode on yourself or a target.
SEAS:AddNewCommand("seas_god", "god", "god: <targetname:optional> - Toggles god mode on yourself or a target.", "superadmin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "superadmin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (#args < 1) then
		if (!ply:Alive()) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot toggle god when you are dead!")
		end
		if (ply:HasGodMode()) then
			ply:GodDisable()
			return SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has DISABLED GODMODE on themselves!"})
		else
			ply:GodEnable()
			return SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has ENABLED GODMODE on themselves!"})
		end
	end 
	
	if (type(args[1] == "string")) then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage(ply, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		if (!Player(args[1]):Alive()) then 
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot toggle god on a dead plyer.")
		end
		
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		
		if (Player(args[1]):HasGodMode()) then
			Player(args[1]):GodDisable()
			return SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has DISABLED GODMODE on " ..Player(args[1]):Nick()})
		else
			Player(args[1]):GodEnable()
			return SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().." has ENABLED GODMODE on " ..Player(args[1]):Nick()})
		end
	end
end, false, true)

// Give weapon
SEAS:AddNewCommand("seas_give", "give", "give: <player> <weapon> - Gives the player a weapon.", "superadmin", function(ply, cmd, args)
	
	// Check permissions.
	if (!SEAS:PermissionChecks(ply, "superadmin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a player.")
	end
	
	if (!args[2]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a weapon to give.")
	end
	
	// Check for multiple targets.
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:ShowAdminMessage(ply, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	if (player.GetByID(args[1])) then
		Player(args[1]):Give(args[2])
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().. " has given " ..Player(args[1]):Nick().. " a " ..args[2].."."})
	end
end)

// Check DB
SEAS:AddNewCommand("seas_checkdb", "checkdb", "checkdb: - Checks DB connection.", "superadmin", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "superadmin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	 
	if (!SEAS.MISC.UseSQL) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "SQL is currently set to false.")
	end
	
	local status = SEAS.DB:status()
	
	if (status == 0) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "The database is connected.")
	else 
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "The database is not connected. Error number: " ..status
		.."\nPlease refer to MySQLOO error messages at: https://github.com/FredyH/MySQLOO")
	end
		
end)

// Rcon command
SEAS:AddNewCommand("seas_rcon", "rcon", "rcon: - Runs a console command.", "superadmin", function(ply, cmd, args)

	local blacklistedcommands = 
	{
		"retry",
		"map",
		"sv_password"
	}
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "superadmin")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!args[1]) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You must provide a command to execute!")
	end
	
	// Cannot allow blacklisted commands for a reason..
	if (table.HasValue(blacklistedcommands, args[1])) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "The command '"..args[1].."' is a blacklisted command.")
	end
	
	local numargs = 0
	local processargs = "" 
	
	if (#args > 1) then
		RunConsoleCommand(args[1], args[2])
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().. " has run the console command " ..args[1].. " with argument: " ..args[2].."."})
	else
		RunConsoleCommand(args[1])
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick().. " has run the console command " ..args[1].. "."})
	end
		
end)
-- End of Superadmin commands -

-- Owner Commands --

// Remove a user's rank.
SEAS:AddNewCommand("seas_removerank", "removerank", "removerank: <targetname> - Removes a players rank.", "owner", function(ply, cmd, args)

	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "owner")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!SEAS.MISC.UseSQL) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "This feature requires the use of SQL!")
	end
	
	if (!args) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You need to provide a player.")
	end
	
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	local status = SEAS.DB:status()
	if (status == 0) then	
		
		if (player.GetByID(args[1])) then
			if (SEAS:CheckImmunity(ply, Player(args[1]))) then
				return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
			end

			SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has REMOVED " .. Player(args[1]):Nick().."'s rank."})
			SEAS:Query([[DELETE FROM seas_admin_ranks WHERE steamid = "]]..Player(args[1]):SteamID()..[["]])
			
			Player(args[1]):SetUserGroup("user")
		end
	end
end, false, true)

// Set a user to a rank.
SEAS:AddNewCommand("seas_setrank", "setrank", "setrank: <targetname> <rank> - Sets a players rank.", "owner", function(ply, cmd, args)
	
	// Check for permissions.
	if (!SEAS:PermissionChecks(ply, "owner")) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, SEAS.Chat.PermissionMessage)
	end
	
	if (!SEAS.MISC.UseSQL) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "This feature requires the use of SQL!")
	end
	
	if (!args) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You need to provide a player.")
	elseif (#args < 2) then
		return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Please provide a rank.")
	end
	
	if (type(args[1]) == "string") then
		args[1] = SEAS:MultipleUserCheck(args[1])
	end
	
	if (type(args[1]) == "table") then
		if (#args[1] < 1) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "No users were found.")
		end
		
		SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Multiple users found: ")
		for k, v in pairs (args[1]) do
			SEAS:AddText(ply, Color(0, 255, 0, 255), v:Nick())
		end
		return
	end
	
	local status = SEAS.DB:status()
	if (status == 0 && player.GetByID(args[1])) then	
	
		if (SEAS:CheckImmunity(ply, Player(args[1]))) then
			return SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "You cannot manage a staff member equivalent to or higher than you.")
		end
		
		SEAS:Query([[INSERT INTO seas_admin_ranks(name, rank, steamid) 
			VALUES("]]..Player(args[1]):Nick()..[[", "]]..args[2]..[[", "]]..Player(args[1]):SteamID()..[[")]])
			
		SEAS:PrintAll({SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, ply:Nick() .. " has set " .. Player(args[1]):Nick().."'s rank to " ..string.upper(args[2])})
			
		Player(args[1]):SetUserGroup(args[2])
	end
end)

-- End of Owner commands --

// Hooks and netmessages at the bottom

// Checks chat commands and mutes also.
// Also checks for admin communication.
hook.Add("PlayerSay", "SEAS_AdminChatAndMuteCheck", function(ply, cmd, teamchat)
	local prefix = string.sub(cmd, 1, 1)
	
	if (prefix == SEAS.Chat.AdminChatPrefix) then
		if (SEAS:PermissionChecks(ply, "mod")) then
			for k, v in pairs(player.GetAll()) do
				if (SEAS:PermissionChecks(v, "mod")) then
					SEAS:AddText(v, SEAS.Chat.AdminMsgCol, "[ADMIN] ", team.GetColor(ply:Team()), ply:Nick()..": ", SEAS.Chat.Target, string.sub(cmd, 2))
				end
			end
			return ""
		end
	end
	
	if (SEAS:PermissionChecks(ply, "mod")) then
		if (SEAS.Chat.Prefix == "! or /") then
			if (prefix == "/" || prefix == "!") then  
				SEAS:CheckChatCommands(ply, cmd, teamchat)
				return ""
			end
		elseif (prefix == SEAS.Chat.Prefix) then
			SEAS:CheckChatCommands(ply, cmd, teamchat)
			return ""
		end
	end
	
	if (ply:SEAS_IsMuted()) then
		SEAS:AddText(ply, SEAS.Chat.PunishCol, "You cannot talk when muted.")
		return ""
	end
end)

hook.Add("PlayerInitialSpawn", "SEAS_SendCommandsToClient", function(ply)
	net.Start("SEAS_SentCommandsToClient")
		net.WriteTable(SEAS.ChatCommands)
	net.Send(ply)
end)

hook.Add("PlayerNoClip", "SEAS_AdminNoclip", function(ply)
	if (SEAS:PermissionChecks(ply, "mod")) then
		return true
	end
	
	return false
end)

// Allows the picking up of players with the physgun.
function SEAS:PickupPlayer(ply, target)
	if (SEAS:PermissionChecks(ply, "mod") and target:GetClass():lower() == "player") then
		if (!SEAS:CheckImmunity(ply, target)) then
			return true
		else
			return false
		end
	end
end
hook.Add("PhysgunPickup", "SEAS_PickupPlayer", function(ply, ent)
	return SEAS:PickupPlayer(ply, ent)
end)
