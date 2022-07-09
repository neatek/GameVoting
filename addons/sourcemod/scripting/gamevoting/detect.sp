public bool detect_ban_system(int type) {
	char filename[48], file_path[128];
	switch(type) {
		case BANSYS_SOURCEBANSPP: {
			FormatEx(filename,sizeof(filename),"sbpp_main");
		}
		case BANSYS_SOURCEBANSPP_COMMS: {
			FormatEx(filename,sizeof(filename),"sbpp_comms");
		}
		case BANSYS_MADMIN: {
			FormatEx(filename,sizeof(filename),"materialadmin");
		}
		case BANSYS_MADMIN_COMMS: {
			FormatEx(filename,sizeof(filename),"ma_basecomm");
		}
		default: {}
	}
	BuildPath(Path_SM, file_path, sizeof(file_path), "plugins/%s.smx", filename);
	LogMessage("[GameVoting] Checking ban system: %s", file_path);
	if(FileExists(file_path)) {
		LogToFile(LogFilePath, "[GameVoting] Founded ban system: %s", file_path);
		is_bansys[type] = true;
		return true;
	}
	return false;
}
