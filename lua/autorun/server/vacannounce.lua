CreateConVar( "vac_announce_mode", "0", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE } )

AnnounceMode = GetConVar( "vac_announce_mode" ):GetInt()

cvars.AddChangeCallback( "vac_announce_mode", function( convar_name, value_old, value_new )
	value_new = tonumber( value_new )
	if value_new < 0 || value_new > 3 then
		GetConVar( "vac_announce_mode" ):SetInt( 0 )
		return
	end
	AnnounceMode = value_new
end )

gameevent.Listen( "player_connect" )
hook.Add( "player_connect", "CyberScriptz_VacAnnounce", function( data )
	steamid = string.Split( data.networkid, ":" )
	http.Fetch( "https://steamcommunity.com/profiles/[U:1:" .. ( ( steamid[3] * 2 ) + steamid[2] ) .. "]/?xml=1",
		function( body, len, headers, code )
			if string.Split( body, "<vacBanned>" )[2][1] == "1" then
				print( "Warning: " .. data.name .. " is connecting to this server with a VAC ban." )
				if AnnounceMode < 2 then
					for k, ply in pairs( player.GetAll() ) do
						if AnnounceMode == 0 or ( AnnounceMode == 1 and ply:IsAdmin() ) or ( AnnounceMode == 2 and ply:IsSuperAdmin() ) then
							PrintMessage( HUD_PRINTTALK, "Warning: " .. data.name .. " has a VAC ban on their Steam account." )
						end
					end
				end
			end
		end
	)
end )