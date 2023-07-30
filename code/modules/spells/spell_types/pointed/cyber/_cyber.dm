/obj/effect/proc_holder/spell/pointed/cyber
	school = SCHOOL_CYBERWARE
	clothes_req = FALSE
	invocation_type = INVOCATION_EMOTE
	charge_max = 300
	action_background_icon_state = "cyber"

/obj/effect/proc_holder/spell/pointed/cyber/can_target(atom/target, mob/user, silent)
	if(!iscarbon(target))
		return FALSE

	var/mob/living/carbon/victim = target
	var/obj/item/organ/cyberimp/cyberlink/link = victim.getlink()
	if(!link)
		return FALSE

	return TRUE

