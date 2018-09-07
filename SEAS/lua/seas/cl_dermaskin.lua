local SKIN = {}
function SKIN:PaintFrame(panel, w, h)
		
	draw.RoundedBox(-1, 0, 0, w, h, SEAS.GUI.BackgroundColor)
	draw.RoundedBox(-1, 0, 0, w, 25, SEAS.GUI.TopBarColor)
	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawOutlinedRect(0, 0, w, h)	
	
end

function SKIN:PaintScrollPanel(panel, w, h)
	draw.RoundedBox(-1, 0, 0, w, h, Color(255, 55, 70, 255))
end

function SKIN:PaintPropertySheet(panel, w, h)
	draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
end

function SKIN:PaintToolTip(panel, w, h)
	panel:SetTextColor(Color(255, 255, 255, 255))
	return draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
end

function SKIN:PaintButton(panel, w, h)
	panel:SetTextColor(Color(255, 255, 255, 255))
	if ( panel.Depressed ) then
		return draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 255))
	end
	
	if ( panel.Hovered ) then
		return draw.RoundedBox(-1, 0, 0, w, h, Color(50, 50, 50, 255))
	end
	
	if ( panel:GetDisabled() ) then
		return draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	//surface.SetDrawColor(Color(255, 255, 255, 255))
	
	draw.RoundedBox(-1, 0, 0, w, h, Color(0, 100, 150, 255))
	//surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:PaintWindowMinimizeButton(panel)
	return false
end

function SKIN:PaintWindowMaximizeButton(panel)
	return false
end

function SKIN:PaintWindowCloseButton(panel, w, h)
	if ( panel.Depressed ) then
		draw.RoundedBox(-1, 0, 0, w, h, Color(200, 200, 200, 255))
		draw.SimpleTextOutlined("X", "Trebuchet18", 14, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 1, 1, Color(0, 0, 0, 255))
	elseif ( panel.Hovered ) then
		draw.RoundedBox(-1, 0, 0, w, h, Color(255, 0, 0, 255))
		draw.SimpleTextOutlined("X", "Trebuchet18", 14, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 1, 1, Color(0, 0, 0, 255))
	elseif ( panel:GetDisabled() ) then
		draw.RoundedBox(-1, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.SimpleTextOutlined("X", "Trebuchet18", 14, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 1, 1, Color(0, 0, 0, 255))
	else
		draw.RoundedBox(-1, 0, 0, w, h, Color(150, 0, 0, 255))
		draw.SimpleTextOutlined("X", "Trebuchet18", 14, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 1, 1, Color(0, 0, 0, 255))
	end
end

derma.DefineSkin("SEAS_Derma", "SEAS Dermaskin by Doubleedge.", SKIN, "Default")

