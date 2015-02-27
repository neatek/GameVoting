Database GVDB;

ConVar cAuth;
ConVar cEnable;
ConVar cDelay;
ConVar cMinimum;
ConVar cLogs;
ConVar cProgress;
ConVar cAdmins;
ConVar cImmunityf;
ConVar cMenuDelay;

ConVar cVoteban;
ConVar cVotekick;
ConVar cVotemute;
ConVar cGag;

ConVar cVkDelay;
ConVar cVkPercent;

ConVar cVbDelay;
ConVar cVbPercent;

ConVar cVmDelay;
ConVar cVmPercent;

ConVar cVgDelay;
ConVar cVgPercent;

ConVar cVersion;

enum gvPlayers {
	// GV ingame lifetime id
	id,
	// for special category, own vote
	voteban_vote,
	votekick_vote,
	votemute_vote,
	votegag_vote,
	// other
	antispam,
	mutetime,
	gagtime,
	kicktime,
	bool:silenced
}

int gvdata[MAXPLAYERS+1][gvPlayers];
bool pEnabled = false;
bool pAdmins = false;
bool hideAdmins = false;
char LogFilePath[128];
new AdminFlag:ImmunityFlag;