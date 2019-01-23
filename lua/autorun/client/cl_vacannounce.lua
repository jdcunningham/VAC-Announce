net.Receive( "VACMessage", function()
    name = net.ReadString()
    vac_bans = net.ReadString()
    game_bans = net.ReadString()
    last_ban = net.ReadUInt( 32 )
    plain_color = Color( 255, 255, 255 )
    highlight_color = Color( 200, 200, 255 )
    risk_level = 0
    risk_level_color = highlight_color
    risk_level_text = "None"
    last_ban_info = { "" }
    if vac_bans ~= "0" or game_bans ~= "0" then
        last_ban_info = { " Last Ban: ", highlight_color, tostring( last_ban ) .. " day(s) ago", plain_color }
        if last_ban <= 365 and last_ban >= 182 then
            risk_level = risk_level + 1
        elseif last_ban < 182 and last_ban > 30 then
            risk_level = risk_level + 2
        elseif last_ban <= 30 then
            risk_level = risk_level + 3
        end
    end
    risk_level = risk_level + ( vac_bans == "Multiple" and 2 or tonumber( vac_bans ) )
    risk_level = risk_level + ( game_bans == "Multiple" and 2 or tonumber( game_bans ) )
    if risk_level ~= 0 then
        if risk_level == 1 then
            risk_level_color = highlight_color
            risk_level_text = "Very Low"
        elseif risk_level == 2 then
            risk_level_color = Color( 255, 255, 100 )
            risk_level_text = "Low"
        elseif risk_level == 3 then
            risk_level_color = Color( 255, 165, 0 )
            risk_level_text = "Medium"
        elseif risk_level >= 4 then
            risk_level_color = Color( 255, 0, 0 )
            risk_level_text = "High"
        end
    end
    ban_info = { risk_level_color, tostring( vac_bans ), plain_color, " VAC Ban(s) and ", risk_level_color, tostring( game_bans ), plain_color, " Game Ban(s)" }
    if vac_bans == "Multiple" and game_bans == "Multiple" then
        ban_info = { Color( 255, 0, 0 ), "Multiple VAC Bans & Game Bans." }
    elseif vac_bans == "0" and game_bans == "0" then
        ban_info = { "no VAC Bans or Game Bans." }
    end
    risk_level_info = { " Risk: ", risk_level_color, risk_level_text, plain_color }
    chat.AddText( Color( 255, 40, 100 ), "VACA", Color( 0, 0, 0 ), ": ", Color( 255, 255, 100 ), name, plain_color, " is connecting with ", unpack( ban_info ) )
    if risk_level > 0 then
        chat.AddText( Color( 255, 40, 100 ), "VACA", Color( 0, 0, 0 ), ": ", Color( 255, 255, 100 ), name, plain_color, "'s last ban was ", tostring( last_ban ), " day(s) ago.", unpack( risk_level_info ) )
    end
end )