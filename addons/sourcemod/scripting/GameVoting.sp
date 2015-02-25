#include <sourcemod>
#include "GameVoting/Defines.sp"
#include "GameVoting/Variables.sp"
#include "GameVoting/Players.sp" 
#include "GameVoting/GameVoting.sp" 
#include "GameVoting/Database.sp" 
#include "GameVoting/Callbacks.sp" 
#include "GameVoting/ConVars.sp"
	
public OnPluginStart()
{
	db.connect();
	Plugin_ConVars();
	HookEvent("player_death", PlayerDeath_Event);
	AddCommandListener(Listener, "say");
	AddCommandListener(Listener, "say_team");
}

public Action:Listener(client, const String:command[], argc)
{
	char word[24];
	GetCmdArgString(word, sizeof(word));
	if((word[1] == '!' && word[2] == 'v') || word[1] == 'v') {
	String_ToLower(word,word,sizeof(word));
	if(strlen(word) > 11) return CONTINUE;
	if(!pEnabled) {
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
	int diff = player.num()-GetConVarInt(cMinimum);
	if(diff > -1) {
		PrintToChat(client, "[%s] Sorry, but need %d players for enable votes.", CHAT_PREFIX, diff);
		return CONTINUE;
	}

	StripQuotes(word);
	Menu GVMENU;
	int category = -1;
	// Build menu, menu title
	if(StrEqual(word, VOTEBAN_CMD) || StrEqual(word, "voteban"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEBAN)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}
		
		GVMENU = CreateMenu(MenuHandler_Voteban, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Voteban");
		category = SQL_VOTEBAN;
	}
	else if(StrEqual(word, VOTEKICK_CMD) || StrEqual(word, "votekick"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEKICK)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}

		GVMENU = CreateMenu(MenuHandler_Votekick, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Votekick");
		category = SQL_VOTEKICK;
	}
	else if (StrEqual(word, VOTEMUTE_CMD) || StrEqual(word, "votemute"))
	{
		if(!gv.VoteEnabled(client,SQL_VOTEMUTE)) {
			if(GVMENU != null) CloseHandle(GVMENU);
			return CONTINUE;
		}
		
		GVMENU = CreateMenu(MenuHandler_Votemute, MenuAction:MENU_NO_PAGINATION);
		SetMenuTitle(GVMENU, "GameVoting - Votemute");
		category = SQL_VOTEMUTE;
	}

	if(GVMENU != null) {
		// Add reset vote
		AddMenuItem(GVMENU, "-1", "Reset vote", ITEMDRAW_DEFAULT);

		// Fill menu by players
		gv.FillPlayers(GVMENU, client, category);
		DisplayMenu(GVMENU, client, 30);
		gv.setAs(client, GetTime()+GetConVarInt(cDelay)); // antispam
		return HANDLED;

	} else return CONTINUE;
	} else return CONTINUE;
}

public Action:PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	// testing on bots
	if(!pEnabled) return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	gv.VoteFor(client, attacker, SQL_VOTEBAN);
	//gv.numOfVotes(client, SQL_VOTEBAN);
}

public OnClientPostAdminCheck(int client) {
	if(!pEnabled) return;
	db.loadplayer(client);
}

public OnClientDisconnect_Post(int client)
{
	if(!pEnabled) return;
	gv.reset(client);
}

// www.sourcemodplugins.org/smlib/
String_ToLower(const String:input[], String:output[], size)
{
	size--;

	int x=0;
	while (input[x] != '\0' || x < size) {
		
		if (IsCharUpper(input[x])) {
			output[x] = CharToLower(input[x]);
		}
		else {
			output[x] = input[x];
		}
		
		x++;
	}

	output[x] = '\0';
}