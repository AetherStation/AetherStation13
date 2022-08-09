/datum/antagonist/shadowling
	name = "Shadowling"
	roundend_category = "shadowlings"
	antagpanel_category = "Shadowlings"
	antag_moodlet = /datum/mood_event/sling
	var/list/objectives_given = list()

/datum/antagonist/shadowling/on_gain()
	. = ..()
	SSticker.mode.update_shadow_icons_added(owner)
	SSticker.mode.shadows += owner
	owner.special_role = "Shadowling"
	log_game("[key_name(owner.current)] was made into a shadowling!")
	var/mob/living/carbon/human/S = owner.current
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hatch(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hivemind(null))
	if(owner.assigned_role == "Clown")
		to_chat(S, "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>")
		S.dna.remove_mutation(CLOWNMUT)
	var/datum/objective/ascend/O = new
	O.update_explanation_text()
	owner.objectives += O
	objectives_given += O
	owner.announce_objectives()

/datum/antagonist/shadowling/on_removal()
	SSticker.mode.update_shadow_icons_removed(owner)
	SSticker.mode.shadows -= owner
	message_admins("[key_name_admin(owner.current)] was de-shadowlinged!")
	log_game("[key_name(owner.current)] was de-shadowlinged!")
	owner.special_role = null
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		owner.RemoveSpell(S)
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] lets out a short blip.</span>")
		to_chat(M,"<span class='userdanger'>You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a shadowling! Though you try, you cannot remember anything about your time as one...</span>")
	else
		M.visible_message("<span class='big'>[M] screams and contorts!</span>")
		to_chat(M,"<span class='userdanger'>THE LIGHT-- YOUR MIND-- <i>BURNS--</i></span>")
		spawn(30)
			if(QDELETED(M))
				return
			M.visible_message("<span class='warning'>[M] suddenly bloats and explodes!</span>")
			to_chat(M,"<span class='warning bold'>AAAAAAAAA<font size=3>AAAAAAAAAAAAA</font><font size=4>AAAAAAAAAAAA----</font></span>")
			playsound(M, 'sound/magic/Disintegrate.ogg', 100, 1)
			M.gib()
	return ..()

/datum/antagonist/shadowling/greet()
	to_chat(owner, "<br> <span class='shadowling bold big'>You are a shadowling!</span>")
	to_chat(owner, "<b>Currently, you are disguised as an employee aboard [station_name()].</b>")
	to_chat(owner, "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>")
	to_chat(owner, "<b>Any other shadowlings are your allies. You must assist them as they shall assist you.</b>")
	to_chat(owner, "<b>You require [SSticker.mode.required_thralls || 15] thralls to ascend.</b><br>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/sling.ogg'))

/datum/antagonist/shadowling/proc/check_shadow_death()
	for(var/SM in get_antag_minds(/datum/antagonist/shadowling))
		var/datum/mind/shadow_mind = SM
		if(istype(shadow_mind))
			var/turf/T = get_turf(shadow_mind.current)
			if((shadow_mind) && (shadow_mind.current.stat != DEAD) && T && is_station_level(T.z) && ishuman(shadow_mind.current))
				return FALSE
	return TRUE

/datum/objective/ascend
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with 15 or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/datum/objective/ascend/check_completion()
	return (SSticker && SSticker.mode && SSticker.mode.shadowling_ascended)

/datum/objective/ascend/update_explanation_text()
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with [SSticker.mode.required_thralls] or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/mob/living/carbon/human/Stat()
	. = ..()
	if(statpanel("Status") && (dna && dna.species) && istype(dna.species, /datum/species/shadow/ling))
		var/datum/species/shadow/ling/SL = dna.species
		stat("Shadowy Shield Charges", SL.shadow_charges) 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"
	id = "shadowling"
	say_mod = "chitters"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE)
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_EYES, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	nojumpsuit = TRUE
	mutanteyes = /obj/item/organ/eyes/night_vision/alien/sling
	burnmod = 1.5 //1.5x burn damage, 2x is excessive
	heatmod = 1.5
	var/mutable_appearance/eyes_overlay
	var/shadow_charges = 3
	var/last_charge = 0

/datum/species/shadow/ling/on_species_gain(mob/living/carbon/human/C)
	eyes_overlay = mutable_appearance('icons/mob/sling.dmi', "eyes", 25)
	C.add_overlay(eyes_overlay)
	. = ..()

/datum/species/shadow/ling/on_species_loss(mob/living/carbon/human/C)
	if(eyes_overlay)
		C.cut_overlay(eyes_overlay)
		QDEL_NULL(eyes_overlay)
	. = ..()

/datum/species/shadow/ling/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/light_amount = T.get_lumcount()
		if(light_amount > LIGHT_DAM_THRESHOLD) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, "<span class='userdanger'>The light burns you!</span>") //Message spam to say "GET THE FUCK OUT"
				H.playsound_local(get_turf(H), 'sound/weapons/sear.ogg', 150, 1, pressure_affected = FALSE)
		else if (light_amount < LIGHT_HEAL_THRESHOLD  && !istype(H.loc, /obj/effect/dummy/phased_mob/shadowling)) //Can't heal while jaunting
			H.heal_overall_damage(5,5)
			H.adjustToxLoss(-5)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -25) //Shad O. Ling gibbers, "CAN U BE MY THRALL?!!"
			H.adjustCloneLoss(-1)
			H.SetKnockdown(0)
			H.SetStun(0)
	var/charge_time = 400 - ((SSticker.mode.thralls && SSticker.mode.thralls.len) || 0)*10
	if(world.time >= charge_time+last_charge)
		shadow_charges = min(shadow_charges + 1, 3)
		last_charge = world.time

/datum/species/shadow/ling/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T) && shadow_charges > 0)
		var/light_amount = T.get_lumcount()
		if(light_amount < LIGHT_DAM_THRESHOLD)
			H.visible_message("<span class='danger'>The shadows around [H] ripple as they absorb \the [P]!</span>")
			playsound(T, "bullet_miss", 75, 1)
			shadow_charges = min(shadow_charges - 1, 0)
			return -1
	return 0

/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = "Lesser Shadowling"
	id = "l_shadowling"
	say_mod = "chitters"
	species_traits = list(NOBLOOD,NO_DNA_COPY,NOTRANSSTING,NOEYES)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RADIMMUNE)
	burnmod = 1.1
	heatmod = 1.1

/datum/species/shadow/ling/lesser/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/light_amount = T.get_lumcount()
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move)
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
		else if (light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(2,2)
			H.adjustToxLoss(-5)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -25)
			H.adjustCloneLoss(-1)

/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((is_shadow(shadow_mind.current)) ? "shadowling" : "thrall"))

/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)

/mob/living/proc/add_thrall()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(ANTAG_DATUM_THRALL)

/mob/living/proc/add_sling()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(ANTAG_DATUM_SLING)

/mob/living/proc/remove_thrall()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(ANTAG_DATUM_THRALL)

/mob/living/proc/remove_sling()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(ANTAG_DATUM_SLING) 

/datum/game_mode
	var/list/datum/mind/shadows = list()
	var/list/datum/mind/thralls = list()
	var/required_thralls = 15 //How many thralls are needed (this is changed in pre_setup, so it scales based on pop)
	var/shadowling_ascended = FALSE //If at least one shadowling has ascended
	var/thrall_ratio = 1
