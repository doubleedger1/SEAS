SEAS = {} 

// Include and add all content.
// If you want to modify the addon please name your files respectively.
function SEAS:IncludeAndAdd()
	local server = file.Find("seas/sv_*.lua", "LUA")
	local shared = file.Find("seas/sh_*.lua", "LUA")
	local client = file.Find("seas/cl_*.lua", "LUA")
	   
	if (SERVER) then
		for k, v in pairs(client) do
			AddCSLuaFile("seas/"..v)
		end
		
		for k, v in pairs(shared) do 
			AddCSLuaFile("seas/"..v)
			include("seas/"..v)
		end
		
		for k, v in pairs(server) do
			include("seas/"..v)
		end
	else
		for k, v in pairs (client) do
			include("seas/"..v)
		end
		
		for k, v in pairs(shared) do
			include("seas/"..v)
		end
	end
end

SEAS:IncludeAndAdd()
