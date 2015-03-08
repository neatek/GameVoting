
public OnPluginStart()
{
	db.connect();
	Plugin_ConVars();
	GVInitLog();
	AddCommandListener(Listener, SAYCMD);
	AddCommandListener(Listener, SAYCMD2);
	HookEvent("player_death", PlayerDeath_Event);
	//OnPluginReload();
}

public OnMapStart() {
	pAdmins = false;
	loadReasons();
}

public Action:PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	// testing on bots
	if(!pEnabled) return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(gv.silenced(client)) {
		int diff = gv.getmutestamp(client)-GetTime();
		if(diff > 0) PrintCenterText(client,"You will be unmuted after: %d sec (GameVoting)",diff);
		else gv.unmuteplayer(client);
	}

	#if defined PLUGIN_DEBUG
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	gv.VoteFor(client, attacker, SQL_VOTEBAN);
	gv.numOfVotes(client, SQL_VOTEBAN);
	#endif
}

public OnClientPostAdminCheck(int client) {
	if(!pEnabled || !player.valid(client)) return;
	db.loadplayer(client);

	if(cAdmins.BoolValue && player.isadmin(client)){
		if(!pAdmins) pAdmins = true;
		#if defined PLUGIN_DEBUG
		LogMessage("ADMINS ON SERVER!!! PLUGIN DISABLED");
		#endif
	}
}

public OnClientDisconnect_Post(int client)
{
	if(cAdmins.BoolValue)
	{
		if(player.adminsonserver()) {
			if(!pAdmins) pAdmins = true; 
			#if defined PLUGIN_DEBUG
			LogMessage("ADMINS ON SERVER!!! PLUGIN DISABLED");
			#endif
		}
		else {
			if(pAdmins) pAdmins = false;
			#if defined PLUGIN_DEBUG
			LogMessage("ADMINS NOT ON SERVER!!! PLUGIN ENABLED");
			#endif
		}
	}

	if(!pEnabled || !player.valid(client)) return;
	gv.reset(client);
}