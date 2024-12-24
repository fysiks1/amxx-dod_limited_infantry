#include <amxmodx>
#include <hamsandwich>
#include <dodconst>
#include <fakemeta>
#include <fakemeta_util>

#define CLASS_MASTER "dod_control_point_master"
#define CLASS_SCORES "dod_score_ent"
#define NEVER 0.0

new g_iDeathCount[4]
new bool:g_bInfantryDepleted[4]

new g_pCvarInfantryCount, g_pCvarEnable
new g_entControlPointMaster
new g_entScore[2]
new g_entWinSound[2]

public plugin_init()
{
	register_plugin("DOD Limited Infantry", "0.2", "Fysiks")

	register_concmd("infantry_count", "cmdInfantryCount")

	RegisterHam(Ham_Spawn, "player", "hookHamSpawnPre", 0)
	register_event("DeathMsg","eventDeathMsg","a")
	register_event("HLTV", "hookNewRound", "a", "1=0", "2=0")

	g_pCvarEnable = register_cvar("limited_infantry_enable", "0")
	g_pCvarInfantryCount = register_cvar("limited_infantry_count", "5")

	// Find the 'dod_control_point_master' entity (based on dod_killingspree by Vet(3TT3V))
	g_entControlPointMaster = fm_find_ent_by_class(g_entControlPointMaster, CLASS_MASTER)
	if( !g_entControlPointMaster )
		set_fail_state("dod_control_point_master not found")

	// Find 2 'dod_score_ent' entities - Fail if less (based on dod_killingspree by Vet(3TT3V))
	new ent, last_ent, iTeam, szScoreTargetname[32], ent2, szSoundTargetname[32]
	for( ent = 0; ent < 2; ent++ )
	{
		last_ent = fm_find_ent_by_class(last_ent, CLASS_SCORES)
		iTeam = pev(last_ent, pev_team)

		pev(last_ent, pev_targetname, szScoreTargetname, charsmax(szScoreTargetname))
		ent2 = 0
		while( (ent2 = fm_find_ent_by_class(ent2, "ambient_generic")) )
		{
			pev(ent2, pev_targetname, szSoundTargetname, charsmax(szSoundTargetname))
			if( equal(szScoreTargetname, szSoundTargetname) )
			{
				// Win sound, presumably, assuming only one sound is played per win
				g_entWinSound[iTeam - 1] = ent2
				break
			}
		}

		if( !last_ent || !iTeam )
			set_fail_state("Two dod_score_ent entities were not found")

		g_entScore[iTeam - 1] = last_ent
		
	}
}

public hookHamSpawnPre(id)
{
	if( is_user_connected(id) )
	{
		new iTeam = get_user_team(id)
		if( g_bInfantryDepleted[iTeam] )
		{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
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
			g_iDeathCount[iTeam]++
		}
	}

	if( g_iDeathCount[iTeam] >= get_pcvar_num(g_pCvarInfantryCount) )
	{
		// Limit reached, trigger end of round
		new iPlayers[32], iPlayersNum

		g_bInfantryDepleted[iTeam] = true

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
	else
	{
		client_print(0, print_chat, "Backup infantrymen remaining for %s: %d", iTeam == ALLIES ? "Allies" : "Axis", get_pcvar_num(g_pCvarInfantryCount) - g_iDeathCount[iTeam])
	}
}

public hookNewRound()
{
	arrayset(g_iDeathCount, 0, sizeof g_iDeathCount)
	arrayset(g_bInfantryDepleted, 0, sizeof g_bInfantryDepleted)
}

triggerWin(iTeam)
{
	// Trigger dod_score_ent for winning team
	client_print(0, print_chat, "%s have lost due to a lack of backup infantry.", iTeam == ALLIES ? "Allies" : "Axis") // Debug
	ExecuteHamB(Ham_Use, g_entScore[iTeam == ALLIES ? 0 : 1], g_entControlPointMaster, g_entControlPointMaster, 3, NEVER)

	// Play win sound
	new entWinSound = g_entWinSound[iTeam == ALLIES ? 0 : 1]
	if( pev_valid(entWinSound) )
	{
		ExecuteHamB(Ham_Use, entWinSound, g_entControlPointMaster, g_entControlPointMaster, 3, NEVER)
	}
}

public cmdInfantryCount(id)
{
	new iMax = get_pcvar_num(g_pCvarInfantryCount)
	console_print(id, "Allies: %d/%d   Axis: %d/%d", g_iDeathCount[ALLIES], iMax, g_iDeathCount[AXIS], iMax)
	return PLUGIN_HANDLED
}
