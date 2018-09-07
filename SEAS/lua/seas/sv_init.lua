-- SQL Settings here --
SEAS.SQL = {}  
 
SEAS.Tables = {}
 
SEAS.SQL.HOST = "35.240.23.236" // Replace with the IP your database uses.
SEAS.SQL.DB = "seasdb" // Replace with the database you use.
SEAS.SQL.User = "Doubleedge" // Replace with your DB user name.
SEAS.SQL.Pass = "Zombified1!" // Replace with your password.
SEAS.SQL.Port = 3306 // Replace with the port your database uses. (Usually port 3306)
 
// Let's not allow stupid stuff like name; DROP table_name; shall we.
function SEAS:Escape(str, ... )
    local clean = {}
    local arg={...}
   
    str = string.gsub(str, "?", "%s", 20)
    for i,v in ipairs(arg) do
        clean[i] = str
    end
   
    str = string.format(str, unpack(clean))
    return str
end
 
// If you're using SQL make sure all of the config info is correct
if (SEAS.MISC.UseSQL) then  
    require("mysqloo")    
 
    // Database connection and storage.
    SEAS.DB = mysqloo.connect(SEAS.SQL.HOST, SEAS.SQL.User, SEAS.SQL.Pass, SEAS.SQL.DB, SEAS.SQL.Port)
   
    // Sends the query for specific information.
    // Use this query if any commands need it use SQL.
    function SEAS:Query(str)
       
        // Let's make sure that safety is a priority
        local safety = SEAS:Escape(str)
        local q = SEAS.DB:query(safety)
       
        function q:onError(err, sql)
            print("[SEAS] There was an issue with the following query: ")
            print(sql)
            print("Error: ", err)
            return
        end
       
        function q:onSuccess(data)
            print("[SEAS] Successfully sent query.")
            table.insert(SEAS.Tables, data)
            PrintTable(data)
            return data
        end
       
        q:start()
    end
   
    function SEAS.DB:onConnected()
 
        print("[SEAS] Successfully connected to database.")
 
        SEAS:CheckTablesExist(self)
       
    end
   
    function SEAS.DB:onDisconnected()
        print("[SEAS] Disconnected from database.")
    end
 
    function SEAS.DB:onConnectionFailed( err )
 
        print( "[SEAS] Connection to database failed!" )
        print( "Error:", err )
 
    end
   
    function SEAS.DB:onError(err, sql)
        print("[SEAS] There was an issue with the following query: ")
        print(sql)
        print("Error: ", err)
        return
    end
       
    function SEAS.DB:onSuccess(data)
        print("[SEAS] Successfully sent query.")
        table.insert(SEAS.Tables, data[1])
        PrintTable(data)
        return data
    end
 
    function SEAS:CheckTablesExist()
        local seas = SEAS.DB:query([[SHOW TABLES LIKE 'seas_%']])
       
        function seas:onError(err, sql)
            print( "Query errored!" )
            print( "Query:", sql )
            print( "Error:", err )
        end
       
        function seas:onSuccess(data)
            print( "Query successful!" )
           
            if (#data < 1) then
                SEAS:CreateTables()
            end
        end
         
        seas:start()
    end
   
    // Create the initial tables.
    function SEAS:CreateTables()
        SEAS:Query([[CREATE TABLE seas_admin_ranks(
            steamid VARCHAR(30) NOT NULL,
            name VARCHAR(256) NOT NULL,
            rank VARCHAR(20) NOT NULL,
            PRIMARY KEY (steamid))]]
        )
         
        SEAS:Query([[CREATE TABLE seas_punishments(
            ID int NOT NULL AUTO_INCREMENT,
            steamid VARCHAR(30) NOT NULL,
            name VARCHAR(256) NOT NULL,
            type VARCHAR(256) NOT NULL,
            duration INT NOT NULL,
            admin VARCHAR (256) NOT NULL,
            reason VARCHAR(256) NOT NULL,
            adminsteamid VARCHAR(30) NOT NULL,
            PRIMARY KEY (ID)
            )]]
        )
       
        SEAS:Query([[CREATE TABLE seas_logs(
            server VARCHAR(256) NOT NULL,
            timestamp VARCHAR(200) NOT NULL,
            details VARCHAR(256) NOT NULL,
            type VARCHAR(30) NOT NULL)]]
        )
       
    end
 
    // Connect to DB.
    SEAS.DB:connect()
 
    // Net messages.
    util.AddNetworkString("SEAS_RequestPunishments")
    util.AddNetworkString("SEAS_SentPunishments")
    util.AddNetworkString("SEAS_ClientPunishQuery")
    util.AddNetworkString("SEAS_ClientEditQuery")
    util.AddNetworkString("SEAS_ClientRemoveQuery")
    util.AddNetworkString("SEAS_QuerySent")
    util.AddNetworkString("SEAS_RequestLogs")
    util.AddNetworkString("SEAS_SentLogs")
   
    // Let's check for any punishments when a player connects.
    function SEAS:CheckPunishmentsExist(ply)
        local status = SEAS.DB:status()
       
        if (!status == 0) then
            print("[DB ERROR] Problem retrieving info from database.")
        end
       
        // Not using SEAS:Query() for this because we are using SteamID.
        local punish = SEAS.DB:query([[SELECT * FROM seas_punishments WHERE steamid = "]]..ply:SteamID()..[["]])
       
        function punish:onSuccess(data)
            local tbl = {}
            for k, v in pairs (data) do
                table.insert(tbl, v)
            end
           
            // If a punishment exists, check their times and types.
            if (table.Count(tbl) > 0) then
                for k, v in pairs(tbl) do
                    if (v.type == "VOICEMUTE") then
                        if (v.duration <= os.time()) then
                            SEAS:Query([[DELETE FROM seas_punishments WHERE type = "VOICEMUTE" AND name = "]]..v.name..[[" AND duration = ]]..v.duration)
                            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[NOTICE] ", color_white, "Your voicemute has recently expired. Stay out of trouble.")
                        else
                            local time = v.duration - os.time()
                            if (time >= 155759993) then
                                time = "NEVER"
                            else
                                time = SEAS:ConvertTimestamp(time)
                            end
                           
                            ply:SEAS_Voicemute()
                            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[NOTICE] ", color_white, "You are voicemuted. Reason: "..v.reason.."\nExpires: "..time)
                        end        
                    elseif (v.type == "MUTE") then
                        if (v.duration <= os.time()) then
                            SEAS:Query([[DELETE FROM seas_punishments WHERE type = "MUTE" AND name = "]]..v.name..[[" AND duration = ]]..v.duration)
                            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[NOTICE] ", color_white, "Your mute has recently expired. Stay out of trouble.")
                        else
                            local time = v.duration - os.time()
                            if (time >= 155759993) then
                                time = "NEVER"
                            else
                                time = SEAS:ConvertTimestamp(time)
                            end
                       
                            ply:SEAS_Mute()
                            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[NOTICE] ", color_white, "You are muted. Reason: "..v.reason.."\nExpires: "..time)
                        end
                    elseif (v.type == "BAN") then
                        if (v.duration <= os.time()) then
                            SEAS:Query([[DELETE FROM seas_punishments WHERE type = "BAN" AND name = "]]..v.name..[[" AND duration = ]]..v.duration)
                            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[NOTICE] ", color_white, "Your ban has recently expired. Stay out of trouble.")
                        else
                            local time = v.duration - os.time()
                            if (time >= 155759993) then
                                time = "NEVER"
                            else
                                time = SEAS:ConvertTimestamp(time)
                            end
                            ply:Kick("You are banned. Reason: "..v.reason.."\nExpires: "..time)
                            print("You are banned. Reason: "..v.reason.."\nExpires: "..time)
                        end
                    end
                end
            end
        end
       
        function punish:onError(err, sql)
            print( "Query errored!" )
            print( "Query:", sql )
            print( "Error:", err )
        end
       
        punish:start()
 
    end
   
    // Let's check if the player has a rank on the SQL.
    function SEAS:CheckForRanks(ply)
        local status = SEAS.DB:status()
           
        if (!status == 0) then
            print("[DB ERROR] Problem retrieving info from database.")
        end
           
        // Not using SEAS:Query() for this because we want specific SteamID
        local rank = SEAS.DB:query([[SELECT * FROM seas_admin_ranks WHERE steamid = "]]..ply:SteamID()..[["]])
       
        function rank:onSuccess(data)
            local tbl = {}
            for k, v in pairs (data) do
                table.insert(tbl, v)
            end
           
            // If they have a rank, inform them and set their usergroup.
            if (table.Count(tbl) > 0) then
                ply:SetUserGroup(tbl[1]["rank"])
                if (SEAS.MISC.PrintStaffMessage) then
                    SEAS:AddText(ply, color_white, "Welcome back "..ply:Nick()..".\nYour rank is: "..tbl[1]["rank"])
                end
            end
        end
       
        function rank:onError(err, sql)
            print( "Query errored!" )
            print( "Query:", sql )
            print( "Error:", err )
        end
       
        rank:start()
    end
   
    hook.Add("PlayerInitialSpawn", "SEAS_CheckPunishments", function(ply)
        SEAS:CheckPunishmentsExist(ply)
        SEAS:CheckForRanks(ply)
    end)
   
    // For punishments list.
    net.Receive("SEAS_RequestPunishments", function()
        local tbl = {}
        local q = SEAS.DB:query([[SELECT * FROM seas_punishments]])
       
        function q:onSuccess(data)
            for k, v in SortedPairsByMemberValue(data) do
                if !(v.duration <= os.time()) then
                    table.insert(tbl, v)
                end
            end
   
            net.Start("SEAS_SentPunishments")
                net.WriteTable(tbl)
            net.Broadcast()
        end
       
        function q:onError(err, sql)
            print( "Query errored!" )
            print( "Query:", sql )
            print( "Error:", err )
        end
       
        q:start()
       
    end)
   
    // To add a punishment and reload the list.
    net.Receive("SEAS_ClientPunishQuery", function()
        local tbl = net.ReadTable()
        local ply = net.ReadEntity()
        local limits = 0 // 0 = PERMANENT.
       
        if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
            if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) == SEAS.MISC.AdminPowerLevel) then
                limits = SEAS.Punishments.MaxAdminLength
            else
                limits = SEAS.Punishments.MaxModLength
            end
        end
       
        if (tbl["duration"] > limits && limits !=0) then
            tbl["duration"] = limits
            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Your punishment length was changed due to rank restriction.")
        end
       
        SEAS:Query([[INSERT INTO seas_punishments(steamid, name, type, duration, admin, reason, adminsteamid)
        VALUES("]]..tbl["steamid"]..[[", "]]..tbl["name"]..[[", "]]..tbl["type"]..[[", ]]..(tbl["duration"] * 60 + os.time())..
        [[, "]]..tbl["admin"]..[[", "]]..tbl["reason"]..[[", "]]..ply:SteamID()..[[")]])
       
        net.Start("SEAS_QuerySent")
        net.Send(ply)
    end)
   
    // To update an existing punishment.
    net.Receive("SEAS_ClientEditQuery", function()
        local tbl = net.ReadTable()
        local ply = net.ReadEntity()
        local limits = 0 // 0 = PERMANENT.
       
        if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) < SEAS.MISC.SuperPowerLevel) then
            if (SEAS:ConvertToPowerlevel(ply:GetUserGroup()) == SEAS.MISC.AdminPowerLevel) then
                limits = SEAS.Punishments.MaxAdminLength
            else
                limits = SEAS.Punishments.MaxModLength
            end
        end
       
        if (tbl["duration"] > limits && limits !=0) then
            tbl["duration"] = limits
            SEAS:AddText(ply, SEAS.Chat.AdminMsgCol, "[ADMIN] ", color_white, "Your punishment length was changed due to rank restriction.")
        end
       
        SEAS:Query([[UPDATE seas_punishments SET duration = ]]..(tbl["duration"] * 60 + os.time())..[[, type = "]]..tbl["type"]..[["
        , reason = "]]..tbl["reason"]..[[" WHERE steamid = "]]..tbl["steamid"]..[[" AND type = "]]..tbl["oldtype"]..[["]])
       
        net.Start("SEAS_QuerySent")
        net.Send(ply)
    end)
   
    // To remove an existing punishment.
    net.Receive("SEAS_ClientRemoveQuery", function()
        local tbl = net.ReadTable()
        local ply = net.ReadEntity()
       
        SEAS:Query([[DELETE FROM seas_punishments WHERE steamid = "]]..tbl[2]..[[" AND type = "]]..tbl[4]..[["]])
       
        net.Start("SEAS_QuerySent")
        net.Send(ply)
    end)
   
    // To acquire and send all the logs.
    net.Receive("SEAS_RequestLogs", function()
        local tbl = {}
        local q = SEAS.DB:query([[SELECT * FROM seas_logs]])
       
        function q:onSuccess(data)
            for k, v in SortedPairsByMemberValue(data) do
                table.insert(tbl, v)
            end
   
            net.Start("SEAS_SentLogs")
                net.WriteTable(tbl)
            net.Broadcast()
        end
       
        function q:onError(err, sql)
            print( "Query errored!" )
            print( "Query:", sql )
            print( "Error:", err )
        end
       
        q:start()
    end)
   
   
end
 
// Make sure that others can't hear voicemuted people.
hook.Add("PlayerCanHearPlayersVoice", "SEAS_CheckVoiceMuted", function(listen, talk)
    if (talk:SEAS_IsVoiceMuted()) then
        return false
    else
        return true
    end
end)