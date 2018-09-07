SEAS.Scale = math.Clamp(ScrH() / 1080, 0.6, 1) // Scales for lower resolutions.

SEAS.LocalCommands = SEAS.LocalCommands or {}

SEAS.CommandHelp = SEAS.CommandHelp or {  
	["owner"] = {},
	["superadmin"] = {},
	["admin"] = {},
	["mod"] = {},
}

surface.CreateFont("SEASFont18", {
	font = "Roboto Lt",
	size = 18 * SEAS.Scale,
	weight = 100, 
})


// Adds to the helpful command.
function SEAS:AddCommandHelp()
	for k, v in SortedPairsByMemberValue(SEAS.LocalCommands) do
		if (v[4] == "owner") then
			table.insert(SEAS.CommandHelp["owner"], v[3])
		elseif (v[4] == "superadmin") then
			table.insert(SEAS.CommandHelp["superadmin"], v[3])
		elseif (v[4] == "admin") then 
			table.insert(SEAS.CommandHelp["admin"], v[3])
		elseif (v[4] == "mod") then
			table.insert(SEAS.CommandHelp["mod"], v[3])
		end
	end
end

// Converts the string and compares prop rank check.
// If you do any custom groups that use permissions
// then add something like if (user:IsUserGroup("rank"))
function SEAS:CheckUserRank(rank, user)
	if (type(rank) != "string") then
		return false
	end
	
	if (rank == "owner") then
		if (user:SEAS_IsOwner()) then
			return true
		else 
			return false 
		end
	end
	
	if (rank == "superadmin") then
		if (user:IsSuperAdmin() || user:SEAS_IsOwner()) then
			return true
		else
			return false
		end
	end
	
	if (rank == "admin") then
		if (user:IsAdmin() || user:SEAS_IsOwner()) then
			return true
		else	
			return false
		end
	end
	
	if (rank == "mod") then
		if (user:SEAS_IsMod()) then
			return true
		else	
			return false
		end
	end
	
	return false
end

// Used for the quick menu to changemap
function SEAS:MapRequest()
	// Frame - Error frame.
	local SEAS_MapFrame = vgui.Create("DFrame")
	SEAS_MapFrame:SetPos(ScrW() / (2.75 * SEAS.Scale), ScrH() / (3 * SEAS.Scale))
	SEAS_MapFrame:SetSize(600 * SEAS.Scale, 150 * SEAS.Scale)
	SEAS_MapFrame:SetSkin("SEAS_Derma")
	SEAS_MapFrame:SetTitle("Change map")
	SEAS_MapFrame:SetIcon("icon16/image.png")
	SEAS_MapFrame:MakePopup(true)
	SEAS_MapFrame:SetBackgroundBlur(true)

	local SEAS_Text = vgui.Create("DLabel", SEAS_MapFrame)
	SEAS_Text:SetTextColor(color_white)
	SEAS_Text:SetText("What map would you like to change to?")
	SEAS_Text:SetFont("SEASFont18")
	SEAS_Text:SetSize(300 * SEAS.Scale, 25)
	SEAS_Text:SetPos(170 * SEAS.Scale, 45 * SEAS.Scale)
	
	local SEAS_Entry = vgui.Create("DTextEntry", SEAS_MapFrame)
	SEAS_Entry:SetSize(400 * SEAS.Scale, 25)
	SEAS_Entry:SetText("")
	SEAS_Entry:SetPos(100 * SEAS.Scale, 75 * SEAS.Scale)
	
	local SEAS_OkButton = vgui.Create("DButton", SEAS_MapFrame)
	SEAS_OkButton:SetSize(50, 25)
	SEAS_OkButton:SetText("Change Map")
	SEAS_OkButton:Dock(BOTTOM)
	SEAS_OkButton.DoClick = function()
		LocalPlayer():ConCommand("seas_map "..SEAS_Entry:GetValue())
		SEAS_MapFrame:Close()
	end
	
end

// Pops up a error window.
function SEAS:ErrorMsg(message, warntype)

	// Just in case it's called unexpectedly.
	if (warntype != "warn" && warntype != "error") then 
		return print("[SEAS] Something went wrong with warning!")
	end
	
	// Length of message
	local lenw, lenh = surface.GetTextSize(message)
	lenw = lenw * 1.2
	
	// Frame - Error frame.
	local SEAS_ErrorFrame = vgui.Create("DFrame")
	SEAS_ErrorFrame:SetPos(ScrW() / (2.75 * SEAS.Scale), ScrH() / (3 * SEAS.Scale))
	SEAS_ErrorFrame:SetSize((lenw + 50) * SEAS.Scale, 150 * SEAS.Scale)
	
	if (warntype == "warn") then
		SEAS_ErrorFrame:SetTitle("Warning!")
		SEAS_ErrorFrame:SetIcon(SEAS.GUI.WarningIcon)
	else
		SEAS_ErrorFrame:SetTitle("Error!")
		SEAS_ErrorFrame:SetIcon(SEAS.GUI.ErrorIcon)
	end
	
	SEAS_ErrorFrame:SetSkin("SEAS_Derma")
	SEAS_ErrorFrame:MakePopup(true)
	SEAS_ErrorFrame:SetBackgroundBlur(true)
	SEAS_ErrorFrame:ShowCloseButton(false)
	
	local SEAS_Text = vgui.Create("DLabel", SEAS_ErrorFrame)
	SEAS_Text:SetTextColor(color_white)
	SEAS_Text:SetText(message)
	SEAS_Text:SetSize(lenw * SEAS.Scale, 25)
	SEAS_Text:SetFont("SEASFont18")
	SEAS_Text:Dock(FILL)
	SEAS_Text:DockMargin(10, 0, 0, 0)
	
	local SEAS_OkButton = vgui.Create("DButton", SEAS_ErrorFrame)
	SEAS_OkButton:SetSize(50, 25)
	SEAS_OkButton:SetText("OK")
	//SEAS_OkButton:SetPos(200 * SEAS.Scale, 150 * SEAS.Scale)
	SEAS_OkButton:Dock(BOTTOM)
	SEAS_OkButton.DoClick = function()
		SEAS_ErrorFrame:Close()
	end
end

// Draws the help menu for the player.
function SEAS:DrawAdminHelpMenu()

	// Frame - Main admin frame.
	local SEAS_AdminFrame = vgui.Create("DFrame")
	SEAS_AdminFrame:SetPos(ScrW() / (2.75 * SEAS.Scale), ScrH() / (3 * SEAS.Scale))
	SEAS_AdminFrame:SetSize(600 * SEAS.Scale, 400 * SEAS.Scale)
	SEAS_AdminFrame:SetTitle("List of available commands to you.")
	SEAS_AdminFrame:SetIcon("icon16/script.png")
	SEAS_AdminFrame:SetSkin("SEAS_Derma")
	SEAS_AdminFrame:MakePopup(true)
	SEAS_AdminFrame:SetBackgroundBlur(true)
	
	// Width and height of main frame for easier building.
	local wid, hei = SEAS_AdminFrame:GetSize()
	
	local power = SEAS:ConvertToPowerlevel(LocalPlayer():GetUserGroup())
	
	// DListView - Player list.
	local SEAS_AdminCommandList = vgui.Create("DListView", SEAS_AdminFrame)
	SEAS_AdminCommandList:Dock(FILL)
	SEAS_AdminCommandList:AddColumn("Command - Description")
	
	// Make sure entries are alphabetical
	local sortedtable = {}
	for k, v in pairs(SEAS.CommandHelp) do
		local rank = SEAS:ConvertToPowerlevel(k)
		if (rank <= power) then
			for k2, v2 in pairs(v) do
				table.insert(sortedtable, v2)
			end
		end
	end
	
	// Sort the table and add the lines.
	table.sort(sortedtable, function(a, b) return a < b end)
	for k, v in pairs(sortedtable) do
		SEAS_AdminCommandList:AddLine(v)
	end
	
end

// Edits a punishments.
function SEAS:DrawEditPunishment(name, steamid, admin, punish, duration, reason)
	
	// Frame - Main admin frame.
	local SEAS_AdminFrame = vgui.Create("DFrame")
	SEAS_AdminFrame:SetPos(ScrW() / (2.75 * SEAS.Scale), ScrH() / (3 * SEAS.Scale))
	SEAS_AdminFrame:SetSize(450 * SEAS.Scale, 200 * SEAS.Scale)
	SEAS_AdminFrame:SetTitle("Editing punishment of: " ..name)
	SEAS_AdminFrame:SetIcon("icon16/pencil.png")
	SEAS_AdminFrame:SetSkin("SEAS_Derma")
	SEAS_AdminFrame:MakePopup(true)
	SEAS_AdminFrame:SetBackgroundBlur(true)
	
	if (!name) then
		name = "Error."
	end
	
	// DLabel - Punishment reason.
	local SEAS_PunishReason = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_PunishReason:SetPos(75 * SEAS.Scale, 75 * SEAS.Scale)
	SEAS_PunishReason:SetText("Reason")
	SEAS_PunishReason:SetTextColor(Color(255, 255, 255, 255))
	SEAS_PunishReason:SetFont("SEASFont18")
	SEAS_PunishReason:SizeToContents()
	
	// DTextEntry - Punishment reason.
	local SEAS_PunishReasonEntry = vgui.Create("DTextEntry", SEAS_AdminFrame)
	SEAS_PunishReasonEntry:SetSize(100, 25)
	SEAS_PunishReasonEntry:SetPos(50 * SEAS.Scale, 100 * SEAS.Scale)
	SEAS_PunishReasonEntry:SetText(reason)
	
	// DLabel - Punishment type.
	local SEAS_PunishType = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_PunishType:SetPos(205 * SEAS.Scale, 75 * SEAS.Scale)
	SEAS_PunishType:SetText("Type")
	SEAS_PunishType:SetTextColor(Color(255, 255, 255, 255))
	SEAS_PunishType:SetFont("SEASFont18")
	SEAS_PunishType:SizeToContents()
	
	// DComboBox  - Punishment type.
	local SEAS_PunishTypeDrop = vgui.Create("DComboBox", SEAS_AdminFrame)
	SEAS_PunishTypeDrop:SetSize(100, 25)
	SEAS_PunishTypeDrop:SetPos(175 * SEAS.Scale, 100 * SEAS.Scale)
	SEAS_PunishTypeDrop:AddChoice("BAN", "BAN", true)
	SEAS_PunishTypeDrop:AddChoice("MUTE", "MUTE")
	SEAS_PunishTypeDrop:AddChoice("VOICEMUTE", "VOICEMUTE")
	
	// DLabel - Punishment type.
	local SEAS_PunishType = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_PunishType:SetPos(325 * SEAS.Scale, 75 * SEAS.Scale)
	SEAS_PunishType:SetText("Time")
	SEAS_PunishType:SetTextColor(Color(255, 255, 255, 255))
	SEAS_PunishType:SetFont("SEASFont18")
	SEAS_PunishType:SizeToContents()
	
	// DComboBox - Punishment time.
	local SEAS_PunishTime = vgui.Create("DComboBox", SEAS_AdminFrame)
	SEAS_PunishTime:SetSize(100, 25)
	SEAS_PunishTime:SetPos(300 * SEAS.Scale, 100 * SEAS.Scale)
	SEAS_PunishTime:SetSortItems(false)
	for k, v in pairs(SEAS.GUI.Durations) do
		SEAS_PunishTime:AddChoice(k, v, true)
	end

	// DButton - Submit edit.
	local SEAS_PunishButton = vgui.Create("DButton", SEAS_AdminFrame)
	SEAS_PunishButton:SetSize(100, 25)
	SEAS_PunishButton:SetFont("SEASFont18")
	SEAS_PunishButton:SetText("Submit")
	SEAS_PunishButton:SetPos(175 * SEAS.Scale, 150 * SEAS.Scale)
	SEAS_PunishButton.DoClick = function()
		local data = {}
		
		data["name"] = name
		data["steamid"] = steamid
		data["admin"] = LocalPlayer():Nick()
		data["type"] = select(2, SEAS_PunishTypeDrop:GetSelected())
		data["duration"] = select(2, SEAS_PunishTime:GetSelected())
		data["reason"] = SEAS_PunishReasonEntry:GetValue()
		data["oldtype"] = punish
		
		net.Start("SEAS_ClientEditQuery")
			net.WriteTable(data)
			net.WriteEntity(LocalPlayer())
		net.SendToServer()
		
		SEAS_AdminFrame:Close()
	end
	
end

// Draws the punishments menu for specified player.
function SEAS:DrawPunishmentsMenu(ply)
	local tbl = {}
	if (SEAS.MISC.UseSQL) then	
		net.Start("SEAS_RequestPunishments")
		net.SendToServer()
		
		net.Receive("SEAS_SentPunishments", function()
			local data = net.ReadTable()
			for k, v in SortedPairsByMemberValue(data) do
				table.insert(tbl, v)
			end
		end)
	end
	
	// Wait for the data.
	timer.Simple(1, function()
		// Frame - Main admin frame.
		local SEAS_AdminFrame = vgui.Create("DFrame")
		SEAS_AdminFrame:SetPos(ScrW() / (4 * SEAS.Scale), ScrH() / (4 * SEAS.Scale))
		SEAS_AdminFrame:SetSize(900 * SEAS.Scale, 600 * SEAS.Scale)
		SEAS_AdminFrame:SetTitle("Punishments")
		SEAS_AdminFrame:SetIcon("icon16/table.png")
		SEAS_AdminFrame:SetSkin("SEAS_Derma")
		SEAS_AdminFrame:MakePopup(true)
		SEAS_AdminFrame:SetBackgroundBlur(true)
		
		// DListView - Punishments list.
		local SEAS_PunishList = vgui.Create("DListView", SEAS_AdminFrame)
		SEAS_PunishList:SetSize(890 * SEAS.Scale, 500 * SEAS.Scale)
		SEAS_PunishList:SetPos(5, 30)
		SEAS_PunishList:AddColumn("Player")
		SEAS_PunishList:AddColumn("SteamID")	
		SEAS_PunishList:AddColumn("Issued By")
		SEAS_PunishList:AddColumn("Type")	
		SEAS_PunishList:AddColumn("Duration")
		SEAS_PunishList:AddColumn("Reason")
		SEAS_PunishList:AddColumn("Admin SteamID")
		for k, v in SortedPairsByMemberValue(tbl) do
			SEAS_PunishList:AddLine(v["name"], v["steamid"], v["admin"], v["type"], SEAS:ConvertTimestamp(v["duration"] - os.time()), v["reason"], v["adminsteamid"])
		end
		SEAS_PunishList.OnRowSelected = function(pnl, index, row)
			local tbl = {}
			
			// Let's prepare the data to send through to the function.
			for i = 1, 7 do
				table.insert(tbl, row:GetValue(i))
			end
			
			local dmenu = DermaMenu()
			dmenu:Open()
			
			dmenu:AddOption("Edit", function() 
				if (!SEAS.Punishments.CanEditAny && LocalPlayer():SteamID() != tbl[7]) then
					if (SEAS:ConvertToPowerlevel(LocalPlayer():GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
						SEAS:ErrorMsg(SEAS.GUI.InsufficientPermissions, "error")
					else
						SEAS:DrawEditPunishment(tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6])
					end
				else
					SEAS:DrawEditPunishment(tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6])
				end
			end):SetImage("icon16/application_form_edit.png")
			
			dmenu:AddOption("Remove", function() 
				if (!SEAS.Punishments.CanEditAny && LocalPlayer():SteamID() != tbl[7]) then
					if (SEAS:ConvertToPowerlevel(LocalPlayer():GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
						SEAS:ErrorMsg(SEAS.GUI.InsufficientPermissions, "error")
					else
						net.Start("SEAS_ClientRemoveQuery") 
							net.WriteTable(tbl)
							net.WriteEntity(ply)
						net.SendToServer()
					end
				else
					net.Start("SEAS_ClientRemoveQuery") 
						net.WriteTable(tbl)
						net.WriteEntity(ply)
					net.SendToServer()
				end
			end):SetImage("icon16/application_form_delete.png")
		end
		
		// DLabel - Add punishment text.
		local SEAS_AddPunishText = vgui.Create("DLabel", SEAS_AdminFrame)
		SEAS_AddPunishText:SetSize(200 * SEAS.Scale, 25 * SEAS.Scale)
		SEAS_AddPunishText:SetPos(10 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishText:SetText("Add punishment:")
		SEAS_AddPunishText:SetTextColor(Color(255, 255, 255, 255))
		SEAS_AddPunishText:SetFont("SEASFont18")
		
		// DTextEntry - Punishment name.
		local SEAS_AddPunishName = vgui.Create("DTextEntry", SEAS_AdminFrame)
		SEAS_AddPunishName:SetSize(100, 25)
		SEAS_AddPunishName:SetPos(130 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishName:SetText("<Name here>")
		
		// DTextEntry - Punishment SteamID.
		local SEAS_AddPunishID = vgui.Create("DTextEntry", SEAS_AdminFrame)
		SEAS_AddPunishID:SetSize(100, 25)
		SEAS_AddPunishID:SetPos(250 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishID:SetText("<SteamID here>")
		
		// DComboBox - Punishment time.
		local SEAS_AddPunishTime = vgui.Create("DComboBox", SEAS_AdminFrame)
		SEAS_AddPunishTime:SetSize(100, 25)
		SEAS_AddPunishTime:SetPos(370 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishTime:SetSortItems(true)
		for k, v in pairs(SEAS.GUI.Durations) do
			SEAS_AddPunishTime:AddChoice(k, v, true)
		end

		// DComboBox  - Punishment type.
		local SEAS_AddPunishType = vgui.Create("DComboBox", SEAS_AdminFrame)
		SEAS_AddPunishType:SetSize(100, 25)
		SEAS_AddPunishType:SetPos(490 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishType:AddChoice("BAN", "BAN", true)
		SEAS_AddPunishType:AddChoice("MUTE", "MUTE")
		SEAS_AddPunishType:AddChoice("VOICEMUTE", "VOICEMUTE")	

		// DTextEntry - Punishment SteamID.
		local SEAS_AddPunishReason = vgui.Create("DTextEntry", SEAS_AdminFrame)
		SEAS_AddPunishReason:SetSize(100, 25)
		SEAS_AddPunishReason:SetPos(610 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishReason:SetText("<Reason here>")		
		
		// DButton - Punishment Submission.
		local SEAS_AddPunishButton = vgui.Create("DButton", SEAS_AdminFrame)
		SEAS_AddPunishButton:SetSize(100, 25)
		SEAS_AddPunishButton:SetPos(730 * SEAS.Scale, 555 * SEAS.Scale)
		SEAS_AddPunishButton:SetText("Submit")
		SEAS_AddPunishButton.DoClick = function()
			if (SEAS_AddPunishName:GetValue() == "<Name here>") then
				return
			end
				
			if (SEAS_AddPunishID:GetValue() == "<SteamID here>") then
				return 
			end
				
			local data = {}
				
			data["name"] = SEAS_AddPunishName:GetValue()
			data["steamid"] = SEAS_AddPunishID:GetValue()
			data["admin"] = ply:Nick()
			data["type"] = select(2, SEAS_AddPunishType:GetSelected())
			data["duration"] = select(2, SEAS_AddPunishTime:GetSelected())
			data["reason"] = SEAS_AddPunishReason:GetValue()
				
			net.Start("SEAS_ClientPunishQuery")
				net.WriteTable(data)
				net.WriteEntity(ply)
			net.SendToServer()
			
		end
		
		net.Receive("SEAS_QuerySent", function()
			SEAS_AdminFrame:Close()
			SEAS:DrawPunishmentsMenu(ply)
		end)
	end)	
end

// Open's up a new frame to display the details of a log.
function SEAS:DrawLog(log)
	
	// Frame - Main log frame.
	local SEAS_LogFrame = vgui.Create("DFrame")
	SEAS_LogFrame:SetPos(ScrW() / (2.5 * SEAS.Scale), ScrH() / (2.5 * SEAS.Scale))
	SEAS_LogFrame:SetSize(450 * SEAS.Scale, 200 * SEAS.Scale)
	SEAS_LogFrame:SetTitle("Log Details")
	SEAS_LogFrame:SetIcon("icon16/book_open.png")
	SEAS_LogFrame:SetSkin("SEAS_Derma")
	SEAS_LogFrame:MakePopup(true)
	SEAS_LogFrame:SetBackgroundBlur(true)
	
	// DPanel - Panel to show the text.
	local SEAS_LogPanel = vgui.Create("DPanel", SEAS_LogFrame)
	SEAS_LogPanel:SetSize(440 * SEAS.Scale, 140 * SEAS.Scale)
	SEAS_LogPanel:Dock(TOP)
	
	// DLabel - Label for the text.
	local SEAS_LogText = vgui.Create("DLabel", SEAS_LogPanel)
	SEAS_LogText:SetWrap(true)
	SEAS_LogText:SetText(log)
	SEAS_LogText:SetTextColor(Color(0, 0, 0, 255))
	SEAS_LogText:SetFont("SEASFont18")
	SEAS_LogText:SetPos(5, 0)
	SEAS_LogText:SetSize(435 * SEAS.Scale, 135 * SEAS.Scale)
	
	// DButton - Close log button.
	local SEAS_LogButton = vgui.Create("DButton", SEAS_LogFrame)
	SEAS_LogButton:SetFont("SEASFont18")
	SEAS_LogButton:SetText("Close")
	SEAS_LogButton:Dock(BOTTOM)
	SEAS_LogButton.DoClick = function()
		SEAS_LogFrame:Close()
	end
	
end

// Draws the logs menu
function SEAS:ShowLogs()
	local tbl = {}
	if (SEAS.MISC.UseSQL) then	
		net.Start("SEAS_RequestLogs")
		net.SendToServer()
		
		net.Receive("SEAS_SentLogs", function()
			local data = net.ReadTable()
			for k, v in SortedPairsByMemberValue(data) do
				table.insert(tbl, v)
			end
		end)
	end
	
	// Wait for the data.
	timer.Simple(1, function()
		// Frame - Main log frame.
		local SEAS_LogFrame = vgui.Create("DFrame")
		SEAS_LogFrame:SetPos(ScrW() / (4 * SEAS.Scale), ScrH() / (4 * SEAS.Scale))
		SEAS_LogFrame:SetSize(900 * SEAS.Scale, 600 * SEAS.Scale)
		SEAS_LogFrame:SetTitle("Logs")
		SEAS_LogFrame:SetIcon("icon16/book.png")
		SEAS_LogFrame:SetSkin("SEAS_Derma")
		SEAS_LogFrame:MakePopup(true)
		SEAS_LogFrame:SetBackgroundBlur(true)
		
		// DListView - Logs list.
		local SEAS_LogList = vgui.Create("DListView", SEAS_LogFrame)
		SEAS_LogList:SetSize(890 * SEAS.Scale, 565 * SEAS.Scale)
		SEAS_LogList:SetPos(5, 30)
		SEAS_LogList:AddColumn("ID")
		SEAS_LogList:AddColumn("Log Type")
		SEAS_LogList:AddColumn("Server")	
		SEAS_LogList:AddColumn("Date Occured")
		SEAS_LogList:AddColumn("Detail Summary")
		for k, v in SortedPairsByMemberValue(tbl) do
			SEAS_LogList:AddLine(k, v["type"], v["server"], v["timestamp"], v["details"])
		end
		SEAS_LogList.OnRowSelected = function(pnl, index, row)
			local dmenu = DermaMenu()
			dmenu:AddOption("View Log", function() SEAS:DrawLog(row:GetValue(5)) end):SetImage("icon16/book_open.png")
			dmenu:Open()
		end
	end)


end

// Draws the management commands menu for specified player.
function SEAS:DrawManagementMenu(ply)
	local SEAS_SelectedPlayer = ""
	local SEAS_SelectedCommand = ""
	
	// A list of non-player management commands.
	local SEAS_NoDrawCommands = {"admin",
		"help",
		"punishments", 
		"restartmap",
		"quick", 
		"map",
		"checkdb", 
		"warn",
		"logs",
	}
	
	// Frame - Main admin frame.
	local SEAS_AdminFrame = vgui.Create("DFrame")
	SEAS_AdminFrame:SetPos(ScrW() / (4 * SEAS.Scale), ScrH() / (4 * SEAS.Scale))
	SEAS_AdminFrame:SetSize(900 * SEAS.Scale, 600 * SEAS.Scale)
	SEAS_AdminFrame:SetTitle("Admin Menu")
	SEAS_AdminFrame:SetIcon("icon16/shield.png")
	SEAS_AdminFrame:SetSkin("SEAS_Derma")
	SEAS_AdminFrame:MakePopup(true)
	SEAS_AdminFrame:SetBackgroundBlur(true)
	
	// DPanel - Background for the reason.
	local SEAS_ReasonBackground = vgui.Create("DPanel", SEAS_AdminFrame)
	SEAS_ReasonBackground:SetSize(300 * SEAS.Scale, 80 * SEAS.Scale)
	SEAS_ReasonBackground:SetPos(450 * SEAS.Scale, 280 * SEAS.Scale)
	SEAS_ReasonBackground.Paint = function(self, w, h)
		draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	SEAS_ReasonBackground:SetVisible(false)
	
	// DLabel - Reason text.
	local SEAS_ReasonText = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_ReasonText:SetSize(100, 25)
	SEAS_ReasonText:SetPos(570 * SEAS.Scale, 290 * SEAS.Scale)
	SEAS_ReasonText:SetFont("SEASFont18")
	SEAS_ReasonText:SetTextColor(color_white)
	SEAS_ReasonText:SetText("Reason")
	SEAS_ReasonText:SetVisible(false)
	
	// DTextEntry - Reasons for certain punishments.
	local SEAS_ReasonEntry = vgui.Create("DTextEntry", SEAS_AdminFrame)
	SEAS_ReasonEntry:SetSize(150 * SEAS.Scale, 25 * SEAS.Scale)
	SEAS_ReasonEntry:SetText("No reason specified.")
	SEAS_ReasonEntry:SetPos(525 * SEAS.Scale, 320 * SEAS.Scale)
	SEAS_ReasonEntry:SetVisible(false)
	
	// DPanel - Background for rank.
	local SEAS_RankBackground = vgui.Create("DPanel", SEAS_AdminFrame)
	SEAS_RankBackground:SetSize(300 * SEAS.Scale, 80 * SEAS.Scale)
	SEAS_RankBackground:SetPos(450 * SEAS.Scale, 280 * SEAS.Scale)
	SEAS_RankBackground.Paint = function(self, w, h)
		draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	SEAS_RankBackground:SetVisible(false)
	
	// DLabel - Rank text.
	local SEAS_RankText = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_RankText:SetSize(100, 25)
	SEAS_RankText:SetPos(580 * SEAS.Scale, 290 * SEAS.Scale)
	SEAS_RankText:SetFont("SEASFont18")
	SEAS_RankText:SetTextColor(color_white)
	SEAS_RankText:SetText("Rank")
	SEAS_RankText:SetVisible(false)
	
	// DTextEntry - Rank for setting rank of players.
	local SEAS_RankEntry = vgui.Create("DTextEntry", SEAS_AdminFrame)
	SEAS_RankEntry:SetSize(150 * SEAS.Scale, 25 * SEAS.Scale)
	SEAS_RankEntry:SetText("")
	SEAS_RankEntry:SetPos(525 * SEAS.Scale, 320 * SEAS.Scale)
	SEAS_RankEntry:SetVisible(false)
	

	
	// DPanel - Background for the duration.
	local SEAS_DurationBackground = vgui.Create("DPanel", SEAS_AdminFrame)
	SEAS_DurationBackground:SetSize(300 * SEAS.Scale, 80 * SEAS.Scale)
	SEAS_DurationBackground:SetPos(450 * SEAS.Scale, 390 * SEAS.Scale)
	SEAS_DurationBackground.Paint = function(self, w, h)
		draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	SEAS_DurationBackground:SetVisible(false)
	
	// DLabel - Duration text.
	local SEAS_DurationText = vgui.Create("DLabel", SEAS_AdminFrame)
	SEAS_DurationText:SetSize(100, 25)
	SEAS_DurationText:SetPos(570 * SEAS.Scale, 400 * SEAS.Scale)
	SEAS_DurationText:SetFont("SEASFont18")
	SEAS_DurationText:SetTextColor(color_white)
	SEAS_DurationText:SetText("Duration")
	SEAS_DurationText:SetVisible(false)
	
	// DComboBox - Punishment time.
	local SEAS_DurationComboBox = vgui.Create("DComboBox", SEAS_AdminFrame)
	SEAS_DurationComboBox:SetSize(100, 25)
	SEAS_DurationComboBox:SetPos(550 * SEAS.Scale, 430 * SEAS.Scale)
	SEAS_DurationComboBox:SetSortItems(true)
	for k, v in pairs (SEAS.GUI.Durations) do
		SEAS_DurationComboBox:AddChoice(k, v)
	end
	SEAS_DurationComboBox:SetVisible(false)
	
	// DListView - Player list.
	local SEAS_AdminPlayerList = vgui.Create("DListView", SEAS_AdminFrame)
	SEAS_AdminPlayerList:SetWidth(290 * SEAS.Scale)
	SEAS_AdminPlayerList:Dock(LEFT)
	SEAS_AdminPlayerList:AddColumn("Players")
	SEAS_AdminPlayerList:AddColumn("SteamID")
	for k, v in pairs(player.GetAll()) do	
		SEAS_AdminPlayerList:AddLine(v:Nick() , "("..v:SteamID()..")")
	end
	function SEAS_AdminPlayerList:OnRowSelected(pnl, index, row)
		SEAS_SelectedPlayer = index:GetValue(1)
	end
	
	// DScrollPanel - Container for commands.
	local SEAS_CommandContainer = vgui.Create("DScrollPanel", SEAS_AdminFrame)
	SEAS_CommandContainer:SetSize(545 * SEAS.Scale, 200 * SEAS.Scale)
	SEAS_CommandContainer:SetPos(320 * SEAS.Scale, 50 * SEAS.Scale)
	SEAS_CommandContainer.Paint = function(self, w, h)
		draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	
	// DIconLayout - Holds the command buttons.
	local SEAS_CommandButtons = vgui.Create("DIconLayout", SEAS_CommandContainer)
	SEAS_CommandButtons:SetSize(550 * SEAS.Scale, 200 * SEAS.Scale)	
	SEAS_CommandButtons:SetSpaceY(5)
	SEAS_CommandButtons:SetSpaceX(5)
	for k, v in pairs (SEAS.LocalCommands) do
		local power = SEAS:ConvertToPowerlevel(v[4])
		if (SEAS:ConvertToPowerlevel(LocalPlayer():GetUserGroup()) >= power) then
			if (!table.HasValue(SEAS_NoDrawCommands, v[1])) then
				local btn = SEAS_CommandButtons:Add("DButton")
				btn:SetText(string.upper(v[1]))
				btn:SetSize(105, 25)
				btn:SetFont("SEASFont18")
				btn.command = v[2]
				btn.isQuickCommand = v[6]
				btn.DoClick = function()
					SEAS_SelectedCommand = btn.command
					if (btn.isQuickCommand) then
						ply:ConCommand(SEAS_SelectedCommand.." "..SEAS_SelectedPlayer)
						SEAS_ReasonBackground:SetVisible(false)
						SEAS_ReasonText:SetVisible(false)
						SEAS_ReasonEntry:SetVisible(false)
						SEAS_DurationBackground:SetVisible(false)
						SEAS_DurationText:SetVisible(false)
						SEAS_DurationComboBox:SetVisible(false)
						SEAS_RankBackground:SetVisible(false)
						SEAS_RankText:SetVisible(false)
						SEAS_RankEntry:SetVisible(false)
					elseif (btn.command == "seas_kick") then
						SEAS_ReasonBackground:SetVisible(true)
						SEAS_ReasonText:SetVisible(true)
						SEAS_ReasonEntry:SetVisible(true)
						SEAS_DurationBackground:SetVisible(false)
						SEAS_DurationText:SetVisible(false)
						SEAS_DurationComboBox:SetVisible(false)
						SEAS_RankBackground:SetVisible(false)
						SEAS_RankText:SetVisible(false)
						SEAS_RankEntry:SetVisible(false)
					elseif (btn.command == "seas_setrank") then
						SEAS_ReasonBackground:SetVisible(false)
						SEAS_ReasonText:SetVisible(false)
						SEAS_ReasonEntry:SetVisible(false)
						SEAS_DurationBackground:SetVisible(false)
						SEAS_DurationText:SetVisible(false)
						SEAS_DurationComboBox:SetVisible(false)
						SEAS_RankBackground:SetVisible(true)
						SEAS_RankText:SetVisible(true)
						SEAS_RankEntry:SetVisible(true)
					else
						SEAS_ReasonBackground:SetVisible(true)
						SEAS_ReasonText:SetVisible(true)
						SEAS_ReasonEntry:SetVisible(true)
						SEAS_DurationBackground:SetVisible(true)
						SEAS_DurationText:SetVisible(true)
						SEAS_DurationComboBox:SetVisible(true)
						SEAS_RankBackground:SetVisible(false)
						SEAS_RankText:SetVisible(false)
						SEAS_RankEntry:SetVisible(false)
					end
				end
				SEAS_CommandButtons:Add(btn)
			end
		end
	end
	
	// DButton - Punishment Submission.
	local SEAS_PunishButton = vgui.Create("DButton", SEAS_AdminFrame)
	SEAS_PunishButton:SetSize(100, 25)
	SEAS_PunishButton:SetPos(550 * SEAS.Scale, 510 * SEAS.Scale)
	SEAS_PunishButton:SetText("Submit")
	SEAS_PunishButton:SetFont("SEASFont18")
	SEAS_PunishButton.DoClick = function()
		if (SEAS_SelectedCommand == "" || SEAS_SelectedPlayer == "") then 
			return 
		end
		
		if (SEAS_SelectedCommand == "seas_kick") then
			ply:ConCommand(SEAS_SelectedCommand.." "..SEAS_SelectedPlayer..' "'..SEAS_ReasonEntry:GetValue()..'"')
		elseif (SEAS_SelectedCommand == "seas_setrank") then
			ply:ConCommand(SEAS_SelectedCommand.." "..SEAS_SelectedPlayer..' "'..SEAS_RankEntry:GetValue()..'"') 
		else
			ply:ConCommand(SEAS_SelectedCommand.." "..SEAS_SelectedPlayer.." "..select(2, SEAS_DurationComboBox:GetSelected())..' "'..SEAS_ReasonEntry:GetValue()..'"')
		end
	end
	
	
end

// Draw's the DermaMenu for quick command execution.
// Quick commands are manually done here.
// If you add any new commands and want them on the quick menu then add them here.
function SEAS:QuickCommandsMenu()
	local SEAS_DermaMenu = DermaMenu()
	local SEAS_DMPlayers, SEAS_DMPlayersIcon = SEAS_DermaMenu:AddSubMenu("Players")
	SEAS_DMPlayersIcon:SetIcon("icon16/user.png")
	
	local SEAS_Server, SEAS_icon = SEAS_DermaMenu:AddSubMenu("Server")
	SEAS_icon:SetIcon("icon16/server.png")
	
	// Logs
	local logs = SEAS_Server:AddOption("View Logs", function() LocalPlayer():ConCommand("seas_logs") end):SetIcon("icon16/book.png")
	
	// Server related stuff for supers plus here
	if (SEAS:PermissionChecks(LocalPlayer(), "superadmin")) then


		// Gravity
		local gravity, icon = SEAS_Server:AddSubMenu("Set Gravity")
		icon:SetIcon("icon16/world_edit.png")
		local gravity0 = gravity:AddOption("0", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 0") end):SetIcon("icon16/text_list_numbers.png")
		local gravity200 = gravity:AddOption("200", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 200") end):SetIcon("icon16/text_list_numbers.png")
		local gravity400 = gravity:AddOption("400", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 400") end):SetIcon("icon16/text_list_numbers.png")
		local gravity600 = gravity:AddOption("600", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 600") end):SetIcon("icon16/text_list_numbers.png")
		local gravity800 = gravity:AddOption("800", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 800") end):SetIcon("icon16/text_list_numbers.png")
		local gravity1000 = gravity:AddOption("1000", function() LocalPlayer():ConCommand("seas_rcon sv_gravity 1000") end):SetIcon("icon16/text_list_numbers.png")
		
		// Change map
		local mapchange = SEAS_Server:AddOption("Change map", function() SEAS:MapRequest() end):SetIcon("icon16/image.png")
		
		// Check DB
		local checkdb = SEAS_Server:AddOption("Check DB connection", function() LocalPlayer():ConCommand("seas_checkdb")end ):SetIcon("icon16/database.png")
			
	end
		
	// Player targeting commands here.
	for k, v in pairs(player.GetAll()) do
		local ply, icon = SEAS_DMPlayers:AddSubMenu(v:Nick())
		icon:SetIcon("icon16/user.png")
		
		// Mod+ commands only.
		if (SEAS:PermissionChecks(LocalPlayer(), "mod")) then
		
			// Slay command
			local slay = ply:AddOption("Slay", function() LocalPlayer():ConCommand("seas_slay "..v:Nick()) end):SetIcon("icon16/lightning.png")
			
			// Kick command
			local kick, icon = ply:AddSubMenu("Kick")
			icon:SetIcon("icon16/user_delete.png")
			for k2, v2 in pairs(SEAS.GUI.ReasonList) do
				local reason = kick:AddOption(v2, function() LocalPlayer():ConCommand("seas_kick "..v:Nick().." "..v2) end):SetIcon("icon16/text_align_left.png")
			end
			
			// Freeze command
			local freeze = ply:AddOption("Toggle Freeze", function() LocalPlayer():ConCommand("seas_freeze "..v:Nick()) end):SetIcon("icon16/weather_snow.png")
		
			// Ban command
			local ban, icon = ply:AddSubMenu("Ban")
			icon:SetIcon("icon16/user_delete.png")
			
			local banduration, icon = ban:AddSubMenu("Duration")
			icon:SetIcon("icon16/time.png")

			// Mute command
			local mute, icon = ply:AddSubMenu("Mute")
			icon:SetIcon("icon16/sound_mute.png")
			
			local muteduration, icon = mute:AddSubMenu("Duration")
			icon:SetIcon("icon16/time.png")
			
			// Voicemute command
			local voicemute, icon = ply:AddSubMenu("Voicemute")
			icon:SetIcon("icon16/sound_mute.png")
			
			local voicemuteduration, icon = voicemute:AddSubMenu("Duration")
			icon:SetIcon("icon16/time.png")
			
			// Duraations and reasons for all of the types.
			for k2, v2 in pairs (SEAS.GUI.Durations) do
				local bandur, icon = banduration:AddSubMenu(k2)
				icon:SetIcon("icon16/time.png")
				
				local mutedur, icon = muteduration:AddSubMenu(k2)
				icon:SetIcon("icon16/time.png")
				
				local voicemutedur, icon = voicemuteduration:AddSubMenu(k2)
				icon:SetIcon("icon16/time.png")
				
				for k3, v3 in pairs(SEAS.GUI.ReasonList) do
					local ban = bandur:AddOption(v3, function() LocalPlayer():ConCommand("seas_ban "..v:Nick().." "..v2.." "..v3) end):SetIcon("icon16/text_align_left.png")
					local mreason = mutedur:AddOption(v3, function() LocalPlayer():ConCommand("seas_mute "..v:Nick().." "..v2.. " "..v3) end):SetIcon("icon16/text_align_left.png")
					local vmreason = voicemutedur:AddOption(v3, function() LocalPlayer():ConCommand("seas_voicemute "..v:Nick().." "..v2.. " "..v3) end):SetIcon("icon16/text_align_left.png")
				end
			end
		end
		
		// Admin+ commands only.
		if (SEAS:PermissionChecks(LocalPlayer(), "admin")) then
			// Bring command
			local bring = ply:AddOption("Bring", function() LocalPlayer():ConCommand("seas_bring "..v:Nick()) end):SetIcon("icon16/arrow_down.png")
			
			// Goto command
			local goto = ply:AddOption("Goto", function() LocalPlayer():ConCommand("seas_goto "..v:Nick()) end):SetIcon("icon16/arrow_up.png")
			
			// Spectate command
			local spectate = ply:AddOption("Spectate", function() LocalPlayer():ConCommand("seas_spec "..v:Nick()) end):SetIcon("icon16/eye.png")
		end
		
		// Superadmin+ commands only
		if (SEAS:PermissionChecks(LocalPlayer(), "superadmin")) then
			// God command
			local god = ply:AddOption("Toggle God", function() LocalPlayer():ConCommand("seas_god "..v:Nick()) end):SetIcon("icon16/shield.png")
			
		end
		
		// Owner commands only.
		if (SEAS:PermissionChecks(LocalPlayer(), "owner")) then
			local removerank = ply:AddOption("Remove rank", function() LocalPlayer():ConCommand("seas_removerank "..v:Nick()) end):SetIcon("icon16/shield_delete.png")
			local addrank, icon = ply:AddSubMenu("Promote")
			icon:SetIcon("icon16/shield_add.png")
			
			local owner = addrank:AddOption("Owner", function() LocalPlayer():ConCommand("seas_setrank "..v:Nick().." owner") end):SetIcon("icon16/shield.png")
			local owner = addrank:AddOption("Super Admin", function() LocalPlayer():ConCommand("seas_setrank "..v:Nick().." superadmin") end):SetIcon("icon16/user_gray.png")
			local owner = addrank:AddOption("Administrator", function() LocalPlayer():ConCommand("seas_setrank "..v:Nick().." admin") end):SetIcon("icon16/user_suit.png")
			local owner = addrank:AddOption("Moderator", function() LocalPlayer():ConCommand("seas_setrank "..v:Nick().." mod") end):SetIcon("icon16/user_red.png")
		end
		


	end
	
	SEAS_DermaMenu:Open(ScrW() / 4, ScrH() / 4)
end

// Prints helpful information to the console.
// Shows a menu instead if SEAS.MISC.PrintInConsole is false.
function SEAS:PrintHelp()
	local ply = LocalPlayer()
	local message = "-- AVAILABLE COMMANDS --" 
	if (SEAS:PermissionChecks(ply, "owner")) then
		print(message)
		for k, v in pairs (SEAS.CommandHelp["owner"]) do
			print(v.."\n")
		end 
		for k, v in pairs (SEAS.CommandHelp["superadmin"]) do
			print(v.."\n")
		end 
		for k, v in pairs (SEAS.CommandHelp["admin"]) do
			print(v.."\n")
		end
		for k, v in pairs(SEAS.CommandHelp["mod"]) do
			print(v.."\n")
		end
	elseif (SEAS:PermissionChecks(ply, "superadmin")) then
		print(message)
		for k, v in pairs (SEAS.CommandHelp["superadmin"]) do
			print(v.."\n")
		end 
		for k, v in pairs (SEAS.CommandHelp["admin"]) do
			print(v.."\n")
		end
		for k, v in pairs(SEAS.CommandHelp["mod"]) do
			print(v.."\n")
		end
	elseif (SEAS:PermissionChecks(ply, "admin")) then
		print(message)
		for k, v in pairs (SEAS.CommandHelp["admin"]) do
			print(v.."\n")
		end
		for k, v in pairs(SEAS.CommandHelp["mod"]) do
			print(v.."\n")
		end
	elseif (SEAS:PermissionChecks(ply, "mod")) then
		print(message)
		for k, v in pairs (SEAS.CommandHelp["mod"]) do
			print(v.."\n")
		end 
	end
	
	timer.Simple(1, function()
		chat.AddText(SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "A list of available commands have been printed in your console.")
	end)
end

// Checks if the admin is pressing the admin menu quick key.
function SEAS:CheckAdminKey(ply, key)
	if (IsFirstTimePredicted()) then
		if (key == KEY_M) then
			if (SEAS:PermissionChecks(ply, "mod")) then
				SEAS:QuickCommandsMenu()
			end
		end
	end
end
hook.Add("PlayerButtonDown", "SEAS:CheckAdminKey", function(ply, key)
	SEAS:CheckAdminKey(ply, key)	
end)

// Sets the users power level clientside.
net.Receive("SEAS_UserSetPowerLevel", function()
	local ply = net.ReadEntity()
	local power = net.ReadInt(16)
	
	ply.SEAS_PowerLevel = power
end)

// Opens the admin menu for the player.
net.Receive("SEAS_OpenAdminMenu", function()
	local ply = net.ReadEntity()
	
	SEAS:DrawManagementMenu(ply)
end)

// Opens the punishment menu for the player.
net.Receive("SEAS_OpenPunishmentsMenu", function()
	local ply = net.ReadEntity()
	
	SEAS:DrawPunishmentsMenu(ply)
end)

// Receives the commands
net.Receive("SEAS_SentCommandsToClient", function()
	SEAS.LocalCommands = net.ReadTable()
	SEAS:AddCommandHelp()
end)