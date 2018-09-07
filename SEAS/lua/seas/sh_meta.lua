// sh_meta.lua
// This file contains custom player related functions.
// If you want to add any player related functions you can do so here.
local meta = FindMetaTable("Player")

// Group permission checks.
// Owner.
function meta:SEAS_IsOwner()
	return SEAS.MISC.OwnerSteamID == self:SteamID() || self:IsUserGroup("owner") || self:IsSuperAdmin()
end

// Moderator.
function meta:SEAS_IsMod()
	return self:IsUserGroup("mod") || self:IsAdmin() || self:SEAS_IsOwner()
end

// Power level checks.
// Returns power level.
function meta:SEAS_GetPowerLevel()
	return self.SEAS_PowerLevel or 0
end

// Set's the power level
function meta:SEAS_SetPowerLevel(amount)
	self.SEAS_PowerLevel = amount
	
	// Gotta make sure both the client and the server are updated.
	// Saves doing it manually in each function that may do this.
	if (CLIENT) then
		net.Start("SEAS_PowerLevelSetServer")
			net.WriteInt(amount, 16)
			net.WriteEntity(self)
		net.SendToServer()
	else
		net.Start("SEAS_UserSetPowerLevel")
			net.WriteEntity(self)
			net.WriteInt(amount, 16)
		net.Send(self)
	end
end

// Checks user power against amount.
function meta:SEAS_HasPower(amount)
	return (amount <= self:SEAS_GetPowerLevel())	
end

// Punishment related checks.
// Checks if the player is muted.
function meta:SEAS_IsMuted() 
	return self.SEAS_Muted or false
end

// Checks if the player is voice muted.
function meta:SEAS_IsVoiceMuted()
	return self.SEAS_VoiceMuted or false
end

// Mutes the player.
function meta:SEAS_Mute()
	self.SEAS_Muted = true
end

// Unmutes the player.
function meta:SEAS_Unmute()
	self.SEAS_Muted = false
end

// Voicemutes the player.
function meta:SEAS_Voicemute()
	self.SEAS_VoiceMuted = true
end

// Un-voicemutes the player.
function meta:SEAS_UnVoicemute()
	self.SEAS_VoiceMuted = false
end