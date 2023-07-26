/obj/effect/proc_holder/spell/pointed/zap
	name = "Induce cybernetic malfunction"
	desc = "This ability causes a minor shortcut in cyberware of a victim with a less powerful cyberlink. If the victim's cyberlink is stronger than the attacker's it causes minor stamina damage. Does nothing on people without a cyberlink. Using this ability causes a spike in neural stress."
	school = SCHOOL_CYBERWARE
	clothes_req = FALSE
	invocation_type = INVOCATION_EMOTE
	charge_max = 300
	ranged_mousepointer = 'icons/effects/mouse_pointers/zap_target.dmi'
	action_icon_state = "cyber_zap"
	action_background_icon_state = "cyber"
	active_msg = "You prepare to zap a target..."

/obj/effect/proc_holder/spell/pointed/zap/cast(list/targets, mob/user)
	. = ..()
	if(length(targets) != 1)
		return
	if(!can_target(targets[1],user))
		return
	switch(cyberlink_overpower_check(user,targets[1]))
		if(-1)
			return
		if(0)
			var/mob/living/carbon/human/victim = targets[1]
			victim.adjustStaminaLoss(35)
			var/obj/item/organ/cyberimp/cyberlink/link = victim.getorganslot(ORGAN_SLOT_LINK)
			link.throw_error(8)
			var/mob/living/carbon/human/caster = user
			caster.implant_stress += 160
		if(1)
			var/mob/living/carbon/human/victim = targets[1]
			victim.Stun(1 SECONDS)
			var/obj/item/organ/cyberimp/cyberlink/link = victim.getorganslot(ORGAN_SLOT_LINK)
			victim.visible_message("Sparks fly off of [victim] as internal circuitry shortcuts!")
			link.throw_error(7)
			var/mob/living/carbon/human/caster = user
			caster.implant_stress += 160

/obj/effect/proc_holder/spell/pointed/zap/can_target(atom/target, mob/user, silent)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/victim = target
	var/obj/item/organ/cyberimp/cyberlink/link = victim.getorganslot(ORGAN_SLOT_LINK)
	if(!link)
		return FALSE

	return TRUE
