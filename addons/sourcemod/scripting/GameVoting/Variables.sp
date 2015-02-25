Database GVDB;

ConVar cVersion;
ConVar cEnable;
ConVar cDelay;
ConVar cMinimum;

ConVar cVoteban;
ConVar cVotekick;
ConVar cVotemute;

ConVar cVkDelay;
ConVar cVkPercent;

ConVar cVbDelay;
ConVar cVbPercent;

ConVar cVmDelay;
ConVar cVmPercent;

enum gvPlayers {
	// GV ingame lifetime id
	id,
	// for special category, own vote
	voteban_vote,
	votekick_vote,
	votemute_vote,
	// other
	antispam,
	mutetime,
	kicktime,
	bool:silenced
}

int gvdata[MAXPLAYERS+1][gvPlayers];
bool pEnabled = false;