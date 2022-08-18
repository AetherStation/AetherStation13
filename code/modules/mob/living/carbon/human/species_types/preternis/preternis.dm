/*
procs:
handle_charge - called in spec_life(),handles the alert indicators,the power loss death and decreasing the charge level
adjust_charge - take a positive or negative value to adjust the charge level
*/

/datum/species/preternis
	name = "Preternis"
	id = "preternis"
	default_color = "FFFFFF"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_RADIMMUNE,TRAIT_MEDICALIGNORE)
	species_traits = list(EYECOLOR,HAIR,LIPS)
	say_mod = "intones"
	attack_verb = "assault"
	meat = /obj/item/food/meat/slab/synthmeat
	toxic_food = NONE
	brutemod = 1.25
	burnmod = 1.5
	draw_robot_hair = TRUE
	mutanteyes = /obj/item/organ/eyes/preternis
	mutantlungs = /obj/item/organ/lungs/preternis
	virus_infect_chance = 20
	virus_resistance_boost = 10 //YEOUTCH,good luck getting it out
	species_language_holder = /datum/language_holder/preternis

	var/charge = PRETERNIS_LEVEL_FULL
	var/eating_msg_cooldown = FALSE
	var/emag_lvl = 0
	var/power_drain = 0.5 //probably going to have to tweak this shit
	var/tesliumtrip = FALSE
	var/draining = FALSE


/datum/species/preternis/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(C, COMSIG_ATOM_EMAG_ACT, .proc/on_emag_act)
	RegisterSignal(C, COMSIG_ATOM_EMP_ACT, .proc/on_emp_act)
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ROBOTIC,FALSE,TRUE)
		BP.burn_reduction = 0
		BP.brute_reduction = 0
		if(istype(BP,/obj/item/bodypart/chest) || istype(BP,/obj/item/bodypart/head))
			continue
		BP.max_damage = 35
	C.grant_language(/datum/language/machine) //learn it once,learn it forever i guess,this isnt removed on species loss to prevent curators from forgetting machine language

/datum/species/preternis/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(C, COMSIG_ATOM_EMP_ACT)
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ORGANIC,FALSE,TRUE)
		BP.burn_reduction = initial(BP.burn_reduction)
		BP.brute_reduction = initial(BP.brute_reduction)
	C.clear_alert("preternis_emag") //this means a changeling can transform from and back to a preternis to clear the emag status but w/e i cant find a solution to not do that
	C.clear_fullscreen("preternis_emag")
	C.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/preternis_teslium, TRUE)

/datum/species/preternis/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER
	switch(severity)
		if(EMP_HEAVY)
			H.adjustBruteLoss(20)
			H.adjustFireLoss(20)
			H.Paralyze(50)
			charge *= 0.4
			H.visible_message(span_danger("Electricity ripples over [H]'s subdermal implants, smoking profusely."), \
							span_userdanger(">A surge of searing pain erupts throughout your very being! As the pain subsides, a terrible sensation of emptiness is left in its wake."))
		if(EMP_LIGHT)
			H.adjustBruteLoss(10)
			H.adjustFireLoss(10)
			H.Paralyze(20)
			charge *= 0.6
			H.visible_message(span_danger("A faint fizzling emanates from [H]."), \
							span_userdanger("A fit of twitching overtakes you as your subdermal implants convulse violently from the electromagnetic disruption. Your sustenance reserves have been partially depleted from the blast."))

/datum/species/preternis/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	if(emag_lvl == 2)
		return
	emag_lvl = min(emag_lvl + 1,2)
	playsound(H.loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
	H.Paralyze(60)
	switch(emag_lvl)
		if(1)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50) //HALP AM DUMB
			to_chat(H,span_danger("ALERT! MEMORY UNIT [rand(1,5)] FAILURE.NERVEOUS SYSTEM DAMAGE."))
		if(2)
			H.overlay_fullscreen("preternis_emag", /atom/movable/screen/fullscreen/high)
			H.throw_alert("preternis_emag", /atom/movable/screen/alert/high/preternis)
			to_chat(H,span_danger("ALERT! OPTIC SENSORS FAILURE.VISION PROCESSOR COMPROMISED."))

/datum/species/preternis/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()

	if(H.reagents.has_reagent(/datum/reagent/fuel/oil))
		H.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)

	if(H.reagents.has_reagent(/datum/reagent/fuel))
		H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)

	if(H.reagents.has_reagent(/datum/reagent/teslium,10)) //10 u otherwise it wont update and they will remain quikk
		H.add_movespeed_modifier(/datum/movespeed_modifier/reagent/preternis_teslium, TRUE)
		if(H.health < 50 && H.health > 0)
			H.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
			H.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)
			H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)
		H.AdjustParalyzed(-3)
		H.AdjustStun(-3)
		H.AdjustKnockdown(-3)
		H.adjustStaminaLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
		charge = clamp(charge - 10 * REAGENTS_METABOLISM,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
		burnmod = 200
		tesliumtrip = TRUE
	else if(tesliumtrip)
		burnmod = initial(burnmod)
		tesliumtrip = FALSE
		H.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/preternis_teslium, TRUE)

	if (istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/food = chem
		if (food.nutriment_factor)
			var/nutrition = food.nutriment_factor * 0.2
			charge = clamp(charge + nutrition,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
			if (!eating_msg_cooldown)
				eating_msg_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, eating_msg_cooldown, FALSE), 2 MINUTES)
				to_chat(H,span_info("NOTICE: Digestive subroutines are inefficient. Seek sustenance via power-cell C.O.N.S.U.M.E. technology induction."))

	if(chem.current_cycle >= 20)
		H.reagents.del_reagent(chem.type)


	return FALSE

/datum/species/preternis/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	charge = PRETERNIS_LEVEL_FULL
	emag_lvl = 0
	H.clear_alert("preternis_emag")
	H.clear_fullscreen("preternis_emag")
	burnmod = initial(burnmod)
	tesliumtrip = FALSE
	H.remove_movespeed_modifier("preternis_teslium") //full heal removes chems so it wont update the teslium speed up until they eat something

/datum/species/preternis/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
	handle_charge(H)

/datum/species/preternis/proc/handle_charge(mob/living/carbon/human/H)
	charge = clamp(charge - power_drain,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
	if(charge == PRETERNIS_LEVEL_NONE)
		to_chat(H,span_danger("Warning! System power criti-$#@$"))
		H.death()
	else if(charge < PRETERNIS_LEVEL_STARVING)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 3)
	else if(charge < PRETERNIS_LEVEL_HUNGRY)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 2)
	else if(charge < PRETERNIS_LEVEL_FED)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 1)
	else
		H.clear_alert("preternis_charge")
