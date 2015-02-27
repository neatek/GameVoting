public Action:Listener(client, const String:command[], argc)
{
	if(gv.silenced(client)) {
		int diff = gv.getmutestamp(client)-GetTime();
		if(diff > 0) {
			if(!cGag.BoolValue) {
				PrintCenterText(client,"You will be unmuted after: %d sec (GameVoting)",diff);
				PrintToChat(client, "You will be unmuted after: %d sec (GameVoting)",diff);
			} 
			else {
				if(gv.silenced(client) && !gv.muted(client)) {
					PrintCenterText(client,"You will be ungagged after: %d sec (GameVoting)",diff);
					PrintToChat(client, "You will be ungagged after: %d sec (GameVoting)",diff);
				}
				else {
					PrintCenterText(client,"You will be unmuted after: %d sec (GameVoting)",diff);
					PrintToChat(client, "You will be unmuted after: %d sec (GameVoting)",diff);
				}
			}
			
			return HANDLED;
		}
		else {
			gv.unmuteplayer(client);
			return CONTINUE;
		}
	}

	char word[24];
	GetCmdArgString(word, sizeof(word));
	//(word[1] == '!' && word[2] == 'v') || 
	if(word[1] == 'v' && word[2] == 'o') {
	String_ToLower(word,word,sizeof(word));
	if(strlen(word) > 11) return CONTINUE;
	
	if(!pEnabled) {
		PrintToChat(client, "[%s] Admins disable this plugin.", CHAT_PREFIX);
		return CONTINUE;
	}

	// admins on server
	if(cAdmins.BoolValue && pAdmins) {
		PrintToChat(client, "[%s] Admins disable this plugin.", CHAT_PREFIX);
		return CONTINUE;
	}
	
	// Antispam
	if(!gv.allowcmd(client)) {
		int sec = gv.getAs(client)-GetTime();
		PrintToChat(client, "[%s] Stop spam, wait %d sec.", CHAT_PREFIX, sec);
		return CONTINUE;
	}

	// Check minimum players
	if(player.num() < cMinimum.IntValue) {
		PrintToChat(client, "[%s] Sorry, but need more than %d players for votes.", CHAT_PREFIX, (cMinimum.IntValue-1));
		return CONTINUE;
	}

	StripQuotes(word);
	
	PrintToConsole(client, "word: %s", word);

	#if defined PLUGIN_DEBUG
	if(StrEqual(word, "vomuteme"))
	{
		PrintToChat(client, "Mute you!");
		gv.muteplayer(client, (GetTime()+ cVmDelay.IntValue));
	}
	else if(StrEqual(word, "vokickme"))
	{
		PrintToChat(client, "Kick you!");
		gv.setkick(client, 5);
	}
	else if(StrEqual(word, "vobanme"))
	{
		PrintToChat(client, "Ban you!");
		player.ban(client, 0); 
	}
	#endif

	Menu GVMENU;
	int category = 0;
	// Build menu, menu title
	if(StrEqual(word, "voteban"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEBAN)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}
		
		GVMENU = CreateMenu(MenuHandler_Voteban, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Voteban");
		category = SQL_VOTEBAN;
	}
	else if(StrEqual(word, "votekick"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEKICK)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}

		GVMENU = CreateMenu(MenuHandler_Votekick, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Votekick");
		category = SQL_VOTEKICK;
	}
	else if (StrEqual(word, "votemute"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEMUTE)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}
		
		GVMENU = CreateMenu(MenuHandler_Votemute, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Votemute");
		category = SQL_VOTEMUTE;
	}	
	else if (StrEqual(word, "votegag"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEGAG)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}
		
		GVMENU = CreateMenu(MenuHandler_Votegag, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Votegag");
		category = SQL_VOTEGAG;
	}

	if(GVMENU != null) {
		// Add reset vote
		AddMenuItem(GVMENU, "-1", "Reset vote", ITEMDRAW_DEFAULT);

		// Fill menu by players
		gv.FillPlayers(GVMENU, client, category);
		DisplayMenu(GVMENU, client, cMenuDelay.IntValue);
		gv.setAs(client, GetTime()+ cDelay.IntValue); // antispam
		return HANDLED;

	} else return CONTINUE;
	} else return CONTINUE;
}