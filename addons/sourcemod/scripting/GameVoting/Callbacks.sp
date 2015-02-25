/*
	Menu callbacks
*/
public MenuHandler_Voteban(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char victim[11]; int vicint;
		GetMenuItem(menu, param2, victim, sizeof(victim));
		vicint = StringToInt(victim);
		gv.VoteFor(client, vicint, SQL_VOTEBAN);
	}
}

public MenuHandler_Votekick(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char victim[11]; int vicint;
		GetMenuItem(menu, param2, victim, sizeof(victim));
		vicint = StringToInt(victim);
		gv.VoteFor(client, vicint, SQL_VOTEKICK);
	}
}

public MenuHandler_Votemute(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char victim[11]; int vicint;
		GetMenuItem(menu, param2, victim, sizeof(victim));
		vicint = StringToInt(victim);
		gv.VoteFor(client, vicint, SQL_VOTEMUTE);
	}
}

/*
	Database callbacks
*/
public RegPlayer_Callback(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == null) LogError("RegPlayer_Callback Error: %s", error);
	else {
		db.loadplayer(client);
	}
}

public Empty_Callback(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == null) LogError("Empty_Callback Error: %s", error);
}

public LoadPlayer_Callback(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == null) LogError("LoadPlayer_Callback Error: %s", error);
	else {
		if(SQL_GetRowCount(query) > 0) {
			while(SQL_FetchRow(query)) {
				int ggid = SQL_FetchInt(query, SQL_ID);
				gv.setId(client, ggid);
				gv.setkickstamp(client, SQL_FetchInt(query, SQL_KICKSTAMP));
				gv.mutestamp(client, SQL_FetchInt(query, SQL_MUTESTAMP));
				#if defined PLUGIN_DEBUG
					LogMessage("LoadPlayer_Callback#%d",ggid);
				#endif
			}
		}
		else 
		{
			db.regplayer(client);
		}
	}
	
	// after load data
	gv.displaydata(client);
	gv.checkother(client);
}