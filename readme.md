# Hit Rolls are Okay README

This is the README for the XCOM: Chimera Squad mod, 'Hit Rolls are Okay.' 

TL;DR: This is a niche hack mod, if you want to see how a subset of hit rolls are done; in particular, Axiom's Smash. 

If you look at the SDK, there are log statements for many things, including hit rolls. You'd think you could activate these log statements via Engine.ini and the '-Suppress' command. However, that doesn't work. I think that's because all the log statements are stripped upon final release. 

If you want to learn more about how the game actually works, what can you do? 

This mod restores the ability to log hit-roll info in some cases. 

In particular, Axiom's Smash, Aftershock, and Fear Factor. Anything that uses those hit-roll mechanics may also be logged.

By default, this mod turns on the logging, which can be seen in the Launch log and the Combat log. 

## Features

The trivial way for Firaxis to fix this bug is to leave the logging statements in, and just turn off the logging via Engine.ini and '+Suppress.' Ironically, Firaxis already does the latter, but not the former. 

Mods can't modify the source code directly, so the workaround is to add to it:

> Override X2Ability_Breaker.AftershockSmash_ApplyChanceCheck(), which rolls for both Aftershock and Fear Factor. 

> Override X2AbilityToHitCalc_StatCheck_UnitVsUnit.RollForAbilityHit() and RollForEffectTier(), which roll the effect for Smash. 

> Couldn't get the log tag 'XCom_HitRolls' to work; statements from mod's XComEngine.ini weren't propagating to config's XComEngine.ini. 
To hack it, this mod uses the log tag 'XCom_Maps,' which is already output, including to the Balance and FileIO logs.

If there's a bug with this mod, you can post to reddit (e.g., xcom2mods) or email me at geoff.hom@gmail.com. Please include the Combat and/or Launch logs. 
  
> Tip: Smash's impairment tests Axiom's STR vs opponent's Will. If it procs, then another roll is made to see which impairment is used. This second roll is also affected by STR vs Will.

> Tip: Aftershock's description says there's a chance to proc impairment on nearby enemies. This isn't true so far (5.16.2020). Only Smash's target can be impaired. 

> Tip: Fear Factor tests STR vs STR. FF can proc even if Smash misses. It's often easier to Panic all nearby enemies than to impair the Smash target.

> Tip: Mod code is at https://github.com/geoffhom/hit-rolls-are-okay. 

## Requirements

The mod overrides X2Ability_Breaker.AftershockSmash_ApplyChanceCheck(), and also X2AbilityToHitCalc_StatCheck_UnitVsUnit.RollForAbilityHit() and RollForEffectTier(). 