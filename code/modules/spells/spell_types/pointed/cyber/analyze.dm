/obj/effect/proc_holder/spell/pointed/cyber/analyze
	name = "Shallow cybernetic signature scan"
	desc = "Allows you to analyze the opponent's cybernetic signature, allowing you to see their cybernetics and cyberware. Doesn't find cybernetics with obscured signatures."
	charge_max = 300
	ranged_mousepointer = 'icons/effects/mouse_pointers/analyze_target.dmi'
	action_icon_state = "analyze"
	active_msg = "You prepare to analyze a target..."

	var/basic = TRUE

/obj/effect/proc_holder/spell/pointed/cyber/analyze/cast(list/targets, mob/user)
	. = ..()
	if(length(targets) != 1)
		return
	if(!can_target(targets[1],user))
		return
	var/mob/living/carbon/human/victim = targets[1]
	for(var/C in victim.internal_organs)
		if(!istype(C,/obj/item/organ/cyberimp))
			continue
		var/obj/item/organ/cyberimp/cybernetic = C
		if(cybernetic.implant_class == CYBER_CLASS_SYNDICATE && basic)
			continue
		to_chat(user,span_notice("Found cybernetic modification: [cybernetic.name]"))

/obj/effect/proc_holder/spell/pointed/cyber/analyze/advanced
	name = "Deep cybernetic signature scan"
	action_icon_state = "deep_analyze"
	desc = "Allows you to analyze the opponent's cybernetic signature, allowing you to see their cybernetics and cyberware. Can find cybernetics with obscured signatures."
	basic = FALSE
