/***
	Programming is philosophy.
	Vladimir Zhelnov @neatek

	Contact me:
	https://discord.gg/J7eSXuU
	https://neatek.ru/en

	Supports: Sourcebans++, MaterialAdmin, Sourcemod (2020)

	Old versions:
	https://neatek.ru/en/plugins/neatek-gamevoting-old-plugin-versions-archived
***/
#undef REQUIRE_PLUGIN
#include <sourcebanspp>
#include <sourcecomms>
#include <materialadmin>
#include "gamevoting/defines.sp"
#include "gamevoting/globals.sp"
#include "gamevoting/logs.sp"
#include "gamevoting/functions.sp"
#include "gamevoting/reasons.sp"
#include "gamevoting/detect.sp"
#include "gamevoting/commands.sp"
#include "gamevoting/events.sp"
#include "gamevoting/cvars.sp"


public void ClearVotesForClient(int client, int type) {
	VALID_PLAYER {
		char auth[32];
		//GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
		player_steam(client, auth, sizeof(auth));
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
			g_KickedPlayers[client].time = GetTime() + ( CONVAR_KICK_DURATION.IntValue );
			#if defined PLUGIN_DEBUG_MODE
				LogMessage("Kicked time : %d", (GetTime() + ( CONVAR_KICK_DURATION.IntValue )));
			#endif
			char auth[32];
			//GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
			player_steam(client, auth, sizeof(auth));
			strcopy(g_KickedPlayers[client].Steam, 32, auth);
		}
		KickClient(client, "Kicked by GameVoting (wait: %dsec)", CONVAR_KICK_DURATION.IntValue);
	}
	
}


public int KickedPlayer(int client) {
	VALID_PLAYER {
		char auth[32];
		//GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth));
		player_steam(client, auth, sizeof(auth));
		
		for(int i =0 ; i <= MAXPLAYERS; i ++) {
			if(StrEqual(g_KickedPlayers[i].Steam,auth,true)) {
			
				if(g_KickedPlayers[i].time > GetTime()) {
					return ( g_KickedPlayers[i].time - GetTime() );
				}
				else {
					strcopy(g_KickedPlayers[i].Steam, 32, "");
					g_KickedPlayers[i].time = 0;
					return 0;
				
				}
			}
		}
	}
	
	return 0;
}


public int GetCountVotes(int client, int type) {

	VALID_PLAYER {
	
		int i_Counted = 0;
	
		char auth[32];
		player_steam(client, auth, sizeof(auth));
	
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
	g_VoteChoise[client].voteban_reason = 0;
	//strcopy(VAR_VOTESILENCE, 32, "");
}


public int GetCountNeeded(int type) {
	int players = CountPlayers();
	switch(type) {
		case VOTE_BAN: {
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
	// return -1;
}


public void SetChoise(int type, int client, int target) {
	VALID_PLAYER {
		VALID_TARGET {
			char auth[32];
			player_steam(target, auth, sizeof(auth));
			int needed = GetCountNeeded(type);
			if(needed == -1) {
				LOGS_ENABLED {
					LogToFile(LogFilePath, "[GameVoting][Error] Needed count of players for ban : -1");
				}
				return;
			}
			if(needed < 2) {
				PrintToServer("[GameVoting][Fix] Minimum needed count must be: 3, current: %d", needed);
				needed = 3;
			}
			int current = 0;
			switch(type) {
				case VOTE_BAN: {
					strcopy(VAR_VOTEBAN, 32, auth);
					current = GetCountVotes(target, VOTE_BAN);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("\x04[GameVoting]\x01 %t", "gv_voted_for_ban", c_name, t_name, current, needed);

					LOGS_ENABLED {
						char reason[64];
						if(g_VoteChoise[client].voteban_reason > -1)
							gReasons.GetString(g_VoteChoise[client].voteban_reason, reason, sizeof(reason));

						char auth1[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for ban %N(%s). (%d/%d) (Reason: %s - #%d)",  client, auth1, target, auth, current, needed, reason, g_VoteChoise[client].voteban_reason);
						PrintToServer("Player %N(%s) voted for ban %N(%s). (%d/%d) (Reason: %s - #%d)",  client, auth1, target, auth, current, needed, reason, g_VoteChoise[client].voteban_reason);
					}
				}
				
				case VOTE_KICK: {
					strcopy(VAR_VOTEKICK, 32, auth);
					current = GetCountVotes(target, VOTE_KICK);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("\x04[GameVoting]\x01 %t", "gv_voted_for_kick", c_name, t_name, current, needed);
					LOGS_ENABLED {
						char auth1[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for kick %N(%s). (%d/%d)",  client, auth1, target, auth, current, needed);
					}
				}
				
				case VOTE_MUTE: {
					strcopy(VAR_VOTEMUTE, 32, auth);
					current = GetCountVotes(target, VOTE_MUTE);
					char c_name[32],t_name[32];
					GetClientName(client, c_name, sizeof(c_name));
					GetClientName(target, t_name, sizeof(t_name));
					PrintToChatAll("\x04[GameVoting]\x01 %t", "gv_voted_for_mute", c_name, t_name, current, needed);
					LOGS_ENABLED {
						char auth1[32];
						player_steam(client, auth1, sizeof(auth1)); 
						LogToFile(LogFilePath, "Player %N(%s) voted for mute %N(%s). (%d/%d)",  client, auth1, target, auth, current, needed);
					}
				}

				default: {
					return;
				}
				
			}

			if(current >= needed) {
				DoAction(target, type, client);
			}
			else if(current >= CONVAR_START_VOTE_MIN.IntValue && StartVoteFlag(client)) {
				if(type != VOTE_BAN) {
					ShowMenu(client, type, true);
				}
				else {
					DisplayReasons(client);
				}
			}
		}
	}
}


public bool StartVoteFlag(int client) {

	char s_flag[11];
	GetConVarString(CONVAR_FLAG_START_VOTE, s_flag, sizeof(s_flag));
	if(CONVAR_START_VOTE_ENABLE.IntValue < 1) {
		return false;
	}
	if(g_startvote_delay > GetTime() && CONVAR_START_VOTE_ENABLE.IntValue > 0 ) {
		//PrintToChat(client, "[GameVoting] Please wait %dsec before start public vote.", ((g_startvote_delay)-GetTime()) );
		PrintToChat(client, "\x04[GameVoting]\x01 %t", "gv_wait_before_startvote", ((g_startvote_delay)-GetTime()));
		return false;
	}
	if(strlen(s_flag) < 1) {
		return true;
	}
	int b_flags = ReadFlagString(s_flag);
	if ((GetUserFlagBits(client) & b_flags) == b_flags) {
		return true;
	}
	return false;
}


// Show ban&kick&mute&silence menu
public void ShowMenu(int client, int type, bool startvote_force) {
	VALID_PLAYER {
		if(CountPlayers_withoutImmunity() < 1)
			return;
		VAR_CTYPE = type;
		Menu mymenu;
		if(!startvote_force) {
			mymenu = new Menu(menu_handler);
		}
		else {
			mymenu = new Menu(startvote_menu_player_handler);
		}
		char s_mtitle[48];
		switch(type) {
			case VOTE_BAN: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_ban_title", client);
			}
			case VOTE_KICK: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_kick_title", client);
			}
			case VOTE_MUTE: {
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING - %T", "gv_mute_title", client);
			}
			//case VOTE_SILENCE: {
				//mymenu.SetTitle("GAMEVOTING - SILENCE");
			//}
			default: {
				//mymenu.SetTitle("GAMEVOTING");
				Format(s_mtitle, sizeof(s_mtitle), "GAMEVOTING");
			}	
		}
		
		mymenu.SetTitle(s_mtitle);
		char Name[48], id[11];
		for(int target=0;target<MaxClients;target++) {
			VALID_TARGET {

				if(CONVAR_ONLY_TEAMMATES.IntValue > 0) {
					if(GetClientTeam(target) != GetClientTeam(client)) {
						continue;
					}
				}
			
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
		if(g_startvote_delay > GetTime()) {
			PrintToChat(client, "\x04[GameVoting]\x01 %t", "gv_wait_before_startvote", ((g_startvote_delay)-GetTime()));
			return;
		}

		g_startvote_delay = GetTime() + CONVAR_START_VOTE_DELAY.IntValue;
		
		char s_logs[128];
		char t_name[32];
		GetClientName(target, t_name, sizeof(t_name));
		char c_name[32];
		GetClientName(client, c_name, sizeof(c_name));

		switch(VAR_CTYPE) {
			case VOTE_BAN: {
				char reason[64];
				gReasons.GetString(g_VoteChoise[client].voteban_reason, reason, sizeof(reason));
				PrintToChatAll("\x04[GameVoting]\x01 %t", "gv_startvote_ban", c_name, t_name, reason);
			}
			case VOTE_KICK: {
				char reason[64];
				gReasons.GetString(g_VoteChoise[client].voteban_reason, reason, sizeof(reason));
				PrintToChatAll("\x04[GameVoting]\x01 %t", "gv_startvote_kick", c_name, t_name, reason);
			}
			default: {
			}
		}

		for(int i = 1; i <= MaxClients; i++) {
			if(IsCorrectPlayer(i)) {
				// start vote menus
				Menu mymenu = new Menu(menu_startvote_action_handler);
				char s_typeInitiator[48];
				// client, target, type / explode
				FormatEx(s_typeInitiator,sizeof(s_typeInitiator),"%d|%d|%d",client,target,VAR_CTYPE);
				
				char s_Menu[86];
				

				switch(VAR_CTYPE) {
					case VOTE_BAN: {
						//FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Ban %N?", target);
						char reason[64];
						gReasons.GetString(g_VoteChoise[client].voteban_reason, reason, sizeof(reason));
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_ban_title_question", i, t_name, reason);
						if(strlen(s_logs) < 1) {
							LOGS_ENABLED {
								char auth[32], auth1[32];
								player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
								FormatEx(s_logs, sizeof(s_logs), "Player %N(%s) started public vote for ban %N(%s). Reason = %s",  client, auth,target,auth1,reason);
							}
						}
					}
					case VOTE_KICK: {
						//FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Kick %N?", target);
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_kick_title_question", i, t_name);
						
						if(strlen(s_logs) < 1) {
						LOGS_ENABLED {
							char auth[32],auth1[32];
							player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
							FormatEx(s_logs, sizeof(s_logs), "Player %N(%s) started public vote for kick %N(%s).",  client, auth,target,auth1);
						}
						}
					}
					case VOTE_MUTE: {
						//FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING - Mute %N?", target);
						Format(s_Menu, sizeof(s_Menu), "GAMEVOTING - %T", "gv_mute_title_question", i, t_name);
						
						if(strlen(s_logs) < 1) {
						LOGS_ENABLED {
							char auth[32],auth1[32];
							player_steam(client, auth, sizeof(auth)); player_steam(target, auth1, sizeof(auth1));
							FormatEx(s_logs,sizeof(s_logs), "Player %N(%s) started public vote for mute %N(%s).",  client, auth,target,auth1);
						}
						}
					}
					default: {
						FormatEx(s_Menu,sizeof(s_Menu),"GAMEVOTING?");
						return;
					}	
				}
				
				mymenu.SetTitle(s_Menu);
				mymenu.AddItem("","----", ITEMDRAW_DISABLED);
				mymenu.AddItem("","----", ITEMDRAW_DISABLED);
				Format(s_Menu, sizeof(s_Menu), "%T", "gv_yes", i);
				mymenu.AddItem(s_typeInitiator,s_Menu);
				Format(s_Menu, sizeof(s_Menu), "%T", "gv_no", i);
				mymenu.AddItem("",s_Menu);
				mymenu.Display(i, MENU_TIME_FOREVER);
			}
		}
		
		LOGS_ENABLED {
			LogToFile(LogFilePath, s_logs);
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
		char info[48];
		GetMenuItem(menu, item, info, sizeof(info));
		if(strlen(info) > 0) 
		{
			char ex[3][11];
			ExplodeString(info, "|", ex, 3, 11);
			int target = StringToInt(ex[1]);
			int type = StringToInt(ex[2]);
			VALID_TARGET {
				SetChoise(type, client, target);
			}
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


public void DoAction(int client, int type, int last) {
	
	switch(type) {
		case VOTE_BAN: {
			ClearChoise(client);  // clear votes of players if kick or ban
			ClearVotesForClient(client, VOTE_BAN);
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was banned by voting. (Last voted player: %N)",  client, auth,last);
			}

			char reason[64];
			if(g_VoteChoise[last].voteban_reason > -1) {
				gReasons.GetString(g_VoteChoise[last].voteban_reason, reason, sizeof(reason));
			}
			else {
				strcopy(reason, sizeof(reason), "Empty reason");
			}

			if(is_bansys[BANSYS_SOURCEBANSPP]) 
			{
				char reasonstring[68];
				Format(reasonstring, sizeof(reasonstring), "Gamevoting (%N)(%s)", last, reason);
				SBPP_BanPlayer(0, client, CONVAR_BAN_DURATION.IntValue, reasonstring);
				LOGS_ENABLED {
					LogToFile(LogFilePath, "[sbpp_main.smx] Banning %N player by: SBPP_BanPlayer(0, %d, %d, %s)", client, client, CONVAR_BAN_DURATION.IntValue, reasonstring);
				}
			}
			else if(is_bansys[BANSYS_MADMIN]) 
			{
				char reasonstring[68];
				Format(reasonstring, sizeof(reasonstring), "Gamevoting (%N)(%s)", last, reason);
				MABanPlayer(0, client, 1, CONVAR_BAN_DURATION.IntValue, reasonstring);
				LOGS_ENABLED {
					LogToFile(LogFilePath, "[materialadmin.smx] Banning %N player by: MABanPlayer(0, %d, 1, %d, %s)", client, client, CONVAR_BAN_DURATION.IntValue, reasonstring);
				}
			}
			else 
			{
				ServerCommand("sm_ban #%d %d \"Gamevoting (%N)(%s)\"", GetClientUserId(client), CONVAR_BAN_DURATION.IntValue, last, reason);
				LOGS_ENABLED {
					LogToFile(LogFilePath, "[BaseBans] Server command: sm_ban #%d %d \"Gamevoting (%N)(%s)\"", GetClientUserId(client), CONVAR_BAN_DURATION.IntValue, last, reason);
				}
			}
			/*KickClient(client, "Banned by GameVoting (%s)", reason);*/
		}
		case VOTE_KICK: {
			ClearChoise(client); // clear votes of players if kick or ban
			ClearVotesForClient(client, VOTE_KICK);
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was kicked by voting. (Last voted player: %N)",  client, auth,last);
			}

			PushKickedPlayer(client);
		}
		case VOTE_MUTE: {
			ClearVotesForClient(client, VOTE_MUTE);
			LOGS_ENABLED {
				char auth[32];
				player_steam(client, auth, sizeof(auth));
				LogToFile(LogFilePath, "Player %N(%s) was muted by voting. (Last voted player: %N)",  client, auth,last);
			}
			if(is_bansys[BANSYS_SOURCEBANSPP_COMMS]) {
				char reasonstring[68];
				Format(reasonstring, sizeof(reasonstring), "Muted by Gamevoting (%N)", last);
				SourceComms_SetClientMute(client, true, CONVAR_MUTE_DURATION.IntValue, true, reasonstring);
				SourceComms_SetClientGag(client, true, CONVAR_MUTE_DURATION.IntValue, true, reasonstring);
			}
			else if(is_bansys[BANSYS_MADMIN_COMMS]) {
				char reasonstring[68];
				Format(reasonstring, sizeof(reasonstring), "Muted by Gamevoting (%N)", last);
				MASetClientMuteType(0, client, reasonstring, 5, CONVAR_MUTE_DURATION.IntValue);
				MASetClientMuteType(0, client, reasonstring, 6, CONVAR_MUTE_DURATION.IntValue);
			}
			else {
			 	ServerCommand("sm_silence #%d %d \"Muted by Gamevoting (%N)\"", GetClientUserId(client), CONVAR_MUTE_DURATION.IntValue, last);
			}
		}
	}
	
}