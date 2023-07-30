/obj/effect/proc_holder/spell/pointed/cyber/neural_destabilizer
	name = "Induce slight neural destabilization"
	desc = "This ability sends a wave of sensory information directly into victim's cyberlink, inducing temporary neural destabilization. Causes a spike in sensory data to the user aswell."
	school = SCHOOL_CYBERWARE
	clothes_req = FALSE
	invocation_type = INVOCATION_EMOTE
	charge_max = 150
	ranged_mousepointer = 'icons/effects/mouse_pointers/destabilize_target.dmi'
	action_icon_state = "destabilize_basic"
	action_background_icon_state = "cyber"
	active_msg = "You prepare to destabilize a target..."
	var/strength = 1

/obj/effect/proc_holder/spell/pointed/cyber/neural_destabilizer/cast(list/targets, mob/user)
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
			victim.getlink().throw_error(8)
			var/mob/living/carbon/human/caster = user
			caster.implant_stress += 80
		if(1)
			var/mob/living/carbon/human/victim = targets[1]
			victim.getlink().throw_error(7)
			victim.implant_stress += 320 * strength
			var/mob/living/carbon/human/caster = user
			caster.implant_stress += (100 + 60 * strength)

/obj/effect/proc_holder/spell/pointed/cyber/neural_destabilizer/standard
	name = "Induce neural destabilization"
	charge_max = 200
	action_icon_state = "destabilize"
	strength = 2

/obj/effect/proc_holder/spell/pointed/cyber/neural_destabilizer/advanced
	name = "Induce severe neural destabilization"
	charge_max = 400
	action_icon_state = "destabilize_advanced"
	strength = 4

