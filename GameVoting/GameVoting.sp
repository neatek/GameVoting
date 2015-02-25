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
			LogMessage("setVb(%d, %d), old_value: %d", client, value, gvdata[client][voteban_vote]);
		#endif
		gvdata[client][voteban_vote] = value;
	}
	
	public void setVk(int client, int value) {
		gvdata[client][votekick_vote] = value;
	}
	
	public void setVm(int client, int value) {
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
	
	public bool allowcmd(int client) {
		if(this.getAs(client) < GetTime()) return true;
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
	}
	
	public void displaydata(int client) {
		LogMessage("WorkingWithGameVoting.displaydata # Id(%i), Voteban(%i), Votekick(%i), Votemute(%i)", this.getId(client), this.getVb(client), this.getVk(client), this.getVm(client));
	}
	
	public void checkkick(int client)
	{
		// just check kick time
	}
	
	public bool VoteEnabled(int client, int category) {
		switch(category)
		{
			case SQL_VOTEBAN: 
			{
				if(!GetConVarBool(cVoteban)) {
					PrintToChat(client, "[%s] Admins disable voteban command.", CHAT_PREFIX);
					return false;
				}
			}
			case SQL_VOTEMUTE:
			{
				if(!GetConVarBool(cVotemute)) {
					PrintToChat(client, "[%s] Admins disable votemute command.", CHAT_PREFIX);
					return false;
				}
			}
			case SQL_VOTEKICK:
			{
				if(!GetConVarBool(cVotekick)) {
					PrintToChat(client, "[%s] Admins disable votekick command.", CHAT_PREFIX);
					return false;
				}
			}
		}
		
		return true;
	}
	
	public int numOfVotes(int client, int category) {
		#if defined PLUGIN_DEBUG
			//LogMessage("Parse players data - gid #%d", gid);
			this.displaydata(client);
		#endif
	
		int gid = 0;
		gid = this.getId(client);
		int result = 0;
				
		for(int i=0; i < MaxClients; ++i)
		{
			if(player.valid(i))
			{
				#if defined PLUGIN_DEBUG
					// analys
					LogMessage("CLIENT: #%d | VICTIM_GID: #%d | VOTEBAN: #%d", i, this.getId(client), this.getVb(i));
				#endif
			
				switch(category)
				{
					case SQL_VOTEBAN: 
					{
						if(this.getVb(i) == gid) 
						{
							result++;
						}
					}
					case SQL_VOTEMUTE:
					{
						if(this.getVm(i) == gid) 
						{
							#if defined PLUGIN_DEBUG
								//LogMessage("client#%d, votemute_vote#%d, searching for %d...", i, this.getVm(i), gid);
							#endif
							
							result++;
						}
					}
					case SQL_VOTEKICK:
					{
						if(this.getVk(i) == gid) 
						{
							#if defined PLUGIN_DEBUG
								//LogMessage("client#%d, votekick_vote#%d, searching for %d...", i, this.getVk(i), gid);
							#endif
							
							result++;
						}
					}
				}
			}
		}
				
		#if defined PLUGIN_DEBUG
			LogMessage("numOfVotes(%d, %d) - found: %d", client, category, result);
		#endif
		
		return result;
	}
	
	public void VoteFor(int client, int victim, int category)
	{
		//int gid = 0; gid = this.getId(client);
		if(victim == -1 || !player.valid(victim) || client == victim) {
			this.resetvotes(client);
			PrintToChat(client, "Vote has been reset.");
		} else {
		
		int vid = 0; 
		vid = this.getId(victim);
		if(vid != this.getVb(client)) {
		
		#if defined PLUGIN_DEBUG
			LogMessage("Player %N voting for %N. (client:#%d,victim:#%d)", client, victim, this.getId(client), vid);
		#endif

		int needed = 0;
		int votes = this.numOfVotes(victim, category);
		
		switch(category)
		{
			// COPYPAST!
			case SQL_VOTEBAN: 
			{
				this.setVb(client, vid);
				needed = ((player.num()*GetConVarInt(cVbPercent))/100);
				if(votes < needed) PrintToChatAll("Player %N voted to ban %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was banned by GameVoting. (Reason: Justice of players)");
				}
			}
			case SQL_VOTEMUTE:
			{
				this.setVm(client, vid);
				needed = ((player.num()*GetConVarInt(cVkPercent))/100);
				if(votes < needed) PrintToChatAll("Player %N voted to mute %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was muted by GameVoting.");
				}
			}
			case SQL_VOTEKICK:
			{
				this.setVk(client, vid);
				needed = ((player.num()*GetConVarInt(cVmPercent))/100);
				if(votes < needed)
					PrintToChatAll("Player %N voted to kick %N (%d/%d)", client, victim, votes, needed );
				else {
					PrintToChatAll("Player %N was kicked by GameVoting.");
				}
			}
		}
		
		}
		}
	}
	
	public void FillPlayers(Menu handle, int client, int category) {
		// detect exists vote
		int existsvote = -1;
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
					Format(buff, sizeof(buff), "%N (voted)", i);
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