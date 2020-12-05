public int FindFreeSlot() {
	for(int i =0 ; i <= MAXPLAYERS; i ++) {
		if(g_KickedPlayers[i].time == 0) {
			return i;
		} else if(g_KickedPlayers[i].time < GetTime()) {
			g_KickedPlayers[i].time = 0;
		}
	}
	return -1;
}


public bool IsAdmin(int client)
{
	AdminId admin = GetUserAdmin(client);
	if(admin == INVALID_ADMIN_ID)
		return false;
	return GetAdminFlag(admin, Admin_Generic);
}


public bool adminsonserver()
{
	for(int i=0; i < MaxClients; ++i) {
		if(IsCorrectPlayer(i)) {
			if(IsAdmin(i))
				return true;
		}
	}
	return false;
}


public int CountPlayers() {
	int output = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
		if(IsCorrectPlayer(i) && !HasImmunity(i)) 
			output++;
	
	return output;
}


public int CountPlayers_withoutImmunity() {
	int output = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
		if(IsCorrectPlayer(i)) 
			output++;
	
	return output;
}


// Function for check is valid or not player
public bool IsCorrectPlayer(int client) {
	if(client > 4096) {
		client = EntRefToEntIndex(client);
	}
		
	if( (client < 1 || client > MaxClients) || !IsClientConnected(client) ||  !IsClientInGame( client ) ) {
		return false;
	}
	
	if(CONVAR_BOT_ENABLED.IntValue < 1) {
		if(IsFakeClient(client) || IsClientSourceTV(client)) {
			return false;
		}
	}
	
	return true;
}


public bool HasImmunity(int client) {
	char s_flag[11];
	GetConVarString(CONVAR_IMMUNITY_FLAG, s_flag, sizeof(s_flag));
	
	if(strlen(s_flag) < 1) {
		return false;
	}
	
	int b_flags = ReadFlagString(s_flag);

	if ((GetUserFlagBits(client) & b_flags) == b_flags) {
		return true;
	}
	if(CONVAR_IMMUNITY_zFLAG.IntValue > 0) {
		if (GetUserFlagBits(client) & ADMFLAG_ROOT) {
			return true;
		}
	}

	return false;
	//CONVAR_IMMUNITY_FLAG
}


public void player_steam(int client, char[] steam_id, int size) {
	char auth[32];
	switch(CONVAR_AUTHID_TYPE.IntValue)
	{
		case 1: {
			if(GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 2: {
			if(GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 3:  {
			if(GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
		case 4:  {
			if(GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth))) {
				Format(steam_id,size,auth);
			}
				
		}
	}
}