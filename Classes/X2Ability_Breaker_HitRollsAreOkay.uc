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

	`log("           ---", , 'XCom_Maps');
	`log("           ------------X2Ability_Breaker_HitRollsAreOkay.AftershockSmash_ApplyChanceCheck()------------", , 'XCom_Maps');
	`log("           ------------If have both Aftershock and Fear Factor, then Aftershock is rolled first.------------", , 'XCom_Maps');

	// "Source [Axiom, STR [90]], Target [Purifier, STR [50]]"
	`log("           Source [" $ SourceUnit.GetNickName(true) $ ", STR [" $ int(SourceStrength) $ "]], Target [" $ TargetUnit.GetFullName() $ ", STR [" $ int(TargetStrength) $ "]]", , 'XCom_Maps');

	RolledChance = `SYNC_RAND(100);
	TargetChance = default.BREAKER_AFTERSHOCK_BASE_CHANCE + SourceStrength - TargetStrength;

	// "TargetChance [90], RolledChance [?], Result [Hit!/Miss!]"
	Result = RolledChance <= TargetChance ? "Hit!" : "Miss!";
	`log("           TargetChance [" $ int(TargetChance) $ "], RolledChance [" $ int(RolledChance) $ "], Result [" $ Result $ "]", , 'XCom_Maps');

	if (RolledChance <= TargetChance)
	{
		return 'AA_Success';
	}

	return 'AA_EffectChanceFailed';
}	