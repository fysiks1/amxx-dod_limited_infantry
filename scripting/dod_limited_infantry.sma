#include <amxmodx>
#include <hamsandwich>

new g_iSpawnCount[2]

new g_pCvarSpawnCount

public plugin_init()
{
	register_plugin("DOD Limited Infantry", "0.1", "Fysiks")
	RegisterHam(Ham_Spawn, "player", "hookHamSpawn", 1)

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
				g_iSpawnCount[iTeam-1]++
				client_print(0, print_chat, "Spawn Count: %d %d", g_iSpawnCount[0], g_iSpawnCount[1])
			}
		}
	}
}

public hookHamKilled(id)
{
	new iTeam = get_user_team(id)
	new iSpawnCount

	switch( iTeam )
	{
		case 1, 2:
		{
			iSpawnCount = g_iSpawnCount[iTeam-1]
		}
	}


	if( iSpawnCount >= get_pcvar_num(g_pCvarSpawnCount) )
	{
		// Block spawning for team
		// To do
		
		// If last player, trigger end of round
		new iPlayers[32], iPlayersNum

		switch( iTeam )
		{
			case 1, 2:
			{
				get_players(iPlayers, iPlayersNum, "e", iTeam == 1 ? "Allies" : "Axis")
				if( iPlayersNum == 0 )
				{
					// The other team wins!
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




