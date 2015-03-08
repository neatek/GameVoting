//#define PLUGIN_DEBUG 1
#define CHAT_PREFIX "GameVoting"
#define STEAM_SIZE 32
#define SQL_CONFIG "gamevoting"
#define SQL_ID 0
#define SQL_STEAM 1
#define SQL_VOTEBAN 2
#define SQL_VOTEKICK 3
#define SQL_VOTEMUTE 4
#define SQL_VOTEGAG 5
#define SQL_KICKSTAMP 2
#define SQL_MUTESTAMP 3
#define SQL_GAGSTAMP 4

#define REASON_LEN 68

#define SQL_PLAYERS "CREATE TABLE IF NOT EXISTS `gv_cache` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `steam` TEXT NOT NULL UNIQUE, `kicktime` INTEGER, `mutetime` INTEGER, `gagtime` INTEGER);"
#define SQL_GETPLAYER "SELECT * FROM `gv_cache` WHERE `steam` = '%s' LIMIT 1"
#define SQL_REGPLAYER "INSERT INTO `gv_cache` (`id`, `steam`) VALUES (NULL, '%s')"
#define SQL_MUTEPLAYER "UPDATE `gv_cache` SET `mutetime`='%d' WHERE `steam` = '%s'"
#define SQL_KICKPLAYER "UPDATE `gv_cache` SET `kicktime`='%d' WHERE `steam` = '%s'"
#define SQL_GAGPLAYER "UPDATE `gv_cache` SET `gagtime`='%d' WHERE `steam` = '%s'"

#define VOTEBAN_CMD 	"!voteban"
#define VOTEKICK_CMD 	"!votekick"
#define VOTEMUTE_CMD 	"!votemute"

#define CONTINUE Plugin_Continue
#define HANDLED Plugin_Handled

#define SAYCMD 	"say"
#define SAYCMD2 "say_team"