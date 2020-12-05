//#define PLUGIN_DEBUG 1
//#define PLUGIN_DEBUG_MODE 1
#pragma semicolon 1
#pragma newdecls required
#define VERSION "1.9.3"
public Plugin myinfo =
{
	name = "GameVoting",
	author = "Neatek",
	description = "Simple sourcemod plugin for voting",
	version = VERSION,
	url = "https://github.com/neatek/GameVoting"
};
#define REASON_LEN 68
#define EVENT_PARAMS Handle event, const char[] name, bool dontBroadcast
#define VALID_PLAYER if(IsCorrectPlayer(client))
#define VALID_TARGET if(IsCorrectPlayer(target))
#define EVENT_GET_PLAYER GetClientOfUserId(GetEventInt(event, "userid"));
#define VOTE_BAN 1
#define VOTE_KICK 2
#define VOTE_MUTE 3
#define VOTE_SILENCE 4
#define VAR_VOTEBAN g_VoteChoise[client].vbSteam
#define VAR_VOTEKICK g_VoteChoise[client].vkSteam
#define VAR_VOTEMUTE g_VoteChoise[client].vmSteam
#define VAR_VOTESILENCE g_VoteChoise[client].vsSteam
#define VAR_IVOTEBAN g_VoteChoise[i].vbSteam
#define VAR_IVOTEKICK g_VoteChoise[i].vkSteam
#define VAR_IVOTEMUTE g_VoteChoise[i].vmSteam
#define VAR_IVOTESILENCE g_VoteChoise[i].vsSteam
#define VAR_TVOTEBAN g_VoteChoise[target].vbSteam
#define VAR_TVOTEKICK g_VoteChoise[target].vkSteam
#define VAR_TVOTEMUTE g_VoteChoise[target].vmSteam
#define VAR_TVOTESILENCE g_VoteChoise[target].vsSteam
#define VAR_CTYPE g_VoteChoise[client].current_type
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
#define CONVAR_AUTHID_TYPE ConVars[18]
#define CONVAR_ENABLE_LOGS ConVars[19]
#define CONVAR_START_VOTE_MIN ConVars[20]
#define CONVAR_BOT_ENABLED ConVars[21]
#define CONVAR_ONLY_TEAMMATES ConVars[22]
#define LOGS_ENABLED if(strlen(LogFilePath) > 0 && CONVAR_ENABLE_LOGS.IntValue > 0)
#define BANSYS_BASEBANS 0
#define BANSYS_SOURCEBANSPP 1 // Sourcebans++
#define BANSYS_SOURCEBANSPP_COMMS 2  // Sourcebans++ Comms
#define BANSYS_MADMIN 3 // MAdmin
#define BANSYS_MADMIN_COMMS 4 // MAdmin Comms