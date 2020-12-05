public void OnMapStart() {
	loadReasons();
}

public void OnPluginStart() {
	ServerCommand("sv_allow_votes 0");
	HookEvent("player_disconnect", Event_PlayerDisconnected);
	register_ConVars();
	GVInitLog();
}

public void OnPluginEnd() {
	UnhookEvent("player_disconnect", Event_PlayerDisconnected);
}

public void OnClientPostAdminCheck(int client) {
	VALID_PLAYER {
		int wait = KickedPlayer(client);
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("Kicked wait : %d", wait);
		#endif
		if(wait > 0) {
			KickClient(client, "Kicked by GameVoting (Wait: %d sec)", wait);
		}
	}
}

// Great event for storing data
public Action Event_PlayerDisconnected(EVENT_PARAMS) 
{
	int client = EVENT_GET_PLAYER
	VALID_PLAYER {
		ClearChoise(client);
		// valid player
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("%N player disconnected", client);
		#endif
	}
}