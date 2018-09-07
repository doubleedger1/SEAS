# SEAS - An administration system for Garry's Mod.
# Requirements
- A server
- MySQLOO module found here: https://github.com/FredyH/MySQLOO
  - A MySQL database to go alongside.
  - You also need the libmySQL.dll in your main garrysmod folder.
    - There are plans for adding support for SQLite for use of the server db instead in the future hence the use of "if (SEAS.MISC.UseSQL)".
# How to install
- Simply add the folder into your garrysmod/garrysmod/addons.
# Setting it up
- Fill all the SQL related settings in sv_init.lua.

# Features
- Over 20 helpful commands to use.
- Ability to add your own commands alongside the defaults in sv_commands.lua
  - The format should be simple to follow. Just look at a command for an example on how to do so.
- Three player and server management systems to use:
  - Chat command system
    - You can use ! or / or both and use specific times for timed punishments instead of just default minutes using 1y1m1w1d1h in any order.
  - A player management menu for easier administration.
    - Simply select a player and a button to execute. Quick commands will execute on press whereas others will use reason/duration/whatever args then a submit button.
  - A quick commands menu using a button specified in the sh_config.lua file
    - Simple and quick to use with prefabs for reasons, durations and values where applicable.
 # Credits
 - Quack for helpful testing.
