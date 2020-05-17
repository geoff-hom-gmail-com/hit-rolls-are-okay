//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_Breaker_HitRollsAreOkay.uc
//  AUTHOR:  Geoff Hom  --  05/10/2020
//  PURPOSE: Log hit-rolls for Breaker's Smash.
//---------------------------------------------------------------------------------------
class X2Ability_Breaker_HitRollsAreOkay extends X2Ability_Breaker
	dependson (XComGameStateContext_Ability) 	
	config(GameData_SoldierSkills);

function name AftershockSmash_ApplyChanceCheck(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit, SourceUnit;
	local float TargetChance, RolledChance;
	local float SourceStrength, TargetStrength;
	local string Result;
	
	// Do strength checks
	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnit = XComGameState_Unit(kNewTargetState);

	SourceStrength = SourceUnit.GetCurrentStat(eStat_Strength);
	TargetStrength = TargetUnit.GetCurrentStat(eStat_Strength);

	`log("--------------------", , 'XCom_HitRolls');
	`log("          AftershockSmash_ApplyChanceCheck--------------------", , 'XCom_XP');
	`log("          AftershockSmash_ApplyChanceCheck--------------------", , 'GeoffTest');

	// "AftershockSmash_ApplyChanceCheck (Aftershock damage rolled before Fear Factor): Source [Axiom, STR [90]], Target [Purifier, STR [50]]"
	`Log("AftershockSmash_ApplyChanceCheck (Aftershock rolled before Fear Factor): Source [" $ SourceUnit.GetNickName(true) $ ", STR [" $ int(SourceStrength) $ "]], Target [" $ TargetUnit.GetFullName() $ ", STR [" $ int(TargetStrength) $ "]]", , 'XCom_HitRolls');

	RolledChance = `SYNC_RAND(100);
	TargetChance = default.BREAKER_AFTERSHOCK_BASE_CHANCE + SourceStrength - TargetStrength;

	// "AftershockSmash_ApplyChanceCheck: TargetChance [90], RolledChance [?], Result [Hit!/Miss!]"
	Result = RolledChance <= TargetChance ? "Hit!" : "Miss!";
	`Log("AftershockSmash_ApplyChanceCheck: TargetChance [" $ int(TargetChance) $ "], RolledChance [" $ int(RolledChance) $ "], Result [" $ Result $ "]", , 'XCom_HitRolls');

	if (RolledChance <= TargetChance)
	{
		return 'AA_Success';
	}

	return 'AA_EffectChanceFailed';
}	