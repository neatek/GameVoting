// www.sourcemodplugins.org/smlib/
String_ToLower(const String:input[], String:output[], size)
{
	size--;

	int x=0;
	while (input[x] != '\0' || x < size) {
		
		if (IsCharUpper(input[x])) {
			output[x] = CharToLower(input[x]);
		}
		else {
			output[x] = input[x];
		}
		
		x++;
	}

	output[x] = '\0';
}

LoadImmunityFlags() {
	new String:ichar[11];
	cImmunityf.GetString(ichar,sizeof(ichar));
	if(BitToFlag(ReadFlagString(ichar), ImmunityFlag))
		// hide admins with this flag
		//cImmunity.SetString("0", true, true);
		hideAdmins = true;
	else // else display all admins
		//cImmunity.SetString("1", true, true);
		hideAdmins = false;

	cVoting.GetString(ichar,sizeof(ichar));
	if(strlen(ichar) > 0 && !StrEqual(ichar,"0")) {
		BitToFlag(ReadFlagString(ichar), VotingFlag);
		votingForAll = false;
		#if defined PLUGIN_DEBUG
		LogMessage("VOTING ENABLED FOR PRIVATE PEOPLE, FLAG: '%s'", ichar);
		#endif
	}
	else {
		#if defined PLUGIN_DEBUG
		LogMessage("VOTING ENABLED FOR ALL");
		#endif
		votingForAll = true;
	}
}

bool:EnabledVoting(client) {
	if(votingForAll) {
		#if defined PLUGIN_DEBUG
		LogMessage("VOTING ENABLED FOR ALL");
		#endif
		return true;
	}

	#if defined PLUGIN_DEBUG
	LogMessage("VOTING ENABLED FOR PRIVATE PEOPLE");
	#endif

	AdminId AdmID = GetUserAdmin(client);
	if(AdmID != INVALID_ADMIN_ID) {
		if(GetAdminFlag(AdmID, VotingFlag, Access_Real)) {
			#if defined PLUGIN_DEBUG
			LogMessage("VOTING_FLAG FOUND!");
			#endif
			return true;
		}
		else if(GetAdminFlag(AdmID, VotingFlag, Access_Effective)) {
			#if defined PLUGIN_DEBUG
			LogMessage("VOTING_FLAG FOUND!");
			#endif
			return true;
		}
	} 
	#if defined PLUGIN_DEBUG
	else {
		LogMessage("INVALID_ADMIN");
	}
	#endif	

	
	return false;
}

CacheMutestamp(int client, int time) {
	db.mutestamp(client,time);
}

CacheGagstamp(int client, int time) {
	db.gagstamp(client,time);
}

GVInitLog() {
	char ftime[32];
	FormatTime(ftime, sizeof(ftime), "logs/gv%m-%d.txt",  GetTime());
	BuildPath(Path_SM, LogFilePath, sizeof(LogFilePath), ftime);
	//Format(LogFilePath, sizeof(LogFilePath), "%s%s",LogFilePath,ftime);
	#if defined PLUGIN_DEBUG
	LogMessage("log file for GameVoting: %s", LogFilePath);
	#endif
	//GVLog = OpenFile(LogFilePath, "a+");
}

stock readReasons() {
	LogMessage("LOADED REASONS ===============");

	
	// max reasons
	int sSize = ((gReasons.Length)-1);
	char buff[REASON_LEN];
	LogMessage("SIZE: %d",sSize);
	for(int i = 0; i <= sSize; i++) {
		gReasons.GetString(i, buff, sizeof(buff))
		LogMessage("NUM: %d | %s",i, buff);
	}
	
	LogMessage("LOADED REASONS ===============");
}

loadReasons() {
	if(gReasons != null) gReasons.Clear();
	char fFile[86];
	BuildPath(Path_SM, fFile, sizeof(fFile), "configs/gvreasons.txt");
	if(FileExists(fFile))
	{
		File oFile = OpenFile(fFile,"r");
		if(oFile == null) SetFailState("I can't open file: addons/sourcemod/configs/gvreasons.txt");
		if(FileSize(fFile) < 5) SetFailState("Please, fill this file: addons/sourcemod/configs/gvreasons.txt");
		char buff[REASON_LEN];
		int oLines = 1;
		gReasons = new ArrayList(REASON_LEN, 0);
		while(!IsEndOfFile(oFile))
		{
			if(!ReadFileLine(oFile,buff,REASON_LEN)) {
				//SetFailState("I can't read file: addons/sourcemod/configs/gvreasons.txt");
				continue;
			}
				
			TrimString(buff);
			if(strlen(buff) > 3)
			{
				#if defined PLUGIN_DEBUG
				LogMessage("Push reason: %s", buff);
				#endif
				gReasons.PushString(buff);
				oLines++;
				//gReasons.Resize(oLines);
			}
			else
			{
				LogError("Can't add reason: %s, because its smaller than 3 letters. (LINE: %d)", buff, oLines);
			}
		}
		
		oFile.Close();
	}
	else
		SetFailState("Please, create file in directory: addons/sourcemod/configs/gvreasons.txt, with reasons on one line!");
		
	// result
	#if defined PLUGIN_DEBUG
	readReasons();
	#endif
}

DisplayReasons(client) {
	Menu mReasons = CreateMenu(MenuHandler_Reason, MenuAction:MENU_NO_PAGINATION);
	SetMenuTitle(mReasons, "GameVoting - Reason");

	int sSize = ((gReasons.Length)-1);
	char buff[REASON_LEN];
	char buff2[18];
	for(int i = 0; i <= sSize; i++) {
		gReasons.GetString(i, buff, sizeof(buff))
		IntToString(i, buff2, sizeof(buff2));
		AddMenuItem(mReasons, buff2, buff, ITEMDRAW_DEFAULT);
	}

	DisplayMenu(mReasons, client, cMenuDelay.IntValue);
}

public CheckChat(client) {
	if(!EnabledVoting(client))
	{
		PrintToChat(client, "[%s] Only private people can do vote.", CHAT_PREFIX);
		return true;
	}
	
	if(!pEnabled) {
		PrintToChat(client, "[%s] Admins disable this plugin.", CHAT_PREFIX);
		return true;
	}

	// admins on server
	if(cAdmins.BoolValue && pAdmins) {
		PrintToChat(client, "[%s] Admins disable this plugin.", CHAT_PREFIX);
		return true;
	}
	
	// Antispam
	if(!gv.allowcmd(client)) {
		int sec = gv.getAs(client)-GetTime();
		PrintToChat(client, "[%s] Stop spam, wait %d sec.", CHAT_PREFIX, sec);
		return true;
	}

	// Check minimum players
	if(player.num() < cMinimum.IntValue) {
		PrintToChat(client, "[%s] Sorry, but need more than %d players for votes.", CHAT_PREFIX, (cMinimum.IntValue-1));
		return true;
	}
	
	return false;
}

public int mostReason(int client) {
	int gid = 0;
	gid = gv.getId(client);
		
	#if defined PLUGIN_DEBUG
	char rSon[REASON_LEN];
	LogMessage(">>> MODULE REASON ARRAY");
	#endif 

	// module array reasons
	ArrayList someArray = CreateArray();
	for(int i = 0; i <= ((gReasons.Length)-1); i++) {
		someArray.Push(0);
		#if defined PLUGIN_DEBUG
		gReasons.GetString(i, rSon, sizeof(rSon));
		LogMessage("> INDEX: %i, VALUE: 0, REASON: %s", i, rSon);
		#endif 
	}
		

	#if defined PLUGIN_DEBUG
	LogMessage(">>> COUNT REASON ARRAY");
	#endif 

	// count reason
	for(int i=0; i < GetMaxClients(); ++i)
	{
		if(player.valid(i))
		{
			if(gv.getVb(i) == gid) {
				// client found, write reason
				someArray.Set(gv.getVbReason(i), (someArray.Get(gv.getVbReason(i))+1));
			}
		}
	}

	int result = 0;
	// find most reason
	#if defined PLUGIN_DEBUG
	LogMessage(">>> DISPLAY REASON ARRAY");
	#endif 
	for(int i = 0; i <= ((gReasons.Length)-1); i++) {
		if(someArray.Get(i) > result) result = i;
		#if defined PLUGIN_DEBUG
		gReasons.GetString(i, rSon, sizeof(rSon));
		LogMessage("> INDEX: %i, VALUE: %i, REASON: %s", i, someArray.Get(i), rSon);
		#endif 
	}
		
	#if defined PLUGIN_DEBUG
	LogMessage(">>> AS RESULT WAS FOUND REASON:");
	gReasons.GetString(result, rSon, sizeof(rSon));
	LogMessage(">>> VALUE: %s",rSon);
	#endif
		
	return result;
}