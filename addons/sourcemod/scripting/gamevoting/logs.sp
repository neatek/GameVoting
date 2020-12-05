public void GVInitLog() {
	loadReasons();
	if(CONVAR_ENABLE_LOGS.IntValue > 0) {
		BuildPath(Path_SM, LogFilePath, sizeof(LogFilePath), "logs/gamevoting/");
		if(!DirExists(LogFilePath)) {
			CreateDirectory(LogFilePath, 777);
		}
		char ftime[68];
		FormatTime(ftime, sizeof(ftime), "logs/gamevoting/gv%m-%d.txt",  GetTime());
		BuildPath(Path_SM, LogFilePath, sizeof(LogFilePath), ftime);
	}
	detect_ban_system(BANSYS_SOURCEBANSPP);
	detect_ban_system(BANSYS_SOURCEBANSPP_COMMS);
	detect_ban_system(BANSYS_MADMIN);
	detect_ban_system(BANSYS_MADMIN_COMMS);
}