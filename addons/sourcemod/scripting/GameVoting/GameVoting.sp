/*
	setId(int client, int value)
	int getId(int client)

	setVb(int client, int value), int getVb(int client)
	setVk(int client, int value), int getVk(int client)
	setVm(int client, int value), int getVm(int client)
	setAs(int client, int value), int getAs(int client)

	resetvotes(int client)
	reset(int client) - include ID

	displaydata(int client) - ENUM display

	VoteFor(int client, int victim, int category)
	int numOfVotes(int client, int category)
*/

methodmap WorkingWithGameVoting
{
	public void setId(int client, int value) {
		gvdata[client][id] = value;
	}

	public void setVb(int client, int value) {
		#if defined PLUGIN_DEBUG
			LogMessage("setVb(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][voteban_vote]);
		#endif
		gvdata[client][voteban_vote] = value;
	}
	
	public void setVk(int client, int value) {
		#if defined PLUGIN_DEBUG
			LogMessage("setVk(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][votekick_vote]);
		#endif
		gvdata[client][votekick_vote] = value;
	}
	
	public void setVm(int client, int value) {
		#if defined PLUGIN_DEBUG
			LogMessage("setVm(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][votemute_vote]);
		#endif
		gvdata[client][votemute_vote] = value;
	}

	public int getId(int client) {
		return  gvdata[client][id];
	}
	
	public int getVb(int client) {
		return  gvdata[client][voteban_vote];
	}
	
	public int getVk(int client) {
		return  gvdata[client][votekick_vote];
	}
	
	public int getVm(int client) {
		return gvdata[client][votemute_vote];
	}

	public int getAs(int client) {
		return gvdata[client][antispam];
	}
	
	public void setAs(int client, int value) {
		gvdata[client][antispam] = value;
	}
	
	public void mutestamp(int client, int value) {
		gvdata[client][mutetime] = value;
	}
	
	public int getmutestamp(int client) {
		return gvdata[client][mutetime];
	}
	
	public void silence(int client, bool value) {
		gvdata[client][silenced] = value;
	}
	
	public bool silenced(int client) {
		return gvdata[client][silenced];
	}
	
	public bool allowcmd(int client) {
		if(this.getAs(client) < GetTime()) return true;
		return false;
	}
	
	public void setkickstamp(int client, int stamp){
		gvdata[client][kicktime] = stamp;
	}
	
	public int kickstamp(int client) {
		return gvdata[client][kicktime];
	}
	
	public bool mustkick(int client) {
		if(this.kickstamp(client) > GetTime()) return true;
		return false;
	}
	
	public void resetvotes(int client)
	{
		this.setVb(client, -1);
		this.setVk(client, -1);
		this.setVm(client, -1);
	}
	
	public void reset(int client)
	{
		this.setId(client, -1);
		this.resetvotes(client);
		this.setAs(client, 0);
		this.silence(client, false);
		this.mutestamp(client, 0);
	}
	
	public void displaydata(int client) {
		LogMessage("WorkingWithGameVoting.displaydata # Id(%i), Voteban(%i), Votekick(%i), Votemute(%i)", this.getId(client), this.getVb(client), this.getVk(client), this.getVm(client));
	}
	
	public void muteplayer(int client) {
		this.silence(client, true);
		this.mutestamp(client, (GetTime()+ cVmDelay.IntValue));
		SetClientListeningFlags(client, VOICE_MUTED);
	}
	
	public void checkother(int client)
	{
		// just check kick time
		if(this.getmutestamp(client) > GetTime())
		{
			this.muteplayer(client);
		}
		
		if(this.mustkick(client)) {
			int diff = this.kickstamp(client)-GetTime();
			KickClient(client, "Kicked by GameVoting. Wait %d sec",diff);
		}
	}
	
	public bool VoteEnabled(int client, int category) {
		switch(category)
		{
			case SQL_VOTEBAN: 
			{
				if(!cVoteban.BoolValue) {
					PrintToChat(client, "[%s] Admins disable voteban command.", CHAT_PREFIX);
					return false;
				}
			}
			case SQL_VOTEMUTE:
			{
				if(!cVotemute.BoolValue) {
					PrintToChat(client, "[%s] Admins disable votemute command.", CHAT_PREFIX);
					return false;
				}
			}
			case SQL_VOTEKICK:
			{
				if(!cVotekick.BoolValue) {
					PrintToChat(client, "[%s] Admins disable votekick command.", CHAT_PREFIX);
					return false;
				}
			}
		}
		
		return true;
	}
	
	public int numOfVotes(int client, int category) {
		int gid = 0;
		gid = this.getId(client);
		int result = 0;
		for(int i=0; i < GetMaxClients(); ++i)
		{
			if(player.valid(i))
			{
				#if defined PLUGIN_DEBUG
					LogMessage("CLIENT: #%d | VICTIM_GID: #%d | VOTEMUTE: #%d", i, this.getId(client), this.getVm(i));
				#endif
			
				switch(category)
				{
					case SQL_VOTEBAN: if(this.getVb(i) == gid) result++;
					case SQL_VOTEMUTE: if(this.getVm(i) == gid) result++;
					case SQL_VOTEKICK: if(this.getVk(i) == gid) result++;
				}
			}
		}
				
		#if defined PLUGIN_DEBUG
			LogMessage("numOfVotes(%d, %d) - found: %d", client, category, result);
		#endif
		
		return result;
	}
	
	public void setmute(int client, int delay) {
		int timestamp = GetTime()+delay;
		char steam[STEAM_SIZE];
		char query[86];
		steam = player.steam(client);
		if(player.vsteam(steam)) {
			Format(query, sizeof(query), SQL_MUTEPLAYER, timestamp, steam);

			#if defined PLUGIN_DEBUG
				LogMessage(query);
			#endif

			SQL_TQuery(GVDB, Empty_Callback, query, client, DBPrio_Normal); 
		}
	}

	public void setkick(int client, int delay) {
		int timestamp = GetTime()+delay;
		char steam[STEAM_SIZE];
		char query[86];
		steam = player.steam(client);
		if(player.vsteam(steam)) {
			Format(query, sizeof(query), SQL_KICKPLAYER, timestamp, steam);

			#if defined PLUGIN_DEBUG
				LogMessage(query);
			#endif

			SQL_TQuery(GVDB, Empty_Callback, query, client, DBPrio_Normal); 
		}
	}
	
	
	public void VoteFor(int client, int victim, int category)
	{
		//int gid = 0; gid = this.getId(client);
		if(victim == -1 || client == victim) 
		{
			this.resetvotes(client);
			PrintToChat(client, "Vote has been reset.");
			LogMessage("CLIENT #%d | RESET VOTES.",client);
		} 
		else if(player.valid(victim))
		{
		
		int vid = 0; 
		vid = this.getId(victim);
		if(vid != this.getVb(client)) 
		{
		
		#if defined PLUGIN_DEBUG
			LogMessage("GV_ID_VICTIM:#%d | GV_ID_CLIENT:#%d (Player %N voting for %N.)", this.getId(client), vid, client, victim);
		#endif

		int needed = 0;
		int votes = 0;
		switch(category)
		{
			// COPYPAST!
			case SQL_VOTEBAN: 
			{
				this.setVb(client, vid);
				needed = ((player.num() * cVbPercent.IntValue) / 100);
				votes = this.numOfVotes(victim, category);
				
				if(votes < needed) PrintToChatAll("Player %N voted to ban %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was banned by GameVoting. (Reason: Justice of players)", victim);
					player.ban(victim, client); 
				}
			}
			case SQL_VOTEMUTE:
			{
				this.setVm(client, vid);
				needed = ((player.num()* cVkPercent.IntValue )/100);
				votes = this.numOfVotes(victim, category);
				
				if(votes < needed) PrintToChatAll("Player %N voted to mute %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was muted by GameVoting.", victim);
					this.muteplayer(victim); 
				}
			}
			case SQL_VOTEKICK:
			{
				this.setVk(client, vid);
				needed = ((player.num()* cVmPercent.IntValue )/100);
				votes = this.numOfVotes(victim, category);
				
				if(votes < needed)
					PrintToChatAll("Player %N voted to kick %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was kicked by GameVoting.", victim);
					this.setkick(client, cVkDelay.IntValue);
					KickClient(client, "Kicked by GameVoting. Wait %d sec",cVkDelay.IntValue);
					// done
				}

			}
		}
		
		} 
		#if defined PLUGIN_DEBUG
		else LogMessage("GV_ID_CLIENT == GV_ID_VICTIM;");
		#endif
		}
	}
	
	public void FillPlayers(Menu handle, int client, int category) {
		// detect exists vote
		int existsvote = 0;
		switch(category) {
			case SQL_VOTEBAN: existsvote = this.getVb(client);
			case SQL_VOTEKICK: existsvote = this.getVk(client);
			case SQL_VOTEMUTE: existsvote = this.getVm(client);
		}
	
		char buff[48];
		char num[11];
		for(int i=0; i < MaxClients; ++i)
		{
			if(player.valid(i))
			{
				// its exists vote
				if(this.getId(i) == existsvote) {
					Format(buff, sizeof(buff), "%N (x)", i);
					IntToString(i, num, sizeof(num));
					AddMenuItem(handle, num, buff, ITEMDRAW_DEFAULT);
				}
				else {
					Format(buff, sizeof(buff), "%N", i);
					IntToString(i, num, sizeof(num));
					AddMenuItem(handle, num, buff, ITEMDRAW_DEFAULT);
				}
			}
		}
	}
}

WorkingWithGameVoting gv;