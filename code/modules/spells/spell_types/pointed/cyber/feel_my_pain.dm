/obj/effect/proc_holder/spell/pointed/cyber/feel_my_pain
	name = "FEEL MY PAIN"
	desc = "This abilty transfers the bulk of your implant stress to a target over 10 seconds. Causes a big spike in neural stress to the user."
	school = SCHOOL_CYBERWARE
	clothes_req = FALSE
	invocation_type = INVOCATION_EMOTE
	charge_max = 150
	ranged_mousepointer = 'icons/effects/mouse_pointers/feel_my_pain_target.dmi'
	action_icon_state = "feel_my_pain"
	action_background_icon_state = "cyber"
	active_msg = "You prepare to torture a target..."
	var/total_percentage = 0.75

/obj/effect/proc_holder/spell/pointed/cyber/feel_my_pain/cast(list/targets, mob/user)
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
			caster.implant_stress += 640
		if(1)
			var/mob/living/carbon/human/victim = targets[1]
			victim.getlink().throw_error(7)
			var/mob/living/carbon/human/caster = user
			caster.implant_stress += 640
			caster.emote("scream")
			caster.visible_message(span_danger("[caster] screams at the top of his lungs!"))
			if(prob(10))
				to_chat(caster, span_notice("a red streak runs down your nose..."))
				caster.blood_volume -= 5
			INVOKE_ASYNC(src, PROC_REF(feel_my_pain),victim)

/obj/effect/proc_holder/spell/pointed/cyber/feel_my_pain/proc/feel_my_pain(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	for(var/i in 1 to 10)
		var/stress = user.implant_stress * total_percentage * 0.1
		user.implant_stress -= stress
		victim.implant_stress += stress
		sleep(1 SECONDS)
