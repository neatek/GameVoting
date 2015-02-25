#include <sdktools>
#include "GameVoting/Defines.sp"
#include "GameVoting/Variables.sp"
#include "GameVoting/Players.sp"
#include "GameVoting/GameVoting.sp" 
#include "GameVoting/Database.sp"
#include "GameVoting/Callbacks.sp" 
#include "GameVoting/ConVars.sp"
#include "GameVoting/Listener.sp"
#include "GameVoting/Functions.sp"

public OnPluginStart()
{
	db.connect();
	Plugin_ConVars();
	AddCommandListener(Listener, SAYCMD);
	AddCommandListener(Listener, SAYCMD2);
	HookEvent("player_death", PlayerDeath_Event);
}

public Action:PlayerDeath_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	// testing on bots
	if(!pEnabled) return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	gv.VoteFor(client, attacker, SQL_VOTEMUTE);
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