#include <amxmodx>
#include <hamsandwich>
#include <dodconst>

new g_iSpawnCount[4]

new g_pCvarSpawnCount

public plugin_init()
{
	register_plugin("DOD Limited Infantry", "0.1", "Fysiks")
	RegisterHam(Ham_Spawn, "player", "hookHamSpawn", 1)
	register_event("DeathMsg","eventDeathMsg","a")
	// need to hook new round for hookNewRound()

	g_pCvarSpawnCount = register_cvar("limited_infantry_spawn_count", "50")
}

public hookHamSpawn(id)
{
	if( is_user_alive(id) )
	{
		new iTeam = get_user_team(id)
		switch( iTeam )
		{
			case 1, 2:
			{
				g_iSpawnCount[iTeam]++
				client_print(0, print_chat, "Spawn Count: %d %d", g_iSpawnCount[ALLIES], g_iSpawnCount[AXIS])
			}
		}
	}
}

public eventDeathMsg()
{
	new id = read_data(2);
	new iTeam = get_user_team(id)
	new iSpawnCount

	switch( iTeam )
	{
		case 1, 2:
		{
			iSpawnCount = g_iSpawnCount[iTeam]
		}
	}


	if( iSpawnCount >= get_pcvar_num(g_pCvarSpawnCount) )
	{
		// Block spawning for team
		blockTeamSpawn(iTeam)
		
		// If last player, trigger end of round
		new iPlayers[32], iPlayersNum

		switch( iTeam )
		{
			case 1, 2:
			{
				get_players(iPlayers, iPlayersNum, "e", iTeam == 1 ? "Allies" : "Axis")
				if( iPlayersNum == 0 )
				{
					triggerWin(iTeam == ALLIES ? AXIS : ALLIES)
				}
			}
		}
	}
}

public hookNewRound()
{
	arrayset(g_iSpawnCount, 0, sizeof g_iSpawnCount)
	client_print(0, print_chat, "New Round!")
}


triggerWin(iTeam)
{
	// trigger win
	client_print(0, print_chat, "Trigger Win for %s", iTeam == ALLIES ? "Allies" : "Axis")
}

blockTeamSpawn(iTeam)
{
	// block team spawn
	client_print(0, print_chat, "Block Spawn for %s", iTeam == ALLIES ? "Allies" : "Axis")
}

