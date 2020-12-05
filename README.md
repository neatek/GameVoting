# GameVoting 1.9.x
Light voting plugin Sourcemod.net for TF2, CSS, CSGO etc
Supports: Sourcebans++, MaterialAdmin, Sourcemod (2020)

# WebAdmin:
[![webadmin](http://neatek.ru/gamevoting-webadmin.png)](https://discord.gg/J7eSXuU)
If you want to see in release WebAdmin for GameVoting you can donate.
Release on 280$ reached, or you can buy it for your project 180$.
1. Built-in protect against attacks (exclude DDOS, use hardware protection). 
2. With RestAPI. 
3. Easy to install - NO composer, NO other packages - only Unpack archive & import SQL.
4. One database for all your servers - share mute, bans between servers. 
5. Dark / White Theme Switcher, Icons :yum: 
6. API key will be automatically changed when you will install web-scripts. 
7. Based on Light Framework
8. PHP7.3 or above && > MySQL5.5 or above
9. Funny quotes in footer :ok_hand: 
- https://www.paypal.me/neatek/10usd

# Install:
Replace `addons` folder
Require: Sourcemod 1.10, if you use lower sm - recompile it on your version

# Discord:
[![discord](https://neatek.ru/img/Join_me_on_Discord_small.png)](https://discord.gg/J7eSXuU)

# Support:
- https://www.paypal.me/neatek/10usd

# Changes:
- 04.08.2017 - StartVote feature. (global voteban - yes/no)
- 07.08.2017 - Translations.
- 07.08.2017 - Improvements.
- 07.08.2017 - Bug fixes.
- 20.08.2017 - Voteban reasons for "StartVote" feature.
- 27.01.2020 - new Enum struct syntax. Support >SM1.10.x
- 12.02.2020 - Reasons fixed.
- 06.12.2020 - Reasons length must be more than 1 char.
- 06.12.2020 - MACOREVERSION updated - 0.8.0
- 06.12.2020 - Minimal required count of players for ban - 3.
- 06.12.2020 - Detecting of ban systems improved.
- 06.12.2020 - Removed some useless logs, added new usefull logs.

# Config:
- gamevoting_authid "1"
- gamevoting_autodisable "0"
- gamevoting_bots_enabled "0"
- gamevoting_enable "1"
- gamevoting_immunity_flag "a"
- gamevoting_immunity_zflag "1"
- gamevoting_logs "1"
- gamevoting_only_teammates "0"
- gamevoting_players "8"
- gamevoting_startvote_delay "20"
- gamevoting_startvote_enable "1"
- gamevoting_startvote_flag ""
- gamevoting_startvote_min "4"
- gamevoting_voteban "1"
- gamevoting_voteban_delay "20"
- gamevoting_voteban_percent "80"
- gamevoting_votekick "1"
- gamevoting_votekick_delay "20"
- gamevoting_votekick_percent "80"
- gamevoting_votemute "1"
- gamevoting_votemute_delay "20"
- gamevoting_votemute_percent "75"

Located at: cstrike\cfg\sourcemod\Gamevoting.cfg
After first start of server with plugin