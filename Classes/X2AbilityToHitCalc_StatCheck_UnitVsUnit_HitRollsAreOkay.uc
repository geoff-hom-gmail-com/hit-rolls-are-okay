class X2AbilityToHitCalc_StatCheck_UnitVsUnit_HitRollsAreOkay extends X2AbilityToHitCalc_StatCheck_UnitVsUnit;

// This function is from X2AbilityToHitCalc_StatCheck, not X2AbilityToHitCalc_StatCheck_UnitVsUnit. 
// Tried overriding X2AbilityToHitCalc_StatCheck, but didn't get called. Think Breaker Smash impairment is X2AbilityToHitCalc_StatCheck_UnitVsUnit.
function RollForAbilityHit(XComGameState_Ability kAbility, AvailableTarget kTarget, out AbilityResultContext ResultContext)
{
	local int MultiTargetIndex, AttackVal, DefendVal, TargetRoll, RandRoll, StatContestResultValue;
	local OverriddenEffectsByType EmptyOverriddenByType;
	local StatContestOverrideData StatContestOverrideInfo;
	local X2AbilityTemplate AbilityTemplate;

	`log("--------------------", , 'XCom_HitRolls');
	`log("X2AbilityToHitCalc_StatCheck_UnitVsUnit_HitRollsAreOkay.RollForAbilityHit()", , 'XCom_HitRolls');

	// "RollForAbilityHit: Ability [BreakerSmashImpairingAbility], Target [??]"
	`log("RollForAbilityHit: Ability [" $ kAbility.GetMyTemplateName() $ "], Target [" $ kTarget.PrimaryTarget.ObjectID $ "]", , 'XCom_HitRolls');
	
	// hmm, I don't want this for every unitvsUnit stat check... well, I could filter by ability name.

	if (kTarget.PrimaryTarget.ObjectID > 0)
	{
		AttackVal = GetAttackValue(kAbility, kTarget.PrimaryTarget);
		DefendVal = GetDefendValue(kAbility, kTarget.PrimaryTarget);
		TargetRoll = BaseValue + AttackVal - DefendVal;
		`log("Attack Value:" @ AttackVal @ "Defend Value:" @ DefendVal @ "Target Roll:" @ TargetRoll,,'XCom_HitRolls');
		if (TargetRoll < 100)
		{
			RandRoll = `SYNC_RAND(100);
			`log("Random roll:" @ RandRoll,,'XCom_HitRolls');
			if (RandRoll < TargetRoll)
				ResultContext.HitResult = eHit_Success;
			else
				ResultContext.HitResult = eHit_Miss;
		}
		else
		{
			ResultContext.HitResult = eHit_Success;
		}
		`log("Result:" @ ResultContext.HitResult,,'XCom_HitRolls');
		if (class'XComGameStateContext_Ability'.static.IsHitResultHit(ResultContext.HitResult))
		{
			ResultContext.StatContestResult = RollForEffectTier(kAbility, kTarget.PrimaryTarget, false);

			// "StatContestResult [5]"
			`Log("StatContestResult [" $ ResultContext.StatContestResult $ "]", , 'XCom_HitRolls');
		}
	}
	else
	{
		ResultContext.HitResult = eHit_Success;         //  mark success for the ability to go off
	}

	if( `CHEATMGR != None && `CHEATMGR.bDeadEyeStats )
	{
		`log("DeadEyeStats cheat forcing a hit.", true, 'XCom_HitRolls');
		ResultContext.HitResult = eHit_Success;
	}
	else if( `CHEATMGR != None && `CHEATMGR.bNoLuckStats )
	{
		`log("NoLuckStats cheat forcing a miss.", true, 'XCom_HitRolls');
		ResultContext.HitResult = eHit_Miss;
	}
	if( `CHEATMGR != None && `CHEATMGR.bForceAttackRollValue )
	{
		ResultContext.HitResult = eHit_Success;
		ResultContext.StatContestResult = `CHEATMGR.iForcedRollValue;
	}

	// Set up the lookups to more quickly find the correct Effects values based on Tiers
	StatContestOverrideInfo.MultiTargetEffectsNumHits.Length = 0;
	StatContestOverrideInfo.StatContestResultToEffectInfos.Length = 0;

	AbilityTemplate = kAbility.GetMyTemplate();
	SetStatContestResultToEffectInfos(AbilityTemplate.AbilityMultiTargetEffects, GetHighestTierPossible(AbilityTemplate.AbilityMultiTargetEffects), StatContestOverrideInfo);

	for (MultiTargetIndex = 0; MultiTargetIndex < kTarget.AdditionalTargets.Length; ++MultiTargetIndex)
	{
		`log("Roll against multi target" @ kTarget.AdditionalTargets[MultiTargetIndex].ObjectID,,'XCom_HitRolls');
		AttackVal = GetAttackValue(kAbility, kTarget.AdditionalTargets[MultiTargetIndex]);
		DefendVal = GetDefendValue(kAbility, kTarget.AdditionalTargets[MultiTargetIndex]);
		TargetRoll = BaseValue + AttackVal - DefendVal;
		`log("Attack Value:" @ AttackVal @ "Defend Value:" @ DefendVal @ "Target Roll:" @ TargetRoll,,'XCom_HitRolls');
		if (TargetRoll < 100)
		{
			RandRoll = `SYNC_RAND(100);
			`log("Random roll:" @ RandRoll,,'XCom_HitRolls');
			if (RandRoll < TargetRoll)
				ResultContext.MultiTargetHitResults.AddItem(eHit_Success);
			else
				ResultContext.MultiTargetHitResults.AddItem(eHit_Miss);
		}
		else
		{
			ResultContext.MultiTargetHitResults.AddItem(eHit_Success);
		}
		`log("Result:" @ ResultContext.HitResult,,'XCom_HitRolls');
		if (class'XComGameStateContext_Ability'.static.IsHitResultHit(ResultContext.HitResult))
		{
			StatContestResultValue = RollForEffectTier(kAbility, kTarget.AdditionalTargets[MultiTargetIndex], true);
			ResultContext.MultiTargetStatContestResult.AddItem(StatContestResultValue);

			if (ResultContext.MultiTargetEffectsOverrides.Length <= MultiTargetIndex)
			{
				// A new Override needs to be added
				ResultContext.MultiTargetEffectsOverrides.AddItem(EmptyOverriddenByType);
			}

			// Check to see if this value needs to be changed
			// Ignore if the StatContestResultValue is 0
			// AND
			// If there are no Effects that need to be Overridden
			// AND
			// This StatContestResultValue does not map to Effects that may be Overridden
			if ((StatContestResultValue > 0) &&
				(StatContestOverrideInfo.StatContestResultToEffectInfos.Length > StatContestResultValue) &&
				(StatContestOverrideInfo.StatContestResultToEffectInfos[StatContestResultValue].EffectIndices.Length > 0))
			{
				DoStatContestResultOverrides(MultiTargetIndex, StatContestResultValue, kAbility, StatContestOverrideInfo, ResultContext);
			}
		}
		else
		{
			ResultContext.MultiTargetStatContestResult.AddItem(0);
		}
	}
}

function int RollForEffectTier(XComGameState_Ability kAbility, StateObjectReference TargetRef, bool bMultiTarget)
{
	local X2AbilityTemplate AbilityTemplate;
	local int MaxTier, MiddleTier, Idx, AttackVal, DefendVal;
	local array<float> TierValues;
	local float TierValue, LowTierValue, HighTierValue, TierValueSum, RandRoll;

	`log("RollForEffectTier", , 'XCom_HitRolls');

	AbilityTemplate = kAbility.GetMyTemplate();
	if (TargetRef.ObjectID > 0)
	{
		`log("=RollForEffectTier=");
		AttackVal = GetAttackValue(kAbility, TargetRef);
		DefendVal = GetDefendValue(kAbility, TargetRef);
		if (bMultiTarget)
			MaxTier = GetHighestTierPossible(AbilityTemplate.AbilityMultiTargetEffects);
		else
			MaxTier = GetHighestTierPossible(AbilityTemplate.AbilityTargetEffects);
		`log("Attack Value:" @ AttackVal @ "Defend Value:" @ DefendVal @ "Max Tier:" @ MaxTier,,'XCom_HitRolls');

		//  It's possible the ability only cares about success or failure and has no specified ladder of results
		if (MaxTier < 0)
		{
			return 0;
		}

		MiddleTier = MaxTier / 2 + MaxTier % 2;		
		TierValue = 100.0f / float(MaxTier);
		LowTierValue = TierValue * (float(DefendVal) / float(AttackVal));
		HighTierValue = TierValue * (float(AttackVal) / float(DefendVal));
		for (Idx = 1; Idx <= MaxTier; ++Idx)
		{			
			if (Idx < MiddleTier)
			{
				TierValues.AddItem(LowTierValue);
			}
			else if (Idx == MiddleTier)
			{
				TierValues.AddItem(TierValue);
			}
			else
			{
				TierValues.AddItem(HighTierValue);
			}			
			TierValueSum += TierValues[TierValues.Length - 1];
			`log("Tier" @ Idx $ ":" @ TierValues[TierValues.Length - 1],,'XCom_HitRolls');
		}
		//  Normalize the tier values
		for (Idx = 0; Idx < TierValues.Length; ++Idx)
		{
			TierValues[Idx] = TierValues[Idx] / TierValueSum;
			if (Idx > 0)
				TierValues[Idx] += TierValues[Idx - 1];

			`log("Normalized Tier" @ Idx $ ":" @ TierValues[Idx],,'XCom_HitRolls');
		}
		RandRoll = `SYNC_FRAND;
		`log("Random roll:" @ RandRoll,,'XCom_HitRolls');
		for (Idx = 0; Idx < TierValues.Length; ++Idx)
		{
			if (RandRoll < TierValues[Idx])
			{
				`log("Matched tier" @ Idx,,'XCom_HitRolls');
				return Idx + 1;     //  the lowest possible tier is 1, not 0
			}
		}
		`log("Matched highest tier",,'XCom_HitRolls');
		return TierValues.Length;
	}
	return 0;
}