
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	grind_results = list(/datum/reagent/bone_dust = 10, /datum/reagent/liquidgibs = 5) // robotic bodyparts and chests/heads cannot be ground
	var/mob/living/carbon/owner
	var/datum/weakref/original_owner
	var/status = BODYPART_ORGANIC
	var/needs_processing = FALSE

	/// BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/body_zone
	var/aux_zone // used for hands
	var/aux_layer
	/// bitflag used to check which clothes cover this bodypart
	var/body_part
	/// Used for alternate legs, useless elsewhere
	var/use_digitigrade = NOT_DIGITIGRADE
	var/list/embedded_objects = list()
	/// are we a hand? if so, which one!
	var/held_index = 0
	/// For limbs that don't really exist, eg chainsaws
	var/is_pseudopart = FALSE

	///If disabled, limb is as good as missing.
	var/bodypart_disabled = FALSE
	///Multiplied by max_damage it returns the threshold which defines a limb being disabled or not. From 0 to 1. 0 means no disable thru damage
	var/disable_threshold = 0
	///Controls whether bodypart_disabled makes sense or not for this limb.
	var/can_be_disabled = FALSE
	///Multiplier of the limb's damage that gets applied to the mob
	var/body_damage_coeff = 1
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0
	///Gradually increases while burning when at full damage, destroys the limb when at 100
	var/cremation_progress = 0
	///Subtracted to brute damage taken
	var/brute_reduction = 0
	///Subtracted to burn damage taken
	var/burn_reduction = 0
	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	///for nonhuman bodypart (e.g. monkey)
	var/animal_origin
	///whether it can be dismembered with a weapon.
	var/dismemberable = 1

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	///the type of damage overlay (if any) to use when this bodypart is bruised/burned.
	var/dmg_overlay_type

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed
	var/bleeding_supressed = FALSE
	/// How much bleedstacks we have on this bodypart
	var/bleedstacks
	/// If we have a gauze wrapping currently applied (not including splints)
	var/obj/item/stack/current_gauze
	/// If something is currently grasping this bodypart and trying to staunch bleeding (see [/obj/item/self_grasp])
	var/obj/item/self_grasp/grasped_by

	///A list of all the external organs we've got stored to draw horns, wings and stuff with (special because we are actually in the limbs unlike normal organs :/ )
	var/list/obj/item/organ/external/external_organs = list()


/obj/item/bodypart/Initialize(mapload)
	. = ..()
	if(can_be_disabled)
		RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
	if(status != BODYPART_ORGANIC)
		grind_results = null

/obj/item/bodypart/Destroy()
	if(owner)
		owner.remove_bodypart(src)
		set_owner(null)
	return ..()


/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam > DAMAGE_PRECISION)
		. += span_warning("This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.")
	if(burn_dam > DAMAGE_PRECISION)
		. += span_warning("This limb has [burn_dam > 30 ? "severe" : "minor"] burns.")

/obj/item/bodypart/blob_act()
	take_damage(max_damage)


/obj/item/bodypart/attack(mob/living/carbon/victim, mob/user)
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(HAS_TRAIT(victim, TRAIT_LIMBATTACHMENT))
			if(!human_victim.get_bodypart(body_zone) && !animal_origin)
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				if(!attach_limb(victim))
					to_chat(user, span_warning("[human_victim]'s body rejects [src]!"))
					forceMove(human_victim.loc)
				if(human_victim == user)
					human_victim.visible_message(span_warning("[human_victim] jams [src] into [human_victim.p_their()] empty socket!"),\
					span_notice("You force [src] into your empty socket, and it locks into place!"))
				else
					human_victim.visible_message(span_warning("[user] jams [src] into [human_victim]'s empty socket!"),\
					span_notice("[user] forces [src] into your empty socket, and it locks into place!"))
				return
	..()

/obj/item/bodypart/attackby(obj/item/weapon, mob/user, params)
	if(weapon.get_sharpness())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, span_warning("There is nothing left inside [src]!"))
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message(span_warning("[user] begins to cut open [src]."),\
			span_notice("You begin to cut open [src]..."))
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(status != BODYPART_ROBOTIC)
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/bodypart_turf = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(bodypart_turf, 'sound/misc/splort.ogg', 50, TRUE, -1)
	seep_gauze(9999) // destroy any existing gauze if any exists
	for(var/obj/item/organ/bodypart_organ in get_organs())
		bodypart_organ.transfer_to_limb(src, owner)
	for(var/obj/item/item_in_bodypart in src)
		item_in_bodypart.forceMove(bodypart_turf)

///since organs aren't actually stored in the bodypart themselves while attached to a person, we have to query the owner for what we should have
/obj/item/bodypart/proc/get_organs()
	if(!owner)
		return FALSE

	var/list/bodypart_organs
	for(var/obj/item/organ/organ_check as anything in owner.internal_organs) //internal organs inside the dismembered limb are dropped.
		if(check_zone(organ_check.zone) == body_zone)
			LAZYADD(bodypart_organs, organ_check) // this way if we don't have any, it'll just return null

	return bodypart_organs


//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(delta_time, times_fired, stam_regen)
	if(stamina_dam > DAMAGE_PRECISION && stam_regen) //DO NOT update health here, it'll be done in the carbon's life.
		heal_damage(0, 0, INFINITY, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, sharpness = NONE) // maybe separate BRUTE_SHARP and BRUTE_OTHER eventually somehow hmm
	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE //godmode

	if(required_status && (status != required_status))
		return FALSE

	var/dmg_multi = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_multi, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_multi, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_multi, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)

	if(!brute && !burn && !stamina)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	//back to our regularly scheduled program, we now actually apply damage if there's room below limb damage cap
	var/can_inflict = max_damage - get_damage()
	var/total_damage = brute + burn
	if(total_damage > can_inflict && total_damage > 0) // TODO: the second part of this check should be removed once disabling is all done
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	if(can_inflict <= 0)
		return FALSE
	if(brute)
		if (sharpness) // sharper objects cause more bleeding.
			bleedstacks += sharpness * brute * 0.25 // lets not bleed them dry instantly.
		set_brute_dam(brute_dam + brute)
	if(burn)
		set_burn_dam(burn_dam + burn)

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	if(stamina)
		set_stamina_dam(stamina_dam + round(clamp(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
			if(stamina > DAMAGE_PRECISION)
				owner.update_stamina()
				owner.stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
				. = TRUE
	return update_bodypart_damage_state() || .

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && status != required_status) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	if(brute)
		set_brute_dam(round(max(brute_dam - brute, 0), DAMAGE_PRECISION))
	if(burn)
		set_burn_dam(round(max(burn_dam - burn, 0), DAMAGE_PRECISION))
	if(stamina)
		set_stamina_dam(round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
	cremation_progress = min(0, cremation_progress - ((brute_dam + burn_dam)*(100/max_damage)))
	return update_bodypart_damage_state()


///Proc to hook behavior associated to the change of the brute_dam variable's value.
/obj/item/bodypart/proc/set_brute_dam(new_value)
	if(brute_dam == new_value)
		return
	. = brute_dam
	brute_dam = new_value


///Proc to hook behavior associated to the change of the burn_dam variable's value.
/obj/item/bodypart/proc/set_burn_dam(new_value)
	if(burn_dam == new_value)
		return
	. = burn_dam
	burn_dam = new_value


///Proc to hook behavior associated to the change of the stamina_dam variable's value.
/obj/item/bodypart/proc/set_stamina_dam(new_value)
	if(stamina_dam == new_value)
		return
	. = stamina_dam
	stamina_dam = new_value
	if(stamina_dam > DAMAGE_PRECISION)
		needs_processing = TRUE
	else
		needs_processing = FALSE


//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total


//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	if(!owner)
		return

	if(!can_be_disabled)
		set_disabled(FALSE)
		CRASH("update_disabled called with can_be_disabled false")

	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		set_disabled(TRUE)
		return

	var/total_damage = max(brute_dam + burn_dam, stamina_dam)

	// this block of checks is for limbs that can be disabled, but not through pure damage (AKA limbs that suffer wounds, human/monkey parts and such)
	if(!disable_threshold)
		if(total_damage < max_damage)
			last_maxed = FALSE
		else
			if(!last_maxed && owner.stat < UNCONSCIOUS)
				INVOKE_ASYNC(owner, /mob.proc/emote, "scream")
			last_maxed = TRUE
		set_disabled(FALSE) // we only care about the paralysis trait
		return

	// we're now dealing solely with limbs that can be disabled through pure damage, AKA robot parts
	if(total_damage >= max_damage * disable_threshold)
		if(!last_maxed)
			if(owner.stat < UNCONSCIOUS)
				INVOKE_ASYNC(owner, /mob.proc/emote, "scream")
			last_maxed = TRUE
		set_disabled(TRUE)
		return

	if(bodypart_disabled && total_damage <= max_damage * 0.5) // reenable the limb at 50% health
		last_maxed = FALSE
		set_disabled(FALSE)


///Proc to change the value of the `disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(bodypart_disabled == new_disabled)
		return
	. = bodypart_disabled
	bodypart_disabled = new_disabled

	if(!owner)
		return
	owner.update_health_hud() //update the healthdoll
	owner.update_body()


///Proc to change the value of the `owner` variable and react to the event of its change.
/obj/item/bodypart/proc/set_owner(new_owner)
	if(owner == new_owner)
		return FALSE //`null` is a valid option, so we need to use a num var to make it clear no change was made.
	. = owner
	owner = new_owner
	var/needs_update_disabled = FALSE //Only really relevant if there's an owner
	if(.)
		var/mob/living/carbon/old_owner = .
		if(initial(can_be_disabled))
			if(HAS_TRAIT(old_owner, TRAIT_NOLIMBDISABLE))
				if(!owner || !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
					set_can_be_disabled(initial(can_be_disabled))
					needs_update_disabled = TRUE
			UnregisterSignal(old_owner, list(
				SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE),
				SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE),
				))
	if(owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				set_can_be_disabled(FALSE)
				needs_update_disabled = FALSE
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_loss)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_gain)
		if(needs_update_disabled)
			update_disabled()


///Proc to change the value of the `can_be_disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_can_be_disabled(new_can_be_disabled)
	if(can_be_disabled == new_can_be_disabled)
		return
	. = can_be_disabled
	can_be_disabled = new_can_be_disabled
	if(can_be_disabled)
		if(owner)
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				CRASH("set_can_be_disabled to TRUE with for limb whose owner has TRAIT_NOLIMBDISABLE")
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
		update_disabled()
	else if(.)
		if(owner)
			UnregisterSignal(owner, list(
				SIGNAL_ADDTRAIT(TRAIT_PARALYSIS),
				SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS),
				))
		set_disabled(FALSE)


///Called when TRAIT_PARALYSIS is added to the limb.
/obj/item/bodypart/proc/on_paralysis_trait_gain(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(can_be_disabled)
		set_disabled(TRUE)


///Called when TRAIT_PARALYSIS is removed from the limb.
/obj/item/bodypart/proc/on_paralysis_trait_loss(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(can_be_disabled)
		update_disabled()


///Called when TRAIT_NOLIMBDISABLE is added to the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	set_can_be_disabled(FALSE)


///Called when TRAIT_NOLIMBDISABLE is removed from the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	set_can_be_disabled(initial(can_be_disabled))

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute = round( (brute_dam/max_damage)*3, 1 )
	var/tburn = round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//Change organ status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default)
	status = new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(change_icon_to_default)
		if(status == BODYPART_ORGANIC)
			icon = DEFAULT_BODYPART_ICON_ORGANIC
		else if(status == BODYPART_ROBOTIC)
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

/obj/item/bodypart/proc/is_organic_limb()
	return (status == BODYPART_ORGANIC)

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/limb_owner
	if(source)
		limb_owner = source
		if(!original_owner)
			original_owner = WEAKREF(source)
	else
		limb_owner = owner
		if(original_owner && !IS_WEAKREF_OF(owner, original_owner)) //Foreign limb
			no_update = TRUE
		else
			no_update = FALSE

	if(HAS_TRAIT(limb_owner, TRAIT_HUSK) && is_organic_limb())
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = TRUE

	if(HAS_TRAIT(src, TRAIT_PLASMABURNT) && is_organic_limb())
		species_id = SPECIES_PLASMAMAN
		dmg_overlay_type = ""
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = TRUE

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/human_owner = limb_owner
		should_draw_greyscale = FALSE

		var/datum/species/owner_species = human_owner.dna.species
		species_id = owner_species.limbs_id
		species_flags_list = human_owner.dna.species.species_traits

		if(owner_species.use_skintones)
			skin_tone = human_owner.skin_tone
			should_draw_greyscale = TRUE
		else
			skin_tone = ""

		body_gender = human_owner.body_type
		should_draw_gender = owner_species.sexes

		if((MUTCOLORS in owner_species.species_traits) || (DYNCOLORS in owner_species.species_traits))
			if(owner_species.fixed_mut_color)
				species_color = owner_species.fixed_mut_color
			else
				species_color = human_owner.dna.features["mcolor"]
			should_draw_greyscale = TRUE
		else
			species_color = ""

		if(!dropping_limb && human_owner.dna.check_mutation(HULK))
			mutation_color = "00aa00"
		else
			mutation_color = ""

		dmg_overlay_type = owner_species.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(status == BODYPART_ROBOTIC)
		dmg_overlay_type = "robotic"

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/img in standing)
		img.pixel_x = px_x
		img.pixel_y = px_y
	add_overlay(standing)

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"

		if(blocks_emissive)
			var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
			limb_em_block.dir = image_dir
			limb_em_block.color = GLOB.em_block_color
			limb.overlays += limb_em_block
		return

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if((body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	if(!is_organic_limb())
		limb.icon = icon
		limb.icon_state = "[body_zone]" //Inorganic limbs are agender

		if(blocks_emissive)
			var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
			limb_em_block.dir = image_dir
			limb_em_block.color = GLOB.em_block_color
			limb.overlays += limb_em_block

		if(aux_zone)
			aux = image(limb.icon, "[aux_zone]", -aux_layer, image_dir)
			. += aux

			if(blocks_emissive)
				var/mutable_appearance/aux_em_block = mutable_appearance(aux.icon, aux.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
				aux_em_block.dir = image_dir
				aux_em_block.color = GLOB.em_block_color
				aux.overlays += aux_em_block

		return

	if(should_draw_greyscale)
		limb.icon = 'icons/mob/human_parts_greyscale.dmi'
		if(should_draw_gender)
			limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
		else if(use_digitigrade)
			limb.icon_state = "digitigrade_[use_digitigrade]_[body_zone]"
		else
			limb.icon_state = "[species_id]_[body_zone]"
	else
		limb.icon = 'icons/mob/human_parts.dmi'
		if(should_draw_gender)
			limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[species_id]_[body_zone]"

	if(aux_zone)
		aux = image(limb.icon, "[species_id]_[aux_zone]", -aux_layer, image_dir)
		. += aux

	var/draw_color
	if(should_draw_greyscale)
		draw_color = mutation_color || species_color || (skin_tone && skintone2hex(skin_tone))
		if(draw_color)
			limb.color = "#[draw_color]"
			if(aux_zone)
				aux.color = "#[draw_color]"

	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
		limb_em_block.dir = image_dir
		limb_em_block.color = GLOB.em_block_color
		limb.overlays += limb_em_block

		if(aux_zone)
			var/mutable_appearance/aux_em_block = mutable_appearance(aux.icon, aux.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
			aux_em_block.dir = image_dir
			aux_em_block.color = GLOB.em_block_color
			aux.overlays += aux_em_block

	//Draw external organs like horns and frills
	for(var/obj/item/organ/external/external_organ in external_organs)
		if(!dropped && !external_organ.can_draw_on_bodypart(owner))
			continue
		//Some externals have multiple layers for background, foreground and between
		for(var/external_layer in external_organ.all_layers)
			if(external_organ.layers & external_layer)
				external_organ.get_overlays(., image_dir, external_organ.bitflag_to_layer(external_layer), icon_gender, "#[draw_color]")

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/proc/get_bleed_rate()
	if(HAS_TRAIT(owner, TRAIT_NOBLEED))
		return

	if(status != BODYPART_ORGANIC) // maybe in the future we can bleed oil from aug parts, but not now
		return

	var/bleed_rate = bleedstacks * 0.1

	//We want an accurate reading of .len
	list_clear_nulls(embedded_objects)
	for(var/obj/item/embeddies in embedded_objects)
		if(!embeddies.isEmbedHarmless())
			bleed_rate += 0.5

	if(owner.body_position == LYING_DOWN)
		bleed_rate *= 0.75

	if(grasped_by)
		bleed_rate *= 0.7

	if(!bleed_rate)
		if (current_gauze)
			owner.visible_message(span_danger("\The [current_gauze] on [owner]'s [name] falls away in rags."), span_warning("\The [current_gauze] on your [name] falls away in rags."), vision_distance=COMBAT_MESSAGE_RANGE)
			QDEL_NULL(current_gauze)
		QDEL_NULL(grasped_by)

	if (current_gauze)
		seep_gauze(bleed_rate)
		return bleed_rate * current_gauze.seepage_percentage

	return bleed_rate

/**
 * apply_gauze() is used to- well, apply gauze to a bodypart
 *
 * Arguments:
 * * gauze- Just the gauze stack we're taking a sheet from to apply here
 */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/gauze)
	if(!istype(gauze) || !gauze.absorption_capacity)
		return
	var/newly_gauzed = FALSE
	if(!current_gauze)
		newly_gauzed = TRUE
	QDEL_NULL(current_gauze)
	current_gauze = new gauze.type(src, 1)
	gauze.use(1)

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood from limbs, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages falls off and we're left with nothing.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	if(current_gauze.absorption_capacity <= 0)
		owner.visible_message(span_danger("\The [current_gauze] on [owner]'s [name] falls away in rags."), span_warning("\The [current_gauze] on your [name] falls away in rags."), vision_distance=COMBAT_MESSAGE_RANGE)
		QDEL_NULL(current_gauze)

///Proc to turn bodypart into another.
/obj/item/bodypart/proc/change_bodypart(obj/item/bodypart/new_type)
	var/mob/living/carbon/our_owner = owner //dropping nulls the limb
	drop_limb(TRUE)
	var/obj/item/bodypart/new_part = new new_type()
	new_part.attach_limb(our_owner, TRUE)
	qdel(src)
