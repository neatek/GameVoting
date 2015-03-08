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

	if(word[1] == 'v' && word[2] == 'o') 
	{
		String_ToLower(word,word,sizeof(word));
		if(strlen(word) > 11) return CONTINUE;
		StripQuotes(word);

		Menu GVMENU;
		int category = 0;

		if(StrEqual(word, "voteban"))
		{
			if(CheckChat(client)) return CONTINUE;
			if(!gv.VoteEnabled(client,SQL_VOTEBAN)) {
				if(GVMENU != null) CloseHandle(GVMENU);
				return CONTINUE;
			}

			DisplayReasons(client);
			gv.setAs(client, GetTime()+ cDelay.IntValue); // antispam
		}
		else if(StrEqual(word, "votekick"))
		{
			if(CheckChat(client)) return CONTINUE;
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
			if(CheckChat(client)) return CONTINUE;
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
			if(CheckChat(client)) return CONTINUE;
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