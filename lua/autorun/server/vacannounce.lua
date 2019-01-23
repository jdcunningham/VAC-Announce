BroadcastTimeout = {}

CreateConVar( "vac_announce_mode", "0", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE } )
CreateConVar( "vac_announce_timeout", "300", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE } )
CreateConVar( "vac_announce_everyone", "0", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE } )

AnnounceMode = GetConVar( "vac_announce_mode" ):GetInt()
AnnounceTimeout = GetConVar( "vac_announce_timeout" ):GetInt()
AnnounceEveryone = GetConVar( "vac_announce_everyone" ):GetBool()

cvars.AddChangeCallback( "vac_announce_mode", function( convar_name, value_old, value_new )
	value_new = tonumber( value_new )
	if value_new == nil or value_new < 0 or value_new > 3 then
		GetConVar( "vac_announce_mode" ):SetInt( value_old )
		return
	end
	AnnounceMode = value_new
end )

cvars.AddChangeCallback( "vac_announce_timeout", function( convar_name, value_old, value_new )
	value_new = tonumber( value_new )
	if value_new == nil or value_new < 0 then
		GetConVar( "vac_announce_timeout" ):SetInt( value_old )
		return
	end
	AnnounceTimeout = value_new
	BroadcastTimeout = {}
end )

cvars.AddChangeCallback( "vac_announce_everyone", function( convar_name, value_old, value_new )
	value_new = tobool( value_new )
	if value_new == nil then
		GetConVar( "vac_announce_everyone" ):SetBool( true )
		return
	end
	AnnounceEveryone = value_new
end )

if game.SinglePlayer() then
	print( "VAC Announce Disabled. Reason: We're in singleplayer." )
	return
end

util.AddNetworkString( "VACMessage" )

function BroadcastBanInfo( name, steamuid )
	http.Fetch( "https://steamcommunity.com/profiles/" .. steamuid,
		function( body, len, headers, code )
			vac_bans, game_bans, last_ban = 0, 0, 0
			body = string.Split( body, "<div class=\"profile_ban_status\">" )[2]
			if body ~= nil then
				body = string.Split( body, " day(s) since last ban\t\t\t\t\t\t\t\t</div>" )[1]
				for s in string.gmatch( body, "[^\t]+" ) do
					if s == "1 VAC ban on record" then
						vac_bans = 1
					elseif s == "Multiple VAC bans on record" then
						vac_bans = "Multiple"
					elseif s == "1 game ban on record" then
						game_bans = 1
					elseif s == "Multiple game bans on record" then
						game_bans = "Multiple"
					end
					last_ban = s
				end
			end
			print( "VACA: " .. name .. " (" .. steamuid .. ") has " .. vac_bans .. " VAC ban(s), " .. game_bans .. " game ban(s)" .. (tonumber( last_ban ) > -1 and " with the last ban " .. last_ban .. " day(s) ago." or ".") )
			if AnnounceMode < 3 and ( AnnounceEveryone or vac_bans ~= 0 or game_bans ~= 0 ) then
				if BroadcastTimeout[steamuid] == nil or ( BroadcastTimeout[steamuid] + AnnounceTimeout <= SysTime() ) then
					for k, ply in pairs( player.GetAll() ) do
						if AnnounceMode == 0 or ( AnnounceMode == 1 and ( ply:IsAdmin() or ply:IsSuperAdmin() ) or ( AnnounceMode == 2 and ply:IsSuperAdmin() ) ) then
							net.Start( "VACMessage" )
							net.WriteString( name )
							net.WriteString( vac_bans )
							net.WriteString( game_bans )
							net.WriteUInt( last_ban, 32 )
							net.Send( ply )
						end
					end
					if AnnounceTimeout > 0 then
						BroadcastTimeout[steamuid] = SysTime()
					end
				else
					print( "VACA Info: Couldn't broadcast to players since the timeout hasn't yet been finished." )
				end
			end
		end,
		function( error )
			print( "VACA Error: Couldn't retrieve game ban info for " .. steamuid .. "!" )
		end
	)
end

print( "VAC Announce Enabled. Mode: " .. AnnounceMode .. " - Notify " ..  ( AnnounceMode == 0 and "Everybody" or ( AnnounceMode == 1 and "Admins" or ( AnnounceMode == 2 and "Super Admins" or "Console Only" ) ) ) )
gameevent.Listen( "player_connect" )
hook.Add( "player_connect", "CyberScriptz_VacAnnounce", function( data )
	steamid = string.Split( data.networkid, ":" )
	BroadcastBanInfo( data.name, "[U:1:" .. ( ( steamid[3] * 2 ) + steamid[2] ) .. "]" )
end )