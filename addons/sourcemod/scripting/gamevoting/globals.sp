bool is_bansys[5];

int g_startvote_delay = 0;

char LogFilePath[512];

ConVar ConVars[23];

ArrayList gReasons;

enum struct ENUM_VOTE_CHOISE
{
	int current_type;
	int voteban_reason;
	char vbSteam[32];
	char vkSteam[32];
	char vmSteam[32];
	char vsSteam[32];
}
ENUM_VOTE_CHOISE g_VoteChoise[MAXPLAYERS+1];

enum struct ENUM_KICKED_PLAYERS
{
	int time;
	char Steam[32];
}
ENUM_KICKED_PLAYERS g_KickedPlayers[MAXPLAYERS+1];

