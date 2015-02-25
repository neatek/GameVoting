methodmap WorkingWithPlayers
{
	public char steam(int client) {
		char auth[STEAM_SIZE];
		if(GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth))) {
			return auth;
		}
		
		return auth;
	}
	
	public bool valid(int client) 
	{
		if(!(1<= client<=MaxClients ) || !IsClientInGame(client)) 
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
}

WorkingWithPlayers player;