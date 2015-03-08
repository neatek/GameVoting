methodmap WorkingWithPlayers
{
	public bool isadmin(int client)
	{
		if(GetUserAdmin(client) != INVALID_ADMIN_ID) return true;
		return false;
	}

	public bool immunity(int client)
	{
		AdminId adminclient = GetUserAdmin(client);
		if(adminclient == INVALID_ADMIN_ID) return false;
		if(GetAdminFlag(adminclient, ImmunityFlag, Access_Real)) return true;
		if(GetAdminFlag(adminclient, ImmunityFlag, Access_Effective)) return true;
		return false;
	}
	


	public char steam(int client) {
		char auth[STEAM_SIZE];
		switch(cAuth.IntValue)
		{
			case 1: if(GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth))) return auth;
			case 2: if(GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth))) return auth;
			case 3: if(GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth))) return auth;
			case 4: if(GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth))) return auth;
		}
		
		
		return auth;
	}
	
	public bool valid(int client) 
	{
		#if defined PLUGIN_DEBUG
		if(0 < client <= MaxClients && IsClientInGame(client) && IsClientConnected(client) && !IsClientSourceTV(client)) return true;
		#else
		if(0 < client <= MaxClients && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client) && !IsClientSourceTV(client)) return true;
		#endif

		return false; 
	}
	
	public void ban(int client, int attacker)
	{
		char rSon[REASON_LEN];
		int mReason = mostReason(client);
		gReasons.GetString(mReason, rSon, sizeof(rSon));
		#if defined PLUGIN_DEBUG
		LogMessage("MOST REASON: %i", mReason);
		#endif
		if(attacker > 0) {
			ServerCommand("sm_ban #%d %d \"Gamevoting (Reason: %s, votecaller: %N)\"", GetClientUserId(client), cVbDelay.IntValue, rSon, attacker);
		} else {
			ServerCommand("sm_ban #%d %d \"Gamevoting (Reason: %s, votecaller: CONSOLE)\"", GetClientUserId(client), cVbDelay.IntValue, rSon);
		}
		
		PrintToChatAll("Player %N was banned by %N. (Reason: %s)", client, attacker, rSon);
		
		if(cLogs.BoolValue) {
			LogToFile(LogFilePath, "Player %N(%s) was banned by %N for %d minutes (Reason: %s).",  client, this.steam(client), attacker, cVbDelay.IntValue, rSon);
		}
	}
	
	public bool vsteam(char steam[STEAM_SIZE]) {
		if(strlen(steam) > 0)
			return true;

		return false;
	}
	
	public int num() {
		int output = 0;
		for(int i = 1; i <= MaxClients; i++) if(this.valid(i)) output++;
		return output;
	}
	
	public bool adminsonserver()
	{
		bool result = false;
		for(int i=0; i < GetMaxClients(); ++i) {
			if(this.valid(i)) {
				if(this.isadmin(i)) {
					result = true;
					break;
				}
			}
		}
		
		return result;
	}
}

WorkingWithPlayers player;