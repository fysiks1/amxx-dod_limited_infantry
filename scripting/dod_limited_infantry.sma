#include <amxmodx>
#include <hamsandwich>
#include <dodconst>
#include <fakemeta>
#include <fakemeta_util>

#define CLASS_MASTER "dod_control_point_master"
#define CLASS_SCORES "dod_score_ent"
#define NEVER 0.0

new g_iInfantryCount[4]

new g_pCvarInfantryCount, g_pCvarEnable
new g_entControlPointMaster
new g_entScore[2]

public plugin_init()
{
	register_plugin("DOD Limited Infantry", "0.1", "Fysiks")

	register_concmd("infantry_count", "cmdInfantryCount")

	register_event("DeathMsg","eventDeathMsg","a")
	register_event("HLTV", "hookNewRound", "a", "1=0", "2=0")

	g_pCvarEnable = register_cvar("limited_infantry_enable", "0")
	g_pCvarInfantryCount = register_cvar("limited_infantry_count", "5")

	// Find the 'dod_control_point_master' entity (based on dod_killingspree by Vet(3TT3V))
	g_entControlPointMaster = fm_find_ent_by_class(g_entControlPointMaster, CLASS_MASTER)
	if( !g_entControlPointMaster )
		set_fail_state("dod_control_point_master not found")

	// Find 2 'dod_score_ent' entities - Fail if less (based on dod_killingspree by Vet(3TT3V))
	new ent, last_ent, iTeam
	for( ent = 0; ent < 2; ent++ )
	{
		last_ent = fm_find_ent_by_class(last_ent, CLASS_SCORES)
		iTeam = pev(last_ent, pev_team)

		if( !last_ent || !iTeam )
			set_fail_state("Two dod_score_ent entities were not found")

		g_entScore[iTeam - 1] = last_ent
		
	}
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
}

public hookNewRound()
{
	if( !get_pcvar_num(g_pCvarEnable) )
		return

	arrayset(g_iInfantryCount, 0, sizeof g_iInfantryCount)
}

triggerWin(iTeam)
{
	// trigger win
	client_print(0, print_chat, "%s have lost due to a lack of backup infantry.", iTeam == ALLIES ? "Allies" : "Axis") // Debug
	ExecuteHamB(Ham_Use, g_entScore[iTeam == ALLIES ? 0 : 1], g_entControlPointMaster, g_entControlPointMaster, 3, NEVER)
}

public cmdInfantryCount(id)
{
	new iMax = get_pcvar_num(g_pCvarInfantryCount)
	console_print(id, "Allies: %d/%d   Axis: %d/%d", g_iInfantryCount[ALLIES], iMax, g_iInfantryCount[AXIS], iMax)
	return PLUGIN_HANDLED
}
