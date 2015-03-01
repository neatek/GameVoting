methodmap WorkingWithDatabase
{
	public void regplayer(int client)
	{
		if(player.valid(client)) {
			#if defined PLUGIN_DEBUG
				LogMessage("db.regplayer(%d)", client);
			#endif
			char steam[STEAM_SIZE];
			char query[86];
			steam = player.steam(client);
			if(player.vsteam(steam)) {
				Format(query, sizeof(query), SQL_REGPLAYER, steam);
				
				#if defined PLUGIN_DEBUG
					LogMessage(query);
				#endif
				
				SQL_TQuery(GVDB, RegPlayer_Callback, query, client, DBPrio_Normal); 
			}
		}
	}
	
	public void mutestamp(int client, int timestamp)
	{
		if(player.valid(client)) {
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
	}

	public void gagstamp(int client, int timestamp)
	{
		if(player.valid(client)) {
		char steam[STEAM_SIZE];
		char query[86];
		steam = player.steam(client);
		if(player.vsteam(steam)) {
			Format(query, sizeof(query), SQL_GAGPLAYER, timestamp, steam);

			#if defined PLUGIN_DEBUG
				LogMessage(query);
			#endif

			SQL_TQuery(GVDB, Empty_Callback, query, client, DBPrio_Normal); 
		}
		}
	}

	public void loadplayer(int client) {
		if(player.valid(client)) {
		gv.reset(client);
		
		#if defined PLUGIN_DEBUG
			LogMessage("db.loadplayer(%d)", client);
		#endif

		char steam[STEAM_SIZE];
		char query[86];
		steam = player.steam(client);
		if(player.vsteam(steam)) {
			Format(query, sizeof(query), SQL_GETPLAYER, steam);

			#if defined PLUGIN_DEBUG
				LogMessage(query);
			#endif
			
			SQL_TQuery(GVDB, LoadPlayer_Callback, query, client, DBPrio_Normal); 
		}
		}
	}

	public void connect() 
	{
		// Check SQLConfig
		if(!SQL_CheckConfig(SQL_CONFIG)) SetFailState("Failed to load database configuration '%s', please check databases.cfg", SQL_CONFIG);
		
		// Do SQL_Connect
		char error[48];
		GVDB = SQL_Connect(SQL_CONFIG, true, error, sizeof(error));
		GVDB.SetCharset("utf8");
		
		// If we got error
		if(strlen(error) > 0) SetFailState("Database error: %s", error);	
		
		// Insert tables
		#if defined PLUGIN_DEBUG
		LogMessage(SQL_PLAYERS);
		#endif

		if(!SQL_FastQuery(GVDB, SQL_PLAYERS))
		{
			// If we got sql error
			if(SQL_GetError(GVDB, error, sizeof(error))) SetFailState("Database error: %s", error);
		}
	}
}

WorkingWithDatabase db;