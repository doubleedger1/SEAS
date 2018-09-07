SEAS.Chat = {}  
SEAS.Punishments = {}
SEAS.GUI = {}  
SEAS.MISC = {} 

// Reasons for the quick menu.
SEAS.GUI.ReasonList = 
{
	"Does not want to be here.",
	"Breaking rules.",
	"Prop killing.",
	"RDMing.",
}

// Durations for the quick menu in minutes
// How to add:
// ["Text time"] = time in minutes,
SEAS.GUI.Durations =
{
	["10 Minutes"] = 10,
	["30 Minutes"] = 30,
	["1 Hour"] = 60,
	["2 Hours"] = 120,
	["6 Hours"] = 360,
	["1 Day"] = 1440,
	["2 Days"] = 2440,
	["1 Week"] = 10080,
	["2 Weeks"] = 20160,
	["1 Month"] = 40320,
	["1 Year"] = 525600,
	["Permanent"] = 5256000,
}
  
-- Chat related settings --
SEAS.Chat.Tags = true // Enable Super Admin, Admin and Moderator chat tags. Set false to disable. Default: false
SEAS.Chat.SuggestCommands = true // Show commands closest to your current text. Set false to disable.
SEAS.Chat.AdminChatEnabled = true // Enable admin only chat. Default: true
SEAS.Chat.AdminChatPrefix = "@" // If enabled this will be the admin chat. Default: @
SEAS.Chat.Prefix = "/" // Set what prefix to use for chat commands. Set to "! or /" to use ! and /. Default: /
SEAS.Chat.PrintNoclipMsg = true // Set whether or not to print noclip messages in the chat.
SEAS.Chat.AdminMsgCol = Color(0, 0, 255, 255) // Set the color of the admin system messages.
SEAS.Chat.Target = Color(0, 255, 0, 255) // Set the color of the target text. I.E: Command or player names.
SEAS.Chat.PermissionMessage = "You do not have permission to use this command." // Set the message of insufficient permissions. 
SEAS.Chat.PunishCol = Color(255, 0, 0, 255) // Set the color of the punishment value text.
SEAS.Chat.SilentNoclipMsg = false // Set whether or not a message should be printed to chat when admins noclip.

-- Punishment related settings --
SEAS.Punishments.MaxAdminLength = 0 // Set the maximum punish length an admin can issue in minutes. 0 = PERMANENT. Default: 0
SEAS.Punishments.MaxModLength = 10080 // Set the maximum punish length a moderator can issue in minutes  0 = PERMANENT. Default: 10080
SEAS.Punishments.CanEditAny = false // Set whether or not admins can edit each others punishments. Note: Super Admins+ can edit any punishment regardless. Default: false
SEAS.Punishments.UsePopupWarnings = true // Set whether a user receives either a chatbox warning or a popup box. Default: true
SEAS.Punishments.AdminImmunity = true // Set whether admins are immune to punishments. Default: true 
SEAS.Punishments.DefaultTime = 2880 // Set the default punishment time in mins. 0 = PERMANENT.
SEAS.Punishments.DefaultReason = "No reason provided." // Set the default reason when no reason is provided.
SEAS.Punishments.StaffAreImmune = false // Set whether admins and mods are immune to punishments. Default: false.

// Used for chat time checking. Example: /ban Doubleedge. 1m2w3d10h testing.
// Please keep the values between single and double digits. 
// Use higher categories for longer lengths in chat if needed.
SEAS.Punishments.MaxHours = 24 // Set the maximum amount of hours to punish for.Default: 24.
SEAS.Punishments.MaxDays = 7 // Set the maximum amount of days to punish for. Default: 7.
SEAS.Punishments.MaxWeeks = 4 // Set the maximum amount of weeks to punish for. Default: 4.
SEAS.Punishments.MaxMonths = 12 // Set the maximum amount of months to punish for. Default: 12.
SEAS.Punishments.MaxYears = 5 // Set the maximum number of years to punish for. Default: 5.

-- GUI related settings --
SEAS.GUI.ErrorIcon = "icon16/error.png" // Set the path of the error icon for ErrorMsg windows. Uses silkicons. Default "icon16/error.png".
SEAS.GUI.WarningIcon = "icon16/exclamation.png" // Set the path of the warning icon for ErrorMsg windows. Uses silkicons. Default "icon16/exclamation.png".
SEAS.GUI.InsufficientPermissions = "You do not have permission to do this." // Set the message for when a staff member tries to do something they shouldn't.
SEAS.GUI.BackgroundColor = Color(0, 0, 0, 200) // Set the background color of the GUI. Default: Color(0, 0, 0, 200)
SEAS.GUI.TopBarColor = Color(0, 100, 150, 255) // Set the top bar color of the GUI. Default: Color(0, 100, 150, 255)
SEAS.GUI.QuickMenuButton = KEY_M // Set the default button code. http://wiki.garrysmod.com/page/Enums/BUTTON_CODE has a list. Default: KEY_M

-- Miscellaneous settings --
SEAS.MISC.UseSQL = true // Set whether or not to use SQL or text files. Default: true.
SEAS.MISC.SavePlayerPunishments = false // Set whether or not to save a record of player punishments.
SEAS.MISC.ChangemapDelay = 5 // Number of seconds before changing map after an admin changes map. 
SEAS.MISC.RestartmapDelay = 5 // Number of seconds before restarting the map after admin restarts map. 
SEAS.MISC.UsePowerLevel = true // Decide to use power levels as well as admin checking. Default: false
SEAS.MISC.OwnerPowerLevel = 100 // Set the power level of owner. Note: You really shouldn't change this lower than other groups. Default: 100
SEAS.MISC.SuperPowerLevel = 75 // Set the power level of superadmin. // Default: 75
SEAS.MISC.AdminPowerLevel = 50 // Set the power level of admin. // Default: 50
SEAS.MISC.ModPowerLevel = 25 // Set the power level of mod. Default: 25
SEAS.MISC.PrintInConsole = false // Decides to draw a menu for help or print in console. Default: false.
SEAS.MISC.PrintStaffMessage = true // Set's whether or not to welcome staff members back to the server. Default: true
SEAS.MISC.UseLogs = true // Set's whether or not to use the log system for the server. Default: true
SEAS.MISC.UseServerName = true // Set's whether or not to use the server IP or server name for logging. Default: true
SEAS.MISC.SaveChatLogs = true // Set's whether or not to save chat logs. Warning: Can cause problems with high player counts. Default: true