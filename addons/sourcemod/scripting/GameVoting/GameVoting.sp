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

	public char getDate() {
		char ftime[24];
		FormatTime(ftime, sizeof(ftime), "[%H-%M-%S]",  GetTime());
		return ftime;
	}
	
	public void setVb(int client, int value) {
		#if defined PLUGIN_DEBUG
			//LogMessage("setVb(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][voteban_vote]);
		#endif
		gvdata[client][voteban_vote] = value;
	}

	public void setVk(int client, int value) {
		#if defined PLUGIN_DEBUG
			//LogMessage("setVk(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][votekick_vote]);
		#endif
		gvdata[client][votekick_vote] = value;
	}
	
	public void setVm(int client, int value) {
		#if defined PLUGIN_DEBUG
			//LogMessage("setVm(%d, NEW_VALUE %d), OLD_VALUE: %d", client, value, gvdata[client][votemute_vote]);
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

	public int getVg(int client) {
		return gvdata[client][votegag_vote];
	}

	public int getAs(int client) {
		return gvdata[client][antispam];
	}
	
	public void setAs(int client, int value) {
		gvdata[client][antispam] = value;
	}

	public void setVg(int client, int value) {
		gvdata[client][votegag_vote] = value;
	}

	public void setVbReason(int client, int value) {
		#if defined PLUGIN_DEBUG
		LogMessage("CLIENT: %i, SET VALUE: %i",client,value);
		#endif
		gvdata[client][voteban_reason] = value;
	}
	
	public int getVbReason(int client) {
		return gvdata[client][voteban_reason];
	}
	
	public void mutestamp(int client, int value) {
		gvdata[client][mutetime] = value;
	}

	public void gagstamp(int client, int value) {
		gvdata[client][gagtime] = value;
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
	
	public bool muted(int client) {
		if(gvdata[client][mutetime] > GetTime()) return true;
		return false;
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

	public void muteplayer(int client, int timestamp) {
		if(player.valid(client)) {
			PrintToChatAll("Player %N was muted by GameVoting.", client);
			PrintToChat(client, "[%s] You was muted.", CHAT_PREFIX);
			if(!cGag.BoolValue) this.silence(client, true); // if gamevoting_votegag -> 0, enable gag
			this.mutestamp(client, timestamp);  // local enum
			CacheMutestamp(client, timestamp);  // sqlite
			SetClientListeningFlags(client, VOICE_MUTED);	
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was muted.",  client, player.steam(client));
		}
	}
	
	public void unmuteplayer(int client) {
		if(player.valid(client)) {
			PrintToChat(client, "[%s] You was unmuted.", CHAT_PREFIX);
			this.silence(client, false);
			this.mutestamp(client, 0);
			SetClientListeningFlags(client, VOICE_NORMAL);
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was unmuted.", client, player.steam(client));
		}
	}
	
	public void gagplayer(int client, int delay) {
		if(player.valid(client)) {
			PrintToChatAll("Player %N was gagged by GameVoting.", client);
			PrintToChat(client, "[%s] You was gagged.", CHAT_PREFIX);
			this.silence(client, true);
			this.gagstamp(client, (GetTime()+delay)); // local enum
			CacheGagstamp(client, (GetTime()+delay)); // sqlite
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was gagged.",  client, player.steam(client));
		}
	}


	
	public void ungagplayer(int client) {
		if(player.valid(client)) {
			PrintToChatAll("Player %N was ungagged by GameVoting.", client);
			PrintToChat(client, "[%s] You was ungagged.", CHAT_PREFIX);
			this.silence(client, false);
			this.gagstamp(client, 0);
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was ungagged.",  client, player.steam(client));
		}
	}
	
	public void checkother(int client)
	{
		// just check kick time
		if(this.getmutestamp(client) > GetTime())
		{
			this.muteplayer(client, (GetTime()+ cVmDelay.IntValue));
		}
		
		if(this.mustkick(client)) {
			int diff = this.kickstamp(client)-GetTime();
			KickClient(client, "Kicked by GameVoting. Wait %d sec",diff);
			if(cLogs.BoolValue) LogToFile(LogFilePath, "Player %N(%s) was autokicked. Need to wait %d before connect.",  client, player.steam(client), diff);
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
			case SQL_VOTEGAG:
			{
				if(!cGag.BoolValue) {
					PrintToChat(client, "[%s] Admins disable votegag command.", CHAT_PREFIX);
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
					//LogMessage("CLIENT: #%d | VICTIM_GID: #%d | VOTEMUTE: #%d", i, this.getId(client), this.getVm(i));
				#endif
			
				switch(category)
				{
					case SQL_VOTEBAN: if(this.getVb(i) == gid) result++;
					case SQL_VOTEMUTE: if(this.getVm(i) == gid) result++;
					case SQL_VOTEKICK: if(this.getVk(i) == gid) result++;
					case SQL_VOTEGAG: if(this.getVg(i) == gid) result++;
				}
			}
		}
				
		#if defined PLUGIN_DEBUG
			LogMessage("numOfVotes(%d, %d) - found: %d", client, category, result);
		#endif
		
		return result;
	}
	
	/*public void setmute(int client, int delay) {

	}*/

	public void setkick(int client, int delay) {
		if(delay > 0) {
			int timestamp = GetTime()+delay;
			char steam[STEAM_SIZE];
			char query[86];
			steam = player.steam(client);
			if(player.vsteam(steam)) {
				Format(query, sizeof(query), SQL_KICKPLAYER, timestamp, steam);

				#if defined PLUGIN_DEBUG
					LogMessage(query);
				#endif

				SQL_TQuery(GVDB, KickCallback, query, client, DBPrio_Normal); 	
			}
		}
	}

	public void VoteFor(int client, int victim, int category)
	{
		//int gid = 0; gid = this.getId(client);
		if(victim == -1 || client == victim) 
		{
			this.resetvotes(client);
			PrintToChat(client, "Vote has been reset.");
			//LogMessage("CLIENT #%d | RESET VOTES.",client);
		} 
		else if(player.valid(victim))
		{
		
		int vid = 0; 
		vid = this.getId(victim);
		if(vid != this.getVb(client)) 
		{
		
		#if defined PLUGIN_DEBUG
			//LogMessage("GV_ID_VICTIM:#%d | GV_ID_CLIENT:#%d (Player %N voting for %N.)", this.getId(client), vid, client, victim);
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

				if(votes < needed) {
					PrintToChatAll("Player %N voted to ban %N (%d/%d)", client, victim, votes, needed );
					
					if(cProgress.BoolValue) {
						if(cLogs.BoolValue) {
							LogToFile(LogFilePath, "Player %N(%s) voted for ban %N(%s) (%d/%d)",client, player.steam(client), victim, player.steam(victim), votes, needed);
						}
					}
				}
				else {
					player.ban(victim, client); 
				}
			}
			case SQL_VOTEMUTE:
			{
				this.setVm(client, vid);
				needed = ((player.num()* cVmPercent.IntValue )/100);
				votes = this.numOfVotes(victim, category);
				if(votes < needed) {
					PrintToChatAll("Player %N voted to mute %N (%d/%d)", client, victim, votes, needed );
					
					if(cProgress.BoolValue) 
						if(cLogs.BoolValue) 
							LogToFile(LogFilePath, "Player %N(%s) voted for mute %N(%s) (%d/%d)",  client, player.steam(client), victim, player.steam(victim), votes, needed);
				}
				else {
					this.muteplayer(victim, (GetTime()+ cVmDelay.IntValue));
				}
			}
			case SQL_VOTEKICK:
			{
				this.setVk(client, vid);
				needed = ((player.num()* cVkPercent.IntValue )/100);
				votes = this.numOfVotes(victim, category);
				
				if(votes < needed) {
					PrintToChatAll("Player %N voted to kick %N (%d/%d)", client, victim, votes, needed );
					
					if(cProgress.BoolValue) 
						if(cLogs.BoolValue) 
							LogToFile(LogFilePath, "Player %N(%s) voted for kick %N(%s) (%d/%d)", client, player.steam(client), victim, player.steam(victim), votes, needed);
					//if(cLogs.BoolValue) LogToFile(LogFilePath, "[%s] Player %N(%s) voted for kick %N(%s) (%d/%d)", this.getDate(), client, player.steam(client), victim, player.steam(victim), votes, needed);
				}
				else {
					this.setkick(victim, cVkDelay.IntValue);
					
				}
			}
			case SQL_VOTEGAG:
			{
				this.setVg(client, vid);
				needed = ((player.num()* cVgPercent.IntValue )/100);
				votes = this.numOfVotes(victim, category);
				
				if(votes < needed) {
					PrintToChatAll("Player %N voted to gag %N (%d/%d)", client, victim, votes, needed );
					
					if(cProgress.BoolValue) 
						if(cLogs.BoolValue)
							LogToFile(LogFilePath, "Player %N(%s) voted for gag %N(%s) (%d/%d)", client, player.steam(client), victim, player.steam(victim), votes, needed);
					//if(cLogs.BoolValue) LogToFile(LogFilePath, "[%s] Player %N(%s) voted for kick %N(%s) (%d/%d)", this.getDate(), client, player.steam(client), victim, player.steam(victim), votes, needed);
				}
				else {
					this.gagplayer(victim, cVgDelay.IntValue);
				}
			}
		}
		
		} 
		#if defined PLUGIN_DEBUG
		//else LogMessage("GV_ID_CLIENT == GV_ID_VICTIM;");
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
			case SQL_VOTEGAG: existsvote = this.getVg(client);
		}
	
		char buff[48];
		char num[11];
		for(int i=0; i < MaxClients; ++i)
		{
			#if defined PLUGIN_DEBUG
			if(player.valid(i) && i != client)
			#else
			if(player.valid(i))
			#endif
			{
				switch(hideAdmins)
				{
					case false: { // its exists vote
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
					case true: {
						if(!player.immunity(i)) {
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
		}
	}
}

WorkingWithGameVoting gv;
