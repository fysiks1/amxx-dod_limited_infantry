#include <amxmodx>
#include <hamsandwich>

new g_iSpawnCount[33]

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
		g_iSpawnCount[id]++
	}
}

public hookHamKilled(id)
{
	if( g_iSpawnCount[id] >= get_pcvar_num(g_pCvarSpawnCount) )
	{
		// Limit reached, Block spawning
		
		// Check alive
	}
}



public hookNewRound()
{
	arrayset(g_iSpawnCount, 0, sizeof g_iSpawnCount)
}




