methodmap WorkingWithPlayers
{
	public bool isadmin(int client)
	{
		if(GetUserAdmin(client) != INVALID_ADMIN_ID) return true;
		return false;
	}

	public void ban(int client, int attacker)
	{
		if(attacker > 0) {
			ServerCommand("sm_ban #%d %d \"Player %N banned by Gamevoting (votecaller: %N)\"", GetClientUserId(client), cVbDelay.IntValue, client, attacker);
		} else {
			ServerCommand("sm_ban #%d %d \"Player %N banned by Gamevoting (votecaller: CONSOLE)\"", GetClientUserId(client), cVbDelay.IntValue, client);
		}
		
		PrintToChatAll("Player %N was banned by GameVoting. (Reason: Justice of players)", client);
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
		if(!(1<= client<=MaxClients ) || !IsClientInGame(client) || IsClientSourceTV(client)) 
			return false;

		return true; 
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