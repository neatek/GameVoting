#include <sourcemod>

/***

	Programming is philosophy.
	Silence is golden.

	# GAMEVOTING #
		Vladimir Zhelnov @neatek
		Sourcemod 1.8 // 2017

	Contact me:
	https://discord.gg/J7eSXuU
	
***/

// Boring to type it again and again
#define EVENT_PARAMS Handle event, const char[] name, bool dontBroadcast
//#define PLUGIN_DEBUG_MODE 1
#define VALID_PLAYER if(IsCorrectPlayer(client))
#define VALID_TARGET if(IsCorrectPlayer(target))
#define EVENT_GET_PLAYER GetClientOfUserId(GetEventInt(event, "userid"));
#define VOTE_BAN 1
#define VOTE_KICK 2
#define VOTE_MUTE 3
#define VOTE_SILENCE 4
#define VAR_VOTEBAN g_VoteChoise[client][vbSteam]
#define VAR_VOTEKICK g_VoteChoise[client][vkSteam]
#define VAR_VOTEMUTE g_VoteChoise[client][vmSteam]
#define VAR_VOTESILENCE g_VoteChoise[client][vsSteam]

#define VAR_IVOTEBAN g_VoteChoise[i][vbSteam]
#define VAR_IVOTEKICK g_VoteChoise[i][vkSteam]
#define VAR_IVOTEMUTE g_VoteChoise[i][vmSteam]
#define VAR_IVOTESILENCE g_VoteChoise[i][vsSteam]

#define VAR_TVOTEBAN g_VoteChoise[target][vbSteam]
#define VAR_TVOTEKICK g_VoteChoise[target][vkSteam]
#define VAR_TVOTEMUTE g_VoteChoise[target][vmSteam]
#define VAR_TVOTESILENCE g_VoteChoise[target][vsSteam]
#define VAR_CTYPE g_VoteChoise[client][current_type]
#define PLUG_TAG "GameVoting"
#define BAN_COMMAND  "voteban"
#define KICK_COMMAND "votekick"
#define GAG_COMMAND  "votegag"
#define MUTE_COMMAND "votemute"
#define SILENCE_COMMAND "votesilence"
#define CONVAR_VERSION ConVars[0]
#define CONVAR_ENABLED ConVars[1]
#define CONVAR_BAN_DURATION ConVars[2]
#define CONVAR_MUTE_DURATION ConVars[3]
//#define CONVAR_SILENCE_DURATION ConVars[4] 
#define CONVAR_KICK_DURATION ConVars[5]
#define CONVAR_BAN_ENABLE ConVars[6]
#define CONVAR_KICK_ENABLE ConVars[7]
#define CONVAR_MUTE_ENABLE ConVars[8]
//#define CONVAR_SILENCE_ENABLE ConVars[9]
#define CONVAR_MIN_PLAYERS ConVars[10]
#define CONVAR_AUTODISABLE ConVars[11]
#define CONVAR_BAN_PERCENT ConVars[12]
#define CONVAR_KICK_PERCENT ConVars[13]
#define CONVAR_MUTE_PERCENT ConVars[14]
//#define CONVAR_SILENCE_PERCENT ConVars[15]
#define CONVAR_IMMUNITY_FLAG ConVars[16]
#define CONVAR_IMMUNITY_zFLAG ConVars[17]

#define CONVAR_FLAG_START_VOTE ConVars[4]
#define CONVAR_START_VOTE_DELAY ConVars[9]
#define CONVAR_START_VOTE_ENABLE ConVars[15]

int g_startvote_delay = 0;
ConVar ConVars[20];
enum ENUM_VOTE_CHOISE
{
	current_type,
	String:vbSteam[32],
	String:vkSteam[32],
	String:vmSteam[32],
	String:vsSteam[32]
}
int g_VoteChoise[MAXPLAYERS+1][ENUM_VOTE_CHOISE];
enum ENUM_KICKED_PLAYERS
{
	time,
	String:Steam[32],
}
int g_KickedPlayers[MAXPLAYERS+1][ENUM_KICKED_PLAYERS];

public void register_ConVars() {
	
	CONVAR_VERSION = CreateConVar("sm_gamevoting_version", "1.8.3dev", "Version of gamevoting plugin. DISCORD - https://discord.gg/J7eSXuU , Author: Neatek, www.neatek.ru", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	CONVAR_ENABLED = CreateConVar("gamevoting_enable",	"1", "Enable or disable plugin (def:1)", _, true, 0.0, true, 1.0);	

	// min players
	CONVAR_MIN_PLAYERS = CreateConVar("gamevoting_players",	"1",	"Minimum players need to enable votes (def:8)", _, true, 0.0, true, 20.0);
	CONVAR_AUTODISABLE = CreateConVar("gamevoting_autodisable","0",	"Disable plugin when admins on server? (def:0)", _, true, 0.0, true, 1.0);

	// disables
	CONVAR_BAN_ENABLE = CreateConVar("gamevoting_voteban",	"1",	"Enable or disable voteban functional (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_KICK_ENABLE = CreateConVar("gamevoting_votekick",	"1",	"Enable or disable votekick (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_MUTE_ENABLE = CreateConVar("gamevoting_votemute",	"1",	"Enable or disable votemute (def:1)", _, true, 0.0, true, 1.0);
	//CONVAR_SILENCE_ENABLE = CreateConVar("gamevoting_votesilence",	"1",	"Enable or disable silence (def:1)", _, true, 0.0, true, 1.0);

	// durations
	CONVAR_BAN_DURATION = CreateConVar("gamevoting_voteban_delay", "1", "Ban duration in minutes (def:120)", _, true, 0.0, false);
	CONVAR_KICK_DURATION = CreateConVar("gamevoting_votekick_delay", "20", "Kick duration in seconds (def:20)", _, true, 0.0, false);
	CONVAR_MUTE_DURATION = CreateConVar("gamevoting_votemute_delay", "1", "Mute duration in minutes (def:120)", _, true, 0.0, false);
	//CONVAR_SILENCE_DURATION = CreateConVar("gamevoting_votesilence_delay", "1", "Mute duration in minutes (def:120)", _, true, 0.0, false);

	// percent
	CONVAR_BAN_PERCENT = CreateConVar("gamevoting_voteban_percent",	"80",	"Needed percent of players for ban someone (def:80)", _, true, 0.0, true, 100.0);
	CONVAR_KICK_PERCENT = CreateConVar("gamevoting_votekick_percent", "80",	"Needed percent of players for kick someone (def:80)", _, true, 0.0, true, 100.0);
	CONVAR_MUTE_PERCENT = CreateConVar("gamevoting_votemute_percent", "75",	"Needed percent of players for mute someone (def:75)", _, true, 0.0, true, 100.0);
	//CONVAR_SILENCE_PERCENT = CreateConVar("gamevoting_votesilence_percent",	 "75",	"Needed percent of players for silence someone (def:75)", _, true, 0.0, true, 100.0);
	
	// Immunity flags
	CONVAR_IMMUNITY_FLAG = CreateConVar("gamevoting_immunity_flag",	"a",	"Immunity flag from all votes (def:a)");
	CONVAR_IMMUNITY_zFLAG = CreateConVar("gamevoting_immunity_zflag",	"1",	"Immunity for admin flag \"z\"");

	CONVAR_START_VOTE_ENABLE = CreateConVar("gamevoting_startvote_enable", "1", "Disable of enable public votes (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_FLAG_START_VOTE = CreateConVar("gamevoting_startvote_flag",	"",	"Who can start voting for ban or something, set empty for all players (def:a)");
	CONVAR_START_VOTE_DELAY = CreateConVar("gamevoting_startvote_delay", "20", "Delay between public votes in seconds (def:20)", _, true, 0.0, false);
	
	AutoExecConfig(true, "Gamevoting");
}

public void OnPluginStart() {
	// Disable standart votes
	ServerCommand("sv_allow_votes 0");
	// Events
	HookEvent("player_disconnect", Event_PlayerDisconnected);
	register_ConVars();
}

public int FindFreeSlot() {

	for(int i =0 ; i <= MAXPLAYERS; i ++) {
	
		if(g_KickedPlayers[i][time] == 0) {
		
			return i;
			
		
		} else if(g_KickedPlayers[i][time] < GetTime()) {
		
			g_KickedPlayers[i][time] = 0;
		
		}
		
	}
	
	return -1;
	
}

public bool isadmin(int client)
{
	if(GetUserAdmin(client) != INVALID_ADMIN_ID) 
		return true;
	
	return false;
}

public bool adminsonserver()
{
	bool result = false;
	for(int i=0; i < GetMaxClients(); ++i) {
		if(IsCorrectPlayer(i)) {
			if(isadmin(i)) {
				result = true;
				break;
			}
		}
	}
		
	return result;
}


public void ClearVotesForClient(int client, int type) {
	VALID_PLAYER {
		
		char auth[32];
		GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
		
		for(int i =0 ; i <= MAXPLAYERS; i ++) {
			
			switch(type) {
				case VOTE_BAN: {
					if(StrEqual(VAR_IVOTEBAN,auth,true)) {
						strcopy(VAR_IVOTEBAN, 32, "");
					}
				}
				
				case VOTE_KICK: {
					if(StrEqual(VAR_IVOTEKICK,auth,true)) {
						strcopy(VAR_IVOTEKICK, 32, "");
					}
				}
				
				case VOTE_MUTE: {
					if(StrEqual(VAR_IVOTEMUTE,auth,true)) {
						strcopy(VAR_IVOTEMUTE, 32, "");
					}
				}

				default: {
					break;
				}
				
			}

			/*if(StrEqual(VAR_IVOTESILENCE,auth,true)) {
				strcopy(VAR_IVOTESILENCE, 32, "");
			}*/
		}
	}
}

public void PushKickedPlayer(int client) {
	VALID_PLAYER {
		int slot = FindFreeSlot();
		#if defined PLUGIN_DEBUG_MODE
			LogMessage("Kicked free slot : %d", slot);
		#endif
		if(slot > -1) {
		
			g_KickedPlayers[client][time] = GetTime() + ( CONVAR_KICK_DURATION.IntValue );
			
			#if defined PLUGIN_DEBUG_MODE
				LogMessage("Kicked time : %d", (GetTime() + ( CONVAR_KICK_DURATION.IntValue )));
			#endif
			
			char auth[32];
			GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
			
			strcopy(g_KickedPlayers[client][Steam], 32, auth);
			
		}
		
		KickClient(client, "Kicked by GameVoting (wait: %dsec)", CONVAR_KICK_DURATION.IntValue);
		
	}
	
}

public int KickedPlayer(int client) {
	VALID_PLAYER {
		char auth[32];
		GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
		
		for(int i =0 ; i <= MAXPLAYERS; i ++) {
			if(StrEqual(g_KickedPlayers[i][Steam],auth,true)) {
			
				if(g_KickedPlayers[i][time] > GetTime()) {
					return ( g_KickedPlayers[i][time] - GetTime() );
				}
				else {
					strcopy(g_KickedPlayers[i][Steam], 32, "");
					g_KickedPlayers[i][time] = 0;
					return 0;
				
				}
			}
		}
	}
	
	return 0;
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

public int GetCountVotes(int client, int type) {

	VALID_PLAYER {
	
		int i_Counted = 0;
	
		char auth[32];
		GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
	
		for(int target = 0; target <= MAXPLAYERS; target++) {
			VALID_TARGET {
			
				switch(type) {
					case VOTE_BAN: {
						if(StrEqual(VAR_TVOTEBAN,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_KICK: {
						if(StrEqual(VAR_TVOTEKICK,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_MUTE: {
						if(StrEqual(VAR_TVOTEMUTE,auth,true)) {
							i_Counted++;
						}
					}
				
					case VOTE_SILENCE: {
						if(StrEqual(VAR_TVOTESILENCE,auth,true)) {
							i_Counted++;
						}
					}
				
					default: {
						break;
					}
				
				}
			
			}
		
		}
		
		return i_Counted;
	
	}
	
	
	return 0;
}

public void ClearChoise(int client) {
	strcopy(VAR_VOTEBAN, 32, "");
	strcopy(VAR_VOTEKICK, 32, "");
	strcopy(VAR_VOTEMUTE, 32, "");
	//strcopy(VAR_VOTESILENCE, 32, "");
}

public int GetCountNeeded(int type) {

/*
	#define CONVAR_BAN_PERCENT ConVars[12]
	#define CONVAR_KICK_PERCENT ConVars[13]
	#define CONVAR_MUTE_PERCENT ConVars[14]
	#define CONVAR_SILENCE_PERCENT ConVars[15]
*/
	int players = CountPlayers();

	switch(type) {
	
		case VOTE_BAN: {
			///CONVAR_BAN_PERCENT.FloatValue 
			///((player.num() * cVbPercent.IntValue) / 100);
			return ((players * CONVAR_BAN_PERCENT.IntValue) / 100);
		}
				
		case VOTE_KICK: {
			return ((players * CONVAR_KICK_PERCENT.IntValue) / 100);
		}
				
		case VOTE_MUTE: {
			return ((players * CONVAR_MUTE_PERCENT.IntValue) / 100);
		}
				
		/*case VOTE_SILENCE: {
			return ((players * CONVAR_SILENCE_PERCENT.IntValue) / 100);
		}*/
		
		default: {
		
			return -1;
			
		}
	
	}
	
	return -1;
}

public void SetChoise(int type, int client, int target) {
	VALID_PLAYER {
		VALID_TARGET {
		
			char auth[32];
			GetClientAuthId(target, AuthId_Engine, auth, sizeof(auth));
			
			int needed = GetCountNeeded(type);
			if(needed == -1) 
				return;
			
			int current = 0;
			
			switch(type) {
					
				case VOTE_BAN: {
					strcopy(VAR_VOTEBAN, 32, auth);
					current = GetCountVotes(target, VOTE_BAN);
					PrintToChatAll("Player %N voted for ban %N. (%d/%d)", client, target, current, needed);
				}
				
				case VOTE_KICK: {
					strcopy(VAR_VOTEKICK, 32, auth);
					current = GetCountVotes(target, VOTE_KICK);
					PrintToChatAll("Player %N voted for kick %N. (%d/%d)", client, target, current, needed);
				}
				
				case VOTE_MUTE: {
					strcopy(VAR_VOTEMUTE, 32, auth);
					current = GetCountVotes(target, VOTE_MUTE);
					PrintToChatAll("Player %N voted for mute %N. (%d/%d)", client, target, current, needed);
				}
				
				case VOTE_SILENCE: {
					strcopy(VAR_VOTESILENCE, 32, auth);
					current = GetCountVotes(target, VOTE_SILENCE);
					PrintToChatAll("Player %N voted for silence %N. (%d/%d)", client, target, current, needed);
				}
				
				default: {
					return;
				}
				
			}
			
			if(current >= needed) {
				DoAction(target, type);
			}

		}
	}
}

public int CountPlayers() {
	int output = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
		if(IsCorrectPlayer(i) && !HasImmunity(i)) 
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
	
	#if !defined PLUGIN_DEBUG_MODE
	if(IsFakeClient(client) || IsClientSourceTV(client)) {
		return false;
	}
	#endif
	
	return true;
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

// Chat listener
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	VALID_PLAYER {
		
		#if defined PLUGIN_DEBUG_MODE
		//	LogMessage("sArgs : %s", sArgs);
		//	PrintToChatAll("sArgs : %s", sArgs);
		#endif
		
		if(sArgs[0] == '!' && sArgs[1] == 'v' && sArgs[2] == 'o' && sArgs[3] == 't' && sArgs[4] == 'e') 
			CheckCommand(client, sArgs, "!");
		
		else if(sArgs[0] == '/' && sArgs[1] == 'v' && sArgs[2] == 'o' && sArgs[3] == 't' && sArgs[4] == 'e') 
			CheckCommand(client, sArgs, "/");
		
		else if(sArgs[0] == 'v' && sArgs[1] == 'o' && sArgs[2] == 't' && sArgs[3] == 'e') 
			CheckCommand(client, sArgs, "");
	}

	return Plugin_Continue;
}

// Check commands
public void CheckCommand(int client, const char[] args, const char[] pref) {
	
	char command[24];
	strcopy(command, sizeof(command), args);
	TrimString(command);
	
	#if defined PLUGIN_DEBUG_MODE
	//	LogMessage("command : %s", command);
	//	PrintToChatAll("command : %s", command);
	//	HasImmunity(client);
	#endif
	
	if(strlen(pref) > 0) {
		ReplaceString(command, sizeof(command), pref, "", true);
	}
	
	if(CONVAR_ENABLED.IntValue < 1) {
		return;
	}

	if(CountPlayers() < CONVAR_MIN_PLAYERS.IntValue) {
		PrintToChat(client, "[GameVoting] Minimum players for voting - %d.", CONVAR_MIN_PLAYERS.IntValue);
		return;
	}
	
	if(CONVAR_AUTODISABLE.IntValue > 0) {
		if(adminsonserver()) {
			return;
		}
	}
	
	if(StrEqual(command, BAN_COMMAND, false)) {
		if(CONVAR_BAN_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_BAN);
		return;
	}
	
	if(StrEqual(command, KICK_COMMAND, false)) {
		if(CONVAR_KICK_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_KICK);
		return;
	}
	
	if(StrEqual(command, MUTE_COMMAND, false)) {
		if(CONVAR_MUTE_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_MUTE);
		return;
	}
	
	/*if(StrEqual(command, SILENCE_COMMAND, false)) {
		if(CONVAR_SILENCE_ENABLE.IntValue < 1) {
			return;
		}
	
		ShowMenu(client,VOTE_SILENCE);
		return;
	}*/
}

public bool StartVoteFlag(int client) {

	char s_flag[11];
	GetConVarString(CONVAR_FLAG_START_VOTE, s_flag, sizeof(s_flag));
	
	#if defined PLUGIN_DEBUG_MODE
		PrintToChatAll("flag - %s", s_flag);
	#endif
	
	#if defined PLUGIN_DEBUG_MODE
		PrintToChatAll("%d > %d [%d]", (g_startvote_delay), GetTime(), ( (g_startvote_delay) - GetTime()  )  );
	#endif

	if(g_startvote_delay > GetTime() && CONVAR_START_VOTE_ENABLE.IntValue > 0 ) {
		PrintToChat(client, "[GameVoting] Please wait %dsec before start public vote.", ((g_startvote_delay)-GetTime()) );
		return false;
	}
	
	if(strlen(s_flag) < 1) {
		return true;
	}
	
	new b_flags = ReadFlagString(s_flag);
	if ((GetUserFlagBits(client) & b_flags) == b_flags) {
		return true;
	}
	
	return false;
}

public bool HasImmunity(int client) {
	char s_flag[11];
	GetConVarString(CONVAR_IMMUNITY_FLAG, s_flag, sizeof(s_flag));
	new b_flags = ReadFlagString(s_flag);
	#if defined PLUGIN_DEBUG_MODE
	//	PrintToChatAll("flag - %s", s_flag);
	#endif
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

// Show ban&kick&mute&silence menu
public ShowMenu(int client, int type) {
	#if defined PLUGIN_DEBUG_MODE
		PrintToChatAll("Inited menu for client - %N [#%d]", client, type);
	#endif
	VALID_PLAYER {
	
		if(CountPlayers() < 2)
			return;
	
		VAR_CTYPE = type;
		
		Menu mymenu;
		
		if(!StartVoteFlag(client)) {
			mymenu = new Menu(menu_handler);
		}
		else {
			#if defined PLUGIN_DEBUG_MODE
				PrintToChatAll("StartVoteFlag() == true");
			#endif
			
			if(CONVAR_START_VOTE_ENABLE.IntValue > 0)
				mymenu = new Menu(startvote_menu_player_handler);
			else
				mymenu = new Menu(menu_handler);
		}
		
		switch(type) {
			case VOTE_BAN: {
				mymenu.SetTitle("GAMEVOTING - BAN");
			}
			case VOTE_KICK: {
				mymenu.SetTitle("GAMEVOTING - KICK");
			}
			case VOTE_MUTE: {
				mymenu.SetTitle("GAMEVOTING - MUTE");
			}
			case VOTE_SILENCE: {
				mymenu.SetTitle("GAMEVOTING - SILENCE");
			}
			default: {
				mymenu.SetTitle("GAMEVOTING");
			}	
		}
		
		//mymenu.AddItem("-1", "\nSELECT TARGET PLAYER", ITEMDRAW_RAWLINE|ITEMDRAW_DISABLED);

		char Name[48], id[11];
		for(int target=0;target<GetMaxClients();target++) {
			VALID_TARGET {
			
				if(target != client && !HasImmunity(target)) {
					IntToString(target, id, sizeof(id));
					FormatEx(Name,sizeof(Name),"%N",target);
					mymenu.AddItem(id,Name);
				}

			}
		}
		mymenu.Display(client, MENU_TIME_FOREVER);
	}
}

public void StartVote(int client, int target, int type) {

	VALID_PLAYER { VALID_TARGET {
		g_startvote_delay = GetTime() + CONVAR_START_VOTE_DELAY.IntValue;


		for(int i = 1; i <= MaxClients; i++) {
			if(IsCorrectPlayer(i)) {
				// start vote menus
				Menu mymenu = new Menu(menu_startvote_action_handler);
				char s_typeInitiator[48];
				// client, target, type / explode
				FormatEx(s_typeInitiator,sizeof(s_typeInitiator),"%d|%d|%d",client,target,VAR_CTYPE);
				
				#if defined PLUGIN_DEBUG_MODE
					PrintToChatAll("%s", s_typeInitiator);
				#endif
				
				char s_Menu[86];
				switch(VAR_CTYPE) {
					case VOTE_BAN: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Ban %N?", target);
					}
					case VOTE_KICK: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Kick %N?", target);
					}
					case VOTE_MUTE: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Mute %N?", target);
					}
					default: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING?");
						return;
					}	
				}
				mymenu.SetTitle(s_Menu);
				mymenu.AddItem(s_typeInitiator,"Yes");
				mymenu.AddItem("","No");
				mymenu.Display(client, MENU_TIME_FOREVER);
			}
		}

	} }
}

// startvote_menu_handler
public int startvote_menu_player_handler(Menu menu, MenuAction action, int client, int item) {

	if (action == MenuAction_Select) {
	
		char info[11];
		GetMenuItem(menu, item, info, sizeof(info));
		StartVote(client, StringToInt(info), VAR_CTYPE);
		
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

// action startvote
public int menu_startvote_action_handler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		#if defined PLUGIN_DEBUG_MODE
			PrintToChatAll("menu_startvote_action_handler()");
		#endif
		char info[48];
		GetMenuItem(menu, item, info, sizeof(info));
		char ex[3][11];
		ExplodeString(info, "|", ex, 3, 11);
		
		#if defined PLUGIN_DEBUG_MODE
			PrintToChatAll("startvote_menu_handler / info %s", info);
		#endif

		//int initiator = StringToInt(ex[0]);
		int target = StringToInt(ex[1]);
		int type = StringToInt(ex[2]);

		VALID_TARGET {
			SetChoise(type, client, target);
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

// Menu callback
public int menu_handler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[11];
		GetMenuItem(menu, item, info, sizeof(info));
		int target = StringToInt(info);
		VALID_TARGET {
			SetChoise(VAR_CTYPE, client, target);
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

// do action 
public void DoAction(int client, int type) {
	
	switch(type) {
		case VOTE_BAN: {
			ClearChoise(client);  // clear votes of players if kick or ban
			ClearVotesForClient(client, VOTE_BAN);
			ServerCommand("sm_ban #%d %d \"Banned by Gamevoting (%N)\"", GetClientUserId(client), CONVAR_BAN_DURATION.IntValue, client);
		}
		case VOTE_KICK: {
			ClearChoise(client); // clear votes of players if kick or ban
			ClearVotesForClient(client, VOTE_KICK);
			PushKickedPlayer(client);
		}
		case VOTE_MUTE: {
			/*
			[SourceComms++] Usage: sm_mute <#userid|name> [time|0] [reason]
			[SourceComms++] Usage: sm_mute <#userid|name> [reason]
			*/
			ClearVotesForClient(client, VOTE_MUTE);
			ServerCommand("sm_silence #%d %d \"Muted by Gamevoting (%N)\"", GetClientUserId(client), CONVAR_MUTE_DURATION.IntValue, client);
		}
		/*case VOTE_SILENCE: {
			ServerCommand("sm_silence #%d %d \"Silenced by Gamevoting (%N)\"", GetClientUserId(client), CONVAR_SILENCE_DURATION.IntValue, client);
		}*/
	}
	
}
