public void register_ConVars() {
	// Global
	CONVAR_VERSION = CreateConVar("sm_gamevoting_version", VERSION, "Version of gamevoting plugin. DISCORD - https://discord.gg/J7eSXuU , Author: Neatek, www.neatek.ru", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	CONVAR_ENABLED = CreateConVar("gamevoting_enable", "1", "Enable/Disable plugin (def:1)", _, true, 0.0, true, 1.0);	
	CONVAR_AUTHID_TYPE = CreateConVar("gamevoting_authid", "1", "AuthID type, 1 - AuthId_Engine, 2 - AuthId_Steam2, 3 - AuthId_Steam3, 4 - AuthId_SteamID64 (def:1)", _, true, 1.0, true, 4.0);
	CONVAR_ENABLE_LOGS = CreateConVar("gamevoting_logs",	 "1", "Enable/Disable logs for plugin (def:1)", _, true, 0.0, true, 1.0);
	// Min players
	CONVAR_MIN_PLAYERS = CreateConVar("gamevoting_players",	"8", "Minimum players need to enable votes (def:8)", _, true, 0.0, true, 20.0);
	CONVAR_AUTODISABLE = CreateConVar("gamevoting_autodisable","0", "Disable plugin when admins on server? (def:0)", _, true, 0.0, true, 1.0);
	// Disables
	CONVAR_BAN_ENABLE = CreateConVar("gamevoting_voteban",	"1", "Enable or disable voteban functional (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_KICK_ENABLE = CreateConVar("gamevoting_votekick",	"1", "Enable/Disable votekick (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_MUTE_ENABLE = CreateConVar("gamevoting_votemute",	"1", "Enable/Disable votemute (def:1)", _, true, 0.0, true, 1.0);
	//CONVAR_SILENCE_ENABLE = CreateConVar("gamevoting_votesilence",	"1",	"Enable or disable silence (def:1)", _, true, 0.0, true, 1.0);
	// Durations
	CONVAR_BAN_DURATION = CreateConVar("gamevoting_voteban_delay", "20", "Ban duration in minutes (def:120)", _, true, 1.0, false);
	CONVAR_KICK_DURATION = CreateConVar("gamevoting_votekick_delay", "20", "Kick duration in seconds (def:20)", _, true, 1.0, false);
	CONVAR_MUTE_DURATION = CreateConVar("gamevoting_votemute_delay", "20", "Mute duration in minutes (def:120)", _, true, 1.0, false);
	//CONVAR_SILENCE_DURATION = CreateConVar("gamevoting_votesilence_delay", "1", "Mute duration in minutes (def:120)", _, true, 0.0, false);
	// Percent
	CONVAR_BAN_PERCENT = CreateConVar("gamevoting_voteban_percent",	"80", "Needed percent of players for ban someone (def:80)", _, true, 1.0, true, 100.0);
	CONVAR_KICK_PERCENT = CreateConVar("gamevoting_votekick_percent", "80", "Needed percent of players for kick someone (def:80)", _, true, 1.0, true, 100.0);
	CONVAR_MUTE_PERCENT = CreateConVar("gamevoting_votemute_percent", "75", "Needed percent of players for mute someone (def:75)", _, true, 1.0, true, 100.0);
	//CONVAR_SILENCE_PERCENT = CreateConVar("gamevoting_votesilence_percent",	 "75",	"Needed percent of players for silence someone (def:75)", _, true, 0.0, true, 100.0);
	// ImmunityFlags
	CONVAR_IMMUNITY_FLAG = CreateConVar("gamevoting_immunity_flag",	"a", "Immunity flag from all votes, set empty for disable immunity (def:a)");
	CONVAR_IMMUNITY_zFLAG = CreateConVar("gamevoting_immunity_zflag", "1", "Immunity for admin flag \"z\"");
	// StartVote
	CONVAR_START_VOTE_ENABLE = CreateConVar("gamevoting_startvote_enable", "1", "Disable/Enable public votes (def:1)", _, true, 0.0, true, 1.0);
	CONVAR_FLAG_START_VOTE = CreateConVar("gamevoting_startvote_flag", "", "Who can start voting for ban or something, set empty for all players (def:a)");
	CONVAR_START_VOTE_DELAY = CreateConVar("gamevoting_startvote_delay", "20", "Delay between public votes in seconds (def:20)", _, true, 5.0, false);
	CONVAR_START_VOTE_MIN = CreateConVar("gamevoting_startvote_min", "4", "Minimum players for start \"startvote\" feature (def:4)", _, true, 2.0);
	CONVAR_BOT_ENABLED = CreateConVar("gamevoting_bots_enabled", "0", "Disable/Enable bots in votes (def:0)", _, true, 0.0, true, 1.0);
	CONVAR_ONLY_TEAMMATES = CreateConVar("gamevoting_only_teammates", "0", "Disable/Enable only teammates in votes (def:0)", _, true, 0.0, true, 1.0);
	// Listeners
	AddCommandListener(OnClientCommands, "say");
	AddCommandListener(OnClientCommands, "say_team");
	// Configs&Translations
	AutoExecConfig(true, "gamevoting");
	LoadTranslations("gamevoting.phrases");
}