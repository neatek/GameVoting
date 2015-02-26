Plugin_ConVars() {
	// general
	cVersion  	= CreateConVar("gamevoting_version",	"1.7",	"Version of gamevoting plugin. Author: Neatek, www.neatek.ru", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY );
	cEnable  	= CreateConVar("gamevoting_enable",		"1",	"Enable or disable plugin (def:1)", _, true, 0.0, true, 1.0);
	cLogs  		= CreateConVar("gamevoting_logs",		"1",	"Enable or disable logs for plugin (def:1)", _, true, 0.0, true, 1.0);
	cProgress  	= CreateConVar("gamevoting_progress",	"1",	"Do you want to log voting progress? (def:1)", _, true, 0.0, true, 1.0);
	cAdmins  	= CreateConVar("gamevoting_autodisable","0",	"Disable plugin when admins on server? (def:0)", _, true, 0.0, true, 1.0);
	cDelay		= CreateConVar("gamevoting_delay",		"10",	"Delay before vote again for other player (def:10)", _, true, 0.0, true, 120.0);
	cMinimum 	= CreateConVar("gamevoting_players",	"4",	"Minimum players need to enable votes (def:4)", _, true, 0.0, true, 20.0);
	cAuth 		= CreateConVar("gamevoting_authid",		"1",	"AuthID type, 1 - AuthId_Engine, 2 - AuthId_Steam2, 3 - AuthId_Steam3, 4 - AuthId_SteamID64 (def:1)", _, true, 1.0, true, 4.0);
	// functional control
	cVoteban 	= CreateConVar("gamevoting_voteban",	"1",	"Enable or disable voteban functional (def:1)", _, true, 0.0, true, 1.0);
	cVotekick 	= CreateConVar("gamevoting_votekick",	"1",	"Enable or disable votekick (def:1)", _, true, 0.0, true, 1.0);
	cVotemute	= CreateConVar("gamevoting_votemute",	"1",	"Enable or disable votemute (def:1)", _, true, 0.0, true, 1.0);
	// voteban config
	cVbDelay 	= CreateConVar("gamevoting_voteban_delay",		"120",	"Ban duration in minutes (def:120)", _, true, 0.0, false);
	cVbPercent 	= CreateConVar("gamevoting_voteban_percent",	"80",	"Needed percent of players for ban someone (def:80)", _, true, 0.0, false);
	// votekick config
	cVkDelay 	= CreateConVar("gamevoting_votekick_delay",		"60",	"Kick duration in seconds (def:60)", _, true, 0.0, false);
	cVkPercent 	= CreateConVar("gamevoting_votekick_percent",	"80",	"Needed percent of players for kick someone (def:80)", _, true, 0.0, false);
	// votemute config
	cVmDelay 	= CreateConVar("gamevoting_votemute_delay",		"1800",	"Mute duration in seconds (def:1800)", _, true, 0.0, false);
	cVmPercent 	= CreateConVar("gamevoting_votemute_percent",	"75",	"Needed percent of players for mute someone (def:75)", _, true, 0.0, false);
	
	AutoExecConfig(true, "Gamevoting");
	
	HookConVarChange(cVersion, ConVarChanged);
	HookConVarChange(cEnable, ConVarChanged);
}
	
public OnConfigsExecuted()
{
	if(GetConVarBool(cEnable)) pEnabled = true;
}

public ConVarChanged(Handle:hCVar, const String:strOld[], const String:strNew[])
{
	char buff[48];
	GetConVarName(hCVar, buff, sizeof(buff));
	LogMessage("ConVar %s changed from %s to %s", buff, strOld, strNew);
	if(GetConVarBool(cEnable)) pEnabled = true;
	SetConVarFloat(cVersion, 1.7, true, true);
}