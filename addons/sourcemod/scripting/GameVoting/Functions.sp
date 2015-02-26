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