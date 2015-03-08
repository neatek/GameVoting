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

public MenuHandler_Votegag(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char victim[11]; int vicint;
		GetMenuItem(menu, param2, victim, sizeof(victim));
		vicint = StringToInt(victim);
		gv.VoteFor(client, vicint, SQL_VOTEGAG);
	}
}

public MenuHandler_Reason(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select) 
	{
		char item[11]; int reason;
		GetMenuItem(menu, param2, item, sizeof(item));
		reason = StringToInt(item); // reason from array
		gv.setVbReason(client, reason); // set reason
		
		// launch ban menu
		Menu GVMENU = CreateMenu(MenuHandler_Voteban, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Voteban");
		AddMenuItem(GVMENU, "-1", "Reset vote", ITEMDRAW_DEFAULT);
		gv.FillPlayers(GVMENU, client, SQL_VOTEBAN);
		DisplayMenu(GVMENU, client, cMenuDelay.IntValue);
		gv.setAs(client, GetTime()+ cDelay.IntValue); // antispam
	}
}

/*
	Database callbacks
*/
public KickCallback(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == null) LogError("KickCallback Error: %s", error);
	else {
		if(player.valid(client)) {
			KickClient(client, "Kicked by GameVoting. Wait %d sec",cVkDelay.IntValue);
			PrintToChatAll("Player %N was kicked by GameVoting.", client);
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was kicked.", client, player.steam(client));
		}
	}
}

public RegPlayer_Callback(Handle:owner, Handle:query, const String:error[], any:client)
{
	//if(query == null) LogError("RegPlayer_Callback Error: %s", error);
	//else {
	if(player.valid(client)) {
		db.loadplayer(client);
	}
	//}
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
				gv.gagstamp(client, SQL_FetchInt(query, SQL_GAGSTAMP));
				#if defined PLUGIN_DEBUG
					LogMessage("LoadPlayer_Callback#%d",ggid);
				#endif
			}
		}
		else 
		{
			if(player.valid(client)) {
				db.regplayer(client);
			}
		}
	}
	
	// after load data
	//gv.displaydata(client);
	gv.checkother(client);
}