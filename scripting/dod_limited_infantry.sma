#include <amxmodx>
#include <hamsandwich>
#include <dodconst>

new g_iInfantryCount[4]

new g_pCvarInfantryCount, g_pCvarEnable

public plugin_init()
{
	register_plugin("DOD Limited Infantry", "0.1", "Fysiks")

	register_concmd("infantry_count", "cmdInfantryCount")

	RegisterHam(Ham_Spawn, "player", "hookHamSpawn", 1)
	register_event("DeathMsg","eventDeathMsg","a")
	register_event("HLTV", "hookNewRound", "a", "1=0", "2=0")
	register_logevent("hookRoundEnd", 2, "1=Round_End")

	g_pCvarEnable = register_cvar("limited_infantry_enable", "0")
	g_pCvarInfantryCount = register_cvar("limited_infantry_count", "5")
}

public hookHamSpawn(id)
{
}

public eventDeathMsg()
{
	if( !get_pcvar_num(g_pCvarEnable) )
		return
	
	new id = read_data(2);
	new iTeam = get_user_team(id)

	switch( iTeam )
	{
		case 1, 2:
		{
			g_iInfantryCount[iTeam]++
		}
	}

	if( g_iInfantryCount[iTeam] >= get_pcvar_num(g_pCvarInfantryCount) )
	{
		// Limit reached, trigger end of round
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

	client_print(0, print_chat, "Death.  %d:%d", g_iInfantryCount[ALLIES], g_iInfantryCount[AXIS]) // Debug
}

public hookNewRound()
{
	if( !get_pcvar_num(g_pCvarEnable) )
		return

	arrayset(g_iInfantryCount, 0, sizeof g_iInfantryCount)
	client_print(0, print_chat, "New Round!") // Debug
}

public hookRoundEnd()
{
	if( !get_pcvar_num(g_pCvarEnable) )
		return

	arrayset(g_iInfantryCount, 0, sizeof g_iInfantryCount)
	client_print(0, print_chat, "Round End!") // Debug
}


triggerWin(iTeam)
{
	// trigger win
	client_print(0, print_chat, "%s have lost due to a lack of backup infantry.", iTeam == ALLIES ? "Allies" : "Axis") // Debug
}

public cmdInfantryCount(id)
{
	console_print(id, "Allies: %d   Axis: %d", g_iInfantryCount[ALLIES], g_iInfantryCount[AXIS])
	return PLUGIN_HANDLED
}
