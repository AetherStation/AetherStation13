#define EMPOWERED_THRALL_LIMIT 3w

/obj/effect/proc_holder/spell/proc/shadowling_check(mob/living/carbon/human/H)
	if(!H || !istype(H)) return
	if(H.dna && H.dna.species && H.dna.species.id == "shadowling" && IS_SHADOW(H)) return TRUE
	if(H.dna && H.dna.species && H.dna.species.id == "l_shadowling" && IS_THRALL(H)) return TRUE

	if(!IS_SHADOW_OR_THRALL(usr)) to_chat(usr, span_warning("You can't wrap your head around how to do this."))
	else if(IS_THRALL(usr)) to_chat(usr, span_warning("You aren't powerful enough to do this."))
	else if(IS_SHADOW(usr)) to_chat(usr, span_warning("Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first."))
	return FALSE
	
/obj/effect/proc_holder/spell/targeted/shadowling //Stuns and mutes a human target for 10 seconds
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/mob/living/user
	var/mob/living/target

/obj/effect/proc_holder/spell/targeted/shadowling/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = span_warning("You can no longer cast [name]!")
		remove_ranged_ability(msg)
		return
	if(active)
		remove_ranged_ability()
	else
		add_ranged_ability(user, null, TRUE)
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/targeted/shadowling/InterceptClickOn(mob/living/caller, params, atom/t)
	if(!isliving(t))
		to_chat(caller, span_warning("You may only use this ability on living things!"))
		revert_cast()
		return
	user = caller
	target = t
	if(!shadowling_check(user))
		revert_cast()
		return

/obj/effect/proc_holder/spell/targeted/shadowling/revert_cast()
	. = ..()
	remove_ranged_ability()

/obj/effect/proc_holder/spell/targeted/shadowling/start_recharge()
	. = ..()
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/targeted/shadowling/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities."
	panel = "Shadowling Abilities"
	charge_max = 300
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "glare"
	action_icon = 'icons/mob/actions.dmi'

/obj/effect/proc_holder/spell/targeted/shadowling/glare/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(!target)
		return
	if(target.stat)
		to_chat(usr, span_warning("[target] must be conscious!"))
		revert_cast()
		return
	if(IS_SHADOW_OR_THRALL(target))
		to_chat(usr, span_warning("You cannot glare at allies!"))
		revert_cast()
		return
	var/mob/living/carbon/human/M = target
	usr.visible_message(span_warning("<b>[usr]'s eyes flash a purpleish-red!"))
	var/distance = get_dist(target, usr)
	if (distance <= 2)
		target.visible_message(span_danger("[target] suddendly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes across your vision, and you lose control of your movements!"))
		target.Paralyze(10 SECONDS)
		M.silent += 10
	else //Distant glare
		var/loss = 100 - (distance * 10)
		target.adjustStaminaLoss(loss)
		target.stuttering = loss
		to_chat(target, span_userdanger("A purple light flashes across your vision, and exhaustion floods your body..."))
		target.visible_message(span_danger("[target] looks very tired..."))
	charge_counter = 0
	start_recharge()
	remove_ranged_ability()

/obj/effect/proc_holder/spell/aoe_turf/veil //Puts out most nearby lights except for flares and yellow slime cores
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 150 //Short cooldown because people can just turn the lights back on
	human_req = TRUE
	clothes_req = FALSE
	range = 5
	action_icon_state = "veil"
	action_icon = 'icons/mob/actions.dmi'
	var/admin_override = FALSE ///Requested by Shadowlight213. Allows anyone to cast the spell, not just shadowlings.
	var/emp_strength = 2
	var/camera_emp_chance = 10

/obj/effect/proc_holder/spell/aoe_turf/proc/extinguishItem(obj/item/I, cold = FALSE) //Does not darken items held by mobs due to mobs having separate luminosity, use extinguishMob() or write your own proc.
	var/blacklisted_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		if(F.on)
			if(!cold)
				return
			if(is_type_in_list(F, blacklisted_lights))
				F.visible_message(span_warning("The sheer cold shatters [F]!"))
				qdel(F)
			if(is_type_in_list(I, blacklisted_lights))
				I.visible_message(span_userdanger("[I] dims slightly before scattering the shadows around it."))
				return F.on //Necessary because flashlights become 0-luminosity when held.  I don't make the rules of lightcode.
			F.on = FALSE
			F.update_brightness()
	else if(istype(I, /obj/item/pda))
		var/obj/item/pda/P = I
		P.set_light_on(FALSE)
		P.update_appearance()
		P.update_action_buttons(force = TRUE)
	I.set_light(0)
	return I.luminosity

/obj/effect/proc_holder/spell/aoe_turf/proc/extinguishMob(mob/living/H, cold = FALSE)
	for(var/obj/item/F in H)
		if(cold)
			extinguishItem(F, TRUE)
		extinguishItem(F)

/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user) && !admin_override)
		revert_cast()
		return
	to_chat(user, span_shadowling("You silently disable all nearby lights."))
	var/turf/T = get_turf(user)
	var/list/light_corners = list(T.lighting_corner_NE, T.lighting_corner_SE, T.lighting_corner_SW, T.lighting_corner_NW) //Idk how to do this another way
	for(var/datum/lighting_corner/LC in light_corners)
		for(var/datum/light_source/LS in LC.affecting)
			var/atom/LO = LS.source_atom
			if(isitem(LO))
				extinguishItem(LO)
				continue
			if(istype(LO, /obj/machinery/light))
				var/obj/machinery/light/L = LO
				L.on = FALSE
				L.visible_message(span_warning("[L] flickers and falls dark."))
				L.update(0)
				L.set_light(0)
				continue
			if(istype(LO, /obj/machinery/computer) || istype(LO, /obj/machinery/power/apc))
				LO.set_light(0)
				LO.visible_message(span_warning("[LO] grows dim, its screen barely readable."))
				continue
			if(ismob(LO))
				extinguishMob(LO)
			if(istype(LO, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/borg = LO
				if(borg.lamp_enabled)
					borg.smash_headlamp()
					to_chat(borg, span_userdanger("The lightbulb in your headlamp is fried! You'll need a human to help replace it."))
			if(istype(LO, /obj/machinery/camera))
				LO.set_light(0)
				if(prob(camera_emp_chance))
					LO.emp_act(emp_strength)
				continue
			if(istype(LO, /obj/vehicle/sealed/mecha))
				var/obj/vehicle/sealed/mecha/M = LO
				M.mecha_flags &= ~HAS_LIGHTS
				M.visible_message(span_danger("[M]'s lights burn out!"))
				M.set_light_on(FALSE)
				for(var/occupant in M.occupants)
					M.remove_action_type_from_mob(/datum/action/vehicle/sealed/mecha/mech_toggle_lights, occupant)
			if(istype(LO, /obj/machinery/power/floodlight))
				var/obj/machinery/power/floodlight/FL = LO
				FL.change_setting(2) // Set floodlight to lowest setting
			
	for(var/obj/structure/glowshroom/G in orange(7, user)) //High radius because glowshroom spam wrecks shadowlings
		if(!istype(G, /obj/structure/glowshroom/shadowshroom))
			var/obj/structure/glowshroom/shadowshroom/S = new /obj/structure/glowshroom/shadowshroom(G.loc) //I CAN FEEL THE WARP OVERTAKING ME! IT IS A GOOD PAIN!
			S.generation = G.generation
			G.visible_message("<span class='warning'>[G] suddenly turns dark!</span>")
			qdel(G)

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 250
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "icy_veins"
	sound = 'sound/effects/ghost2.ogg'
	var/special_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	var/bodytemp_change = -200
	var/burn_dmg_amount = 10
	var/frostoil_amount = 25

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You freeze the nearby air.</span>")
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(IS_SHADOW_OR_THRALL(M))
				if(M != user) //No message for the user, of course
					to_chat(M, span_danger("You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!"))
					continue
			to_chat(M, span_userdanger("A wave of shockingly cold air engulfs you!"))
			M.Stun(2)
			M.apply_damage(burn_dmg_amount, BURN)
			if(M.bodytemperature)
				M.adjust_bodytemperature(bodytemp_change, 50)
			if(M.reagents)
				M.reagents.add_reagent(/datum/reagent/consumable/frostoil, frostoil_amount) //Half of a cryosting
			extinguishMob(M, TRUE)
		for(var/obj/item/F in T.contents)
			extinguishItem(F, TRUE)

/obj/effect/proc_holder/spell/targeted/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = TRUE
	clothes_req = FALSE
	range = 1 //Adjacent to user
	action_icon_state = "enthrall"
	action_icon = 'icons/mob/actions.dmi'
	var/enthralling = FALSE ///Are we already enthralling someone

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets,mob/living/carbon/human/user = usr)
	if(!(user.mind in SSticker.mode.shadows)) return
	if(user.dna.species.id != "shadowling")
		if(SSticker.mode.thralls.len >= 5)
			revert_cast()
			return
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(user, target))
			to_chat(user, span_warning("You need to be closer to enthrall [target]!"))
			revert_cast()
			return
		if(!target.key || !target.mind)
			to_chat(user, span_warning("The target has no mind!"))
			revert_cast()
			return
		if(target.stat)
			to_chat(user, span_warning("The target must be conscious!"))
			revert_cast()
			return
		if(IS_SHADOW_OR_THRALL(target))
			to_chat(user, span_warning("You can not enthrall allies!"))
			revert_cast()
			return
		if(!ishuman(target))
			to_chat(user, span_warning("You can only enthrall humans!"))
			revert_cast()
			return
		if(enthralling)
			to_chat(user, span_warning("You are already enthralling!"))
			revert_cast()
			return
		if(!target.client)
			to_chat(user, span_warning("[target]'s mind is vacant of activity."))
		enthralling = TRUE
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					to_chat(user, span_notice("You place your hands to [target]'s head..."))
					user.visible_message(span_warning("[user] places their hands onto the sides of [target]'s head!<"))
				if(2)
					to_chat(user, span_notice("You begin preparing [target]'s mind as a blank slate..."))
					user.visible_message(span_warning("[user]'s palms flare a bright red against [target]'s temples!"))
					to_chat(target, span_danger("A terrible red light floods your mind. You collapse as conscious thought is wiped away."))
					target.Knockdown(120)
					if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
						to_chat(user, span_notice("They are protected by an implant. You begin to shut down the nanobots in their brain - this will take some time..."))
						user.visible_message(span_warning("[user] pauses, then dips their head in concentration!"))
						to_chat(target, span_boldannounce("You feel your mental protection faltering!"))
						if(!do_mob(user, target, 650)) //65 seconds to remove a loyalty implant. yikes!
							to_chat(user, span_warning("The enthralling has been interrupted - your target's mind returns to its previous state."))
							to_chat(target, span_userdanger("You wrest yourself away from [user]'s hands and compose yourself!"))
							enthralling = FALSE
							return
						to_chat(user, span_notice("The nanobots composing the mindshield implant have been rendered inert. Now to continue."))
						user.visible_message(span_warning("[user] relaxes again.</span>"))
						for(var/obj/item/implant/mindshield/L in target)
							if(L)
								qdel(L)
						to_chat(target, span_boldannounce("Your mental protection unexpectedly falters, dims, dies."))
				if(3)
					to_chat(user, span_notice("You begin planting the tumor that will control the new thrall..."))
					user.visible_message(span_warning("A strange energy passes from [user]'s hands into [target]'s head!"))
					to_chat(target, span_boldannounce("You feel your memories twisting, morphing. A sense of horror dominates your mind."))
			if(!do_mob(user, target, 70)) //around 21 seconds total for enthralling, 86 for someone with a loyalty implant
				to_chat(user, span_warning("The enthralling has been interrupted - your target's mind returns to its previous state."))
				to_chat(target, span_userdanger("You wrest yourself away from [user]'s hands and compose yourself!"))
				enthralling = FALSE
				return
		enthralling = FALSE
		to_chat(user, span_shadowling("You have enthralled <b>[target.real_name]</b>!"))
		target.visible_message(span_big("[target] looks to have experienced a revelation!"), \
							   span_warning("False faces all d<b>ark not real not real not--</b>"))
		target.setOxyLoss(0) //In case the shadowling was choking them out
		target.mind.special_role = "thrall"
		var/obj/item/organ/internal/shadowtumor/shadow_tumor = new
		shadow_tumor.Insert(target, FALSE, FALSE)
		target.add_thrall()
		if(target.reagents.has_reagent(/datum/reagent/consumable/frostoil)) //Stabilize body temp incase the shadowling froze them earlier
			target.reagents.remove_reagent(/datum/reagent/consumable/frostoil)
			to_chat(target, span_notice("You feel warmer... It feels good."))
			target.bodytemperature = 310

/obj/effect/proc_holder/spell/self/shadowling_hivemind //Lets a shadowling talk to its allies
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/shadowling_hivemind/cast(mob/living/user,mob/user = usr)
	if(!IS_SHADOW(user))
		to_chat(user, span_warning("You must be a shadowling to do that!"))
		return
	var/text = stripped_input(user, "What do you want to say your thralls and fellow shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	var/my_message = "<span class='shadowling command_headset'><b>\[Shadowling\]</b><i> [user.real_name]</i>: [text]</span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(IS_SHADOW_OR_THRALL(M))
			to_chat(M, my_message)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [my_message]")
	log_say("[user.real_name]/[user.key] : [text]")

/obj/effect/proc_holder/spell/self/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "regen_armor"

/obj/effect/proc_holder/spell/self/shadowling_regenarmor/cast(mob/living/carbon/human/user)
	if(!IS_SHADOW(user))
		to_chat(user, span_warning("You must be a shadowling to do this!"))
		revert_cast()
		return
	user.visible_message(span_warning("[user]'s skin suddenly bubbles and shifts around their body!"), \
						span_shadowling("You regenerate your protective armor and cleanse your form of defects."))
	user.setCloneLoss(0)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), ITEM_SLOT_OCLOTHING)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), ITEM_SLOT_HEAD)
	user.set_species(/datum/species/shadow/ling)

/obj/effect/proc_holder/spell/self/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "collective_mind"
	action_icon = 'icons/mob/actions.dmi'
	var/blind_smoke_acquired = FALSE
	var/screech_acquired = FALSE
	var/revive_thrall_acquired = FALSE
	var/null_charge_acquired = FALSE

/obj/effect/proc_holder/spell/self/collective_mind/cast(mob/living/carbon/human/user)
	if(!shadowling_check(user))
		revert_cast()
		return
	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	var/mob/M
	to_chat(user, span_shadowling("<b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b>"))
	for(M in GLOB.alive_mob_list)
		if(IS_THRALL(M))
			thralls++
			to_chat(M, span_shadowling("You feel hooks sink into your mind and pull."))
	if(!do_after(user, 30, target = user))
		to_chat(user, span_warning("Your concentration has been broken. The mental hooks you have sent out now retract into your mind."))
		return
	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms."))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech(null))
	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/self/blindness_smoke(null))
	if(thralls >= CEILING(7 * SSticker.mode.thrall_ratio, 1) && !null_charge_acquired)
		null_charge_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Null Charge</b> ability. This ability will drain an APC's contents to the void, preventing it from recharging \
		or sending power until repaired.</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/self/null_charge(null))
	if(thralls >= CEILING(9 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
		with no bodily defects.</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/revive_thrall(null))
	if(thralls < victory_threshold)
		to_chat(user, span_shadowling("You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present."))
	else if(thralls >= victory_threshold)
		to_chat(user, span_shadowling("<b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i>"))
		to_chat(user, span_shadowling("<b>You may find Ascendance in the Shadowling Evolution tab.</b>"))
		for(M in GLOB.alive_mob_list)
			if(IS_SHADOW(M))
				var/obj/effect/proc_holder/spell/self/collective_mind/CM
				if(CM in M.mind.spell_list)
					M.mind.spell_list -= CM
					qdel(CM)
				M.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/shadowling_hatch)
				M.mind.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_ascend(null))
				if(M == user)
					to_chat(user, span_shadowling("<i>You project this power to the rest of the shadowlings.</i><"))
				else
					to_chat(M, span_shadowling("<b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b>")) //Tells all the other shadowlings

/obj/effect/proc_holder/spell/self/null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "null_charge"

/obj/effect/proc_holder/spell/self/null_charge/cast(mob/living/carbon/human/user)
	if(!shadowling_check(user))
		revert_cast()
		return

	var/list/local_objs = view(1, user)
	var/obj/machinery/power/apc/target_apc
	for(var/object in local_objs)
		if(istype(object, /obj/machinery/power/apc))
			target_apc = object
			break

	if(!target_apc)
		to_chat(user, span_warning("You must stand next to an APC to drain it!"))
		revert_cast()
		return

	//Free veil since you have to stand next to the thing for a while to depower it.
	target_apc.set_light(0)
	target_apc.visible_message(span_warning("The [target_apc] flickers and begins to grow dark."))

	to_chat(user, span_shadowling("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(user, 200, target=target_apc))
		//Whoops!  The APC's light turns back on
		to_chat(user, span_shadowling("Your concentration breaks and the APC suddenly repowers!"))
		target_apc.set_light(2)
		target_apc.visible_message(span_warning("The [target_apc] begins glowing brightly!"))
	else
		//We did it
		to_chat(user, span_shadowling("You return the APC's power to the void, disabling it."))
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = 0 //Won't recharge either until an engineer hits the button
		target_apc.charging = 0
		target_apc.update_icon()

/obj/effect/proc_holder/spell/self/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "black_smoke"
	action_icon = 'icons/mob/actions.dmi'
	sound = 'sound/effects/bamf.ogg'

/obj/effect/proc_holder/spell/self/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky
	if(!shadowling_check(user))
		revert_cast()
		return
	user.visible_message(span_warning("[user] bends over and coughs out a cloud of black smoke!"))
	to_chat(user, span_shadowling("You regurgitate a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/smoke_container = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	smoke_container.reagents.clear_reagents() //Just in case!
	smoke_container.invisibility = INFINITY //This ought to do the trick
	smoke_container.reagents.add_reagent(/datum/reagent/shadowling_blindness_smoke, 10)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(smoke_container)
	if(S)
		S.set_up(smoke_container.reagents, 4, 0, smoke_container.loc)
		S.start()
	qdel(smoke_container)

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech //Damages nearby windows, confuses nearby carbons, and outright stuns silly cones
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "screech"
	action_icon = 'icons/mob/actions.dmi'
	sound = 'sound/effects/screech.ogg'

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	user.audible_message(span_warning("<b>[user] lets out a horrible scream!</b>"))
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(IS_SHADOW_OR_THRALL(target))
				if(target == user) //No message for the user, of course
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, span_danger("<b>A spike of pain drives into your head and scrambles your thoughts!</b>"))
				M.add_confusion(15)
				var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
				if(ears)
					ears.adjustEarDamage(0, 30)//as bad as a changeling shriek
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, span_warning("<b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b>"))
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Paralyze(6)
		for(var/obj/structure/window/W in T.contents)
			W.take_damage(rand(80, 100))

/obj/effect/proc_holder/spell/targeted/revive_thrall //Completely revives a dead thrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	include_user = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "revive_thrall"

/obj/effect/proc_holder/spell/targeted/revive_thrall/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	for(var/mob/living/carbon/human/thrallToRevive in targets)
		var/choice = alert(user,"Empower a living thrall or revive a dead one?",,"Empower","Revive","Cancel")
		switch(choice)
			if("Empower")
				if(!IS_THRALL(thrallToRevive))
					to_chat(user, "<span class='warning'>[thrallToRevive] is not a thrall.</span>")
					revert_cast()
					return
				if(thrallToRevive.stat != CONSCIOUS)
					to_chat(user, "<span class='warning'>[thrallToRevive] must be conscious to become empowered.</span>")
					revert_cast()
					return
				if(thrallToRevive.dna.species.id == "l_shadowling")
					to_chat(user, "<span class='warning'>[thrallToRevive] is already empowered.</span>")
					revert_cast()
					return
				var/empowered_thralls = 0
				for(var/datum/mind/M in SSticker.mode.thralls)
					if(!ishuman(M.current))
						return
					var/mob/living/carbon/human/H = M.current
					if(H.dna.species.id == "l_shadowling")
						empowered_thralls++
				if(empowered_thralls >= EMPOWERED_THRALL_LIMIT)
					to_chat(user, "<span class='warning'>You cannot spare this much energy. There are too many empowered thralls.</span>")
					revert_cast()
					return
				user.visible_message("<span class='danger'>[user] places their hands over [thrallToRevive]'s face, red light shining from beneath.</span>", \
									"<span class='shadowling'>You place your hands on [thrallToRevive]'s face and begin gathering energy...</span>")
				to_chat(thrallToRevive, "<span class='userdanger'>[user] places their hands over your face. You feel energy gathering. Stand still...</span>")
				if(!do_mob(user, thrallToRevive, 80))
					to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
					revert_cast()
					return
				to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
				user.visible_message("<span class='boldannounce'><i>Red lightning surges into [thrallToRevive]'s face!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				user.Beam(thrallToRevive,icon_state="red_lightning",time=1)
				thrallToRevive.Knockdown(5)
				thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] collapses, their skin and face distorting!</span>", \
											   "<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")
				if (!do_mob(user, thrallToRevive, 5))
					thrallToRevive.Unconscious(600)
					thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] gasps, and passes out!</b></span>", "<span class='warning'><i>That... feels nice....</i></span>")
					to_chat(user, "<span class='warning'>We have been interrupted! [thrallToRevive] will need to rest to recover.</span>")
					return
				thrallToRevive.visible_message("<span class='warning'>[thrallToRevive] slowly rises, no longer recognizable as human.</span>", \
											   "<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in \
												darkness but wither slowly in light. In addition, Lesser Glare and Guise have been upgraded into their true forms, and you've been given the ability to turn off nearby lights.</b></span>")
				thrallToRevive.set_species(/datum/species/shadow/ling/lesser)
				thrallToRevive.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/lesser_glare)
				thrallToRevive.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/lesser_shadow_walk)
				thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling/glare(null))
				thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/veil(null))
			if("Revive")
				if(!IS_THRALL(thrallToRevive))
					to_chat(user, "<span class='warning'>[thrallToRevive] is not a thrall.</span>")
					revert_cast()
					return
				if(thrallToRevive.stat != DEAD)
					to_chat(user, "<span class='warning'>[thrallToRevive] is not dead.</span>")
					revert_cast()
					return
				if(HAS_TRAIT(thrallToRevive, TRAIT_BADDNA))
					to_chat(user, "<span class='warning'>[thrallToRevive] is too far gone.</span>")
					revert_cast()
					return
				user.visible_message("<span class='danger'>[user] kneels over [thrallToRevive], placing their hands on \his chest.</span>", \
									"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
				thrallToRevive.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.", source = thrallToRevive)
				if(!do_mob(user, thrallToRevive, 30))
					to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
					revert_cast()
					return
				to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
				user.visible_message("<span class='boldannounce'><i>Red lightning surges from [user]'s hands into [thrallToRevive]'s chest!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				user.Beam(thrallToRevive,icon_state="red_lightning",time=1)
				var/b = do_mob(user, thrallToRevive, 20)
				if(thrallToRevive.revive(full_heal = 1))
					thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] heaves in breath, dim red light shining in their eyes.</span>", \
											   "<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
					thrallToRevive.Knockdown(4)
					thrallToRevive.emote("gasp")
					playsound(thrallToRevive, "bodyfall", 50, 1)
					if (!b)
						thrallToRevive.Knockdown(50)
						thrallToRevive.Unconscious(500)
						thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] collapses in exhaustion.</span>", \
						   "<span class='warning'><b><i>You collapse in exhaustion... nap..... dark.</b></i></span>")
			if("Cancell")
				revert_cast()
				return

/obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Sacrifice a thrall to extend the time of the emergency shuttle's arrival by ten minutes. This can only be used once."
	panel = "Shadowling Abilities"
	range = 1
	human_req = TRUE
	clothes_req = FALSE
	charge_max = 600
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "extend_shuttle"

/obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat)
			revert_cast()
			return
		if(!IS_THRALL(target))
			to_chat(user, "<span class='warning'>[target] must be a thrall.</span>")
			revert_cast()
			return
		if(SSshuttle.emergency.mode != SHUTTLE_CALL)
			to_chat(user, "span class='warning'>The shuttle must be inbound only to the station.</span>")
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'>[user]'s eyes flash a bright red!</span>", \
						  "<span class='notice'>You begin to draw [M]'s life force.</span>")
		M.visible_message("<span class='warning'>[M]'s face falls slack, their jaw slightly distending.</span>", \
						  "<span class='boldannounce'>You are suddenly transported... far, far away...</span>")
		if(!do_after(user, 50, target = M))
			to_chat(M, "<span class='warning'>You are snapped back to reality, your haze dissipating!</span>")
			to_chat(user, "<span class='warning'>You have been interrupted. The draw has failed.</span>")
			return
		to_chat(user, "<span class='notice'>You project [M]'s life force toward the approaching shuttle, extending its arrival duration!</span>")
		M.visible_message("<span class='warning'>[M]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing.</span>", \
						  "<span class='warning'><b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all...</span>")
		M.dust()
		if(SSshuttle.emergency.mode == SHUTTLE_CALL)
			var/more_minutes = 10 MINUTES
			var/timer = SSshuttle.emergency.timeLeft()
			timer += more_minutes
			priority_announce("Major system failure aboard the emergency shuttle. This will extend its arrival time by approximately 15 minutes...", "System Failure", 'sound/misc/notice1.ogg')
			SSshuttle.emergency.setTimer(timer)
			SSshuttle.emergencyNoRecall = TRUE
		user.mind.spell_list.Remove(src) //Can only be used once!
		qdel(src)

//Loosely adapted from the Nightmare's Shadow Walk, but different enough that
//inheriting would have been more hacky code.
//Unlike Shadow Walk, jaunting shadowlings can move through lit areas unmolested,
//but take a constant stamina penalty while jaunting.
/obj/effect/proc_holder/spell/targeted/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	panel = "Shadowling Abilities"
	charge_max = 800
	clothes_req = FALSE
	antimagic_allowed = TRUE
	phase_allowed = TRUE
	selection_type = "range"
	range = -1
	include_user = TRUE
	overlay = null
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "jaunt"

	var/apply_damage = TRUE

/obj/effect/proc_holder/spell/targeted/void_jaunt/cast(list/targets,mob/living/user = usr)
	if(!shadowling_check(user) && !istype(user, /mob/living/simple_animal/ascendant_shadowling))
		revert_cast()
		return
	var/L = user.loc
	if(istype(user.loc, /obj/effect/dummy/phased_mob/shadowling))
		var/obj/effect/dummy/phased_mob/shadowling/S = L
		S.end_jaunt(FALSE)
		return
	else
		playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
		if(apply_damage)
			user.visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>",
													"<span class='shadowling'>Steeling yourself, you dive into the void.</span>")
		else
			user.visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>",
													"<span class='shadowling'>You allow yourself to fall into the void.</span>")
		user.SetAllImmobility(0)
		user.setStaminaLoss(0, 0)
		var/obj/effect/dummy/phased_mob/shadowling/S2 = new(get_turf(user.loc))
		S2.apply_damage = apply_damage
		user.forceMove(S2)
		S2.jaunter = user
		charge_counter = charge_max //Don't have to wait for cooldown to exit

///Amount of stamina damage dealed to shadowling when they exit this. Both have to be high to cancel out natural regeneration
#define VOIDJAUNT_STAM_PENALTY_DARK 10
#define VOIDJAUNT_STAM_PENALTY_LIGHT 35

/obj/effect/dummy/phased_mob/shadowling
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/apply_damage = TRUE
	var/move_delay = 0			//Time until next move allowed
	var/move_speed = 2			//Deciseconds per move

/obj/effect/dummy/phased_mob/shadowling/relaymove(mob/user, direction)
	if(move_delay > world.time && apply_damage)	//Ascendants get no slowdown
		return

	move_delay = world.time + move_speed
	var/turf/newLoc = get_step(src,direction)
	forceMove(newLoc)

/obj/effect/dummy/phased_mob/shadowling/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > LIGHT_DAM_THRESHOLD)	//Increased penalty
		jaunter.apply_damage(VOIDJAUNT_STAM_PENALTY_LIGHT, STAMINA)
	else
		jaunter.apply_damage(VOIDJAUNT_STAM_PENALTY_DARK, STAMINA)

/obj/effect/dummy/phased_mob/shadowling/proc/end_jaunt(forced = FALSE)
	if(jaunter)
		jaunter.forceMove(get_turf(src))
		if(forced)
			jaunter.visible_message("<span class='boldwarning'>A dark shape stumbles from a hole in the air and collapses!</span>",
															"<span class='shadowling'><b>Straining, you use the last of your energy to force yourself from the void.</b></span>")
		else
			jaunter.visible_message("<span class='boldwarning'>A dark shape tears itself from nothingness!</span>",
															"<span class='shadowling'>You exit the void.</span>")

		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunter = null
	qdel(src)

/obj/effect/dummy/phased_mob/shadowling/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadowling/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/phased_mob/shadowling/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

	if(apply_damage)
		check_light_level()

		//True if jaunter entered stamcrit
		if(jaunter.IsParalyzed())
			end_jaunt(TRUE)
			return

/obj/effect/dummy/phased_mob/shadowling/ex_act()
	return

/obj/effect/dummy/phased_mob/shadowling/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/shadowling/singularity_act()
	return

#undef VOIDJAUNT_STAM_PENALTY_DARK
#undef VOIDJAUNT_STAM_PENALTY_LIGHT

// THRALL ABILITIES BEYOND THIS POINT //
/obj/effect/proc_holder/spell/targeted/lesser_glare //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Glare"
	desc = "Makes a single target dizzy for a bit."
	panel = "Thrall Abilities"
	charge_max = 450
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "glare"

/obj/effect/proc_holder/spell/targeted/lesser_glare/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		if(!ishuman(target) || !target)
			to_chat(user, "<span class='warning'>You nay only glare at humans!</span>")
			revert_cast()
			return
		if(target.stat)
			to_chat(user, "<span class='warning'>[target] must be conscious!</span>")
			revert_cast()
			return
		if(IS_SHADOW_OR_THRALL(target))
			to_chat(user, "<span class='warning'>You cannot glare at allies!</span>")
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'><b>[user]'s eyes flash a bright red!</b></span>")
		target.visible_message("<span class='danger'>[target] suddendly looks dizzy and nauseous...</span>")
		if(in_range(target, user))
			to_chat(target, "<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you suddendly feel dizzy and nauseous...</span>")
		else //Only alludes to the thrall if the target is close by
			to_chat(target, "<span class='userdanger'>Red lights suddenly dance in your vision, and you suddendly feel dizzy and nauseous...</span>")
		M.add_confusion(25)
		M.Jitter(50)
		if(prob(25))
			M.vomit(10)

/obj/effect/proc_holder/spell/self/lesser_shadow_walk //Thrall version of Shadow Walk, only works in darkness, doesn't grant phasing, but gives near-invisibility
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	charge_max = 1200
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/proc/reappear(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")
	user.alpha = initial(user.alpha)

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/cast(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
	user.alpha = 10
	addtimer(CALLBACK(src, .proc/reappear, user), 40)

/obj/effect/proc_holder/spell/self/thrall_night_vision //Toggleable night vision for thralls
	name = "Thrall Darksight"
	desc = "Allows you to see in the dark!"
	action_icon_state = "darksight"
	action_icon = 'icons/mob/actions.dmi'
	clothes_req = FALSE
	charge_max = 0

/obj/effect/proc_holder/spell/self/thrall_night_vision/cast(mob/living/carbon/human/user)
	if(!IS_SHADOW_OR_THRALL(user))
		revert_cast()
		return
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	eyes.sight_flags = initial(eyes.sight_flags)
	switch(eyes.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			eyes.see_in_dark = 8
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			eyes.see_in_dark = 2	//default
	user.update_sight()

/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind //Lets a thrall talk with their allies
	name = "Lesser Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Thrall Abilities"
	charge_max = 50
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind/cast(mob/living/carbon/human/user)
	if(!IS_SHADOW_OR_THRALL(user))
		to_chat(user, "<span class='warning'><b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b></span>")
		user.apply_damage(10, BRUTE, "head")
		return
	var/text = stripped_input(user, "What do you want to say your masters and fellow thralls?.", "Lesser Commune", "")
	if(!text)
		return
	text = "<span class='shadowling'><b>\[Thrall\]</b><i> [user.real_name]</i>: [text]</span>"
	for(var/T in GLOB.alive_mob_list)
		var/mob/M = T
		if(IS_SHADOW_OR_THRALL(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")




// ASCENDANT ABILITIES BEYOND THIS POINT //
// YES THEY'RE OP, BUT THEY'VE WON AT THE POINT WHERE THEY HAVE THIS, SO WHATEVER. //
/obj/effect/proc_holder/spell/targeted/shadowling/annihilate //Gibs someone instantly.
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon_state = "annihilate"
	action_icon = 'icons/mob/actions.dmi'
	sound = 'sound/magic/Staff_Chaos.ogg'

/obj/effect/proc_holder/spell/targeted/shadowling/annihilate/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	var/mob/living/boom = target
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	if(IS_SHADOW(boom)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Making an ally explode seems unwise.<span>")
		revert_cast()
		return
	if(istype(boom, /mob/living/simple_animal/pet/dog/corgi))
		to_chat(user, "<span class='warning'>Not even we are that bad of monsters..<span>")
		revert_cast()
		return
	if (!boom.is_holding(/obj/item/storage/backpack/holding)) //so people actually have a chance to kill ascended shadowlings without being insta-sploded
		user.visible_message("<span class='warning'>[user]'s markings flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy into [boom].</span>")
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/Disintegrate.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()
	else
		to_chat(user, "<span class='warning'>The telekinetic energy is absorbed by the bluespace portal in [boom]'s hand!<span>")
		to_chat(boom, "<span class='userdanger'>You feel a slight recoil from the bag of holding!<span>")

/obj/effect/proc_holder/spell/targeted/shadowling/hypnosis //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "enthrall"

/obj/effect/proc_holder/spell/targeted/shadowling/hypnosis/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(user.incorporeal_move)
		revert_cast()
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return
	if(IS_SHADOW_OR_THRALL(target))
		to_chat(user, "<span class='warning'>You cannot enthrall an ally.<span>")
		revert_cast()
		return
	if(!target.ckey || !target.mind)
		to_chat(user, "<span class='warning'>The target has no mind.</span>")
		revert_cast()
		return
	if(target.stat)
		to_chat(user, "<span class='warning'>The target must be conscious.</span>")
		revert_cast()
		return
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>You can only enthrall humans.</span>")
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing them into a thrall.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
	target.mind.special_role = "thrall"
	target.add_thrall()

/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm //Releases bolts of lightning to everyone nearby
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	range = 6
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "lightning_storm"
	action_icon = 'icons/mob/actions.dmi'
	sound = 'sound/magic/lightningbolt.ogg'

/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm/cast(list/targets,mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	user.visible_message("<span class='warning'><b>A massive ball of lightning appears in [user]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")
	for(var/mob/living/carbon/human/target in view(6))
		if(IS_SHADOW_OR_THRALL(target))
			continue
		to_chat(target, "<span class='userdanger'>You're struck by a bolt of lightning!</span>")
		target.apply_damage(10, BURN)
		playsound(target, 'sound/magic/LightningShock.ogg', 50, 1)
		target.Knockdown(80)
		user.Beam(target,icon_state="red_lightning",time=10)

/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant //Large, all-caps text in shadowling chat
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant/cast(mob/living/carbon/human/user)
	var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	text = "<font size=4><span class='shadowling'><b>\[Ascendant\]<i> [user.real_name]</i>: [text]</b></span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(IS_SHADOW_OR_THRALL(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")

/obj/effect/proc_holder/spell/targeted/shadowling/instant_enthrall //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Subjugate"
	desc = "Instantly enthrall a weakling."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "gore" 

/obj/effect/proc_holder/spell/targeted/void_jaunt/ascendant
	name = "Void Walk"
	desc = "Move invisibly through the void between worlds, shielded from mortal eyes."
	panel = "Ascendant"
	charge_max = 0
	apply_damage = FALSE
