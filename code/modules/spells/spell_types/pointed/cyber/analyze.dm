/obj/effect/proc_holder/spell/pointed/analyze
	name = "Shallow cybernetic signature scan"
	desc = "Allows you to analyze the opponent's cybernetic signature, allowing you to see their cybernetics and cyberware. Doesn't find cybernetics with obscured signatures."
	school = SCHOOL_CYBERWARE
	clothes_req = FALSE
	invocation_type = INVOCATION_EMOTE
	charge_max = 300
	ranged_mousepointer = 'icons/effects/mouse_pointers/analyze_target.dmi'
	action_icon_state = "analyze"
	action_background_icon_state = "cyber"
	active_msg = "You prepare to analyze a target..."

	var/basic = TRUE

/obj/effect/proc_holder/spell/pointed/analyze/cast(list/targets, mob/user)
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


/obj/effect/proc_holder/spell/pointed/analyze/can_target(atom/target, mob/user, silent)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/victim = target
	var/obj/item/organ/cyberimp/cyberlink/link = victim.getlink()
	if(!link)
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/pointed/analyze/advanced
	name = "Deep cybernetic signature scan"
	action_icon_state = "deep_analyze"
	desc = "Allows you to analyze the opponent's cybernetic signature, allowing you to see their cybernetics and cyberware. Can find cybernetics with obscured signatures."
	basic = FALSE
