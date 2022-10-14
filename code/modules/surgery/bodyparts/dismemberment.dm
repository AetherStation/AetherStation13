
/obj/item/bodypart/proc/can_dismember(obj/item/item)
	if(dismemberable)
		return TRUE

//Dismember a limb
/obj/item/bodypart/proc/dismember(dam_type = BRUTE, silent=TRUE)
	if(!owner || !dismemberable)
		return FALSE
	var/mob/living/carbon/limb_owner = owner
	if(limb_owner.status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(limb_owner, TRAIT_NODISMEMBER))
		return FALSE

	var/obj/item/bodypart/affecting = limb_owner.get_bodypart(BODY_ZONE_CHEST)
	affecting.receive_damage(clamp(brute_dam/2 * affecting.body_damage_coeff, 15, 50), clamp(burn_dam/2 * affecting.body_damage_coeff, 0, 50)) //Damage the chest based on limb's existing damage
	if(!silent)
		limb_owner.visible_message(span_danger("<B>[limb_owner]'s [name] is violently dismembered!</B>"))
	INVOKE_ASYNC(limb_owner, /mob.proc/emote, "scream")
	playsound(get_turf(limb_owner), 'sound/effects/dismember.ogg', 80, TRUE)
	SEND_SIGNAL(limb_owner, COMSIG_ADD_MOOD_EVENT, "dismembered", /datum/mood_event/dismembered)
	drop_limb()

	limb_owner.update_equipment_speed_mods() // Update in case speed affecting item unequipped by dismemberment
	var/turf/owner_location = limb_owner.loc
	if(istype(owner_location))
		limb_owner.add_splatter_floor(owner_location)

	if(QDELETED(src)) //Could have dropped into lava/explosion/chasm/whatever
		return TRUE
	if(dam_type == BURN)
		burn()
		return TRUE
	add_mob_blood(limb_owner)
	limb_owner.bleed(rand(20, 40))
	var/direction = pick(GLOB.cardinals)
	var/t_range = rand(2,max(throw_range/2, 2))
	var/turf/target_turf = get_turf(src)
	for(var/i in 1 to t_range-1)
		var/turf/new_turf = get_step(target_turf, direction)
		if(!new_turf)
			break
		target_turf = new_turf
		if(new_turf.density)
			break
	throw_at(target_turf, throw_range, throw_speed)
	return TRUE


/obj/item/bodypart/chest/dismember()
	if(!owner)
		return FALSE
	var/mob/living/carbon/chest_owner = owner
	if(!dismemberable)
		return FALSE
	if(HAS_TRAIT(chest_owner, TRAIT_NODISMEMBER))
		return FALSE
	. = list()
	if(isturf(chest_owner.loc))
		chest_owner.add_splatter_floor(chest_owner.loc)
	playsound(get_turf(chest_owner), 'sound/misc/splort.ogg', 80, TRUE)
	for(var/obj/item/organ/organ as anything in chest_owner.internal_organs)
		var/org_zone = check_zone(organ.zone)
		if(org_zone != BODY_ZONE_CHEST)
			continue
		organ.Remove(chest_owner)
		organ.forceMove(chest_owner.loc)
		. += organ
	if(cavity_item)
		cavity_item.forceMove(chest_owner.loc)
		. += cavity_item
		cavity_item = null



///limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
/obj/item/bodypart/proc/drop_limb(special, dismembered)
	if(!owner)
		return
	var/atom/drop_loc = owner.drop_location()

	SEND_SIGNAL(owner, COMSIG_CARBON_REMOVE_LIMB, src, dismembered)
	update_limb(1)
	owner.remove_bodypart(src)

	if(held_index)
		if(owner.hand_bodyparts[held_index] == src)
			// We only want to do this if the limb being removed is the active hand part.
			// This catches situations where limbs are "hot-swapped" such as augmentations and roundstart prosthetics.
			owner.dropItemToGround(owner.get_item_for_held_index(held_index), 1)
			owner.hand_bodyparts[held_index] = null

	var/mob/living/carbon/phantom_owner = owner // so we can still refer to the guy who lost their limb after said limb forgets 'em
	owner = null

	for(var/datum/surgery/surgery as anything in phantom_owner.surgeries) //if we had an ongoing surgery on that limb, we stop it.
		if(surgery.operated_bodypart == src)
			phantom_owner.surgeries -= surgery
			qdel(surgery)
			break

	for(var/obj/item/embedded in embedded_objects)
		embedded_objects -= embedded
		embedded.forceMove(src)
	if(!phantom_owner.has_embedded_objects())
		phantom_owner.clear_alert("embeddedobject")
		SEND_SIGNAL(phantom_owner, COMSIG_CLEAR_MOOD_EVENT, "embedded")

	if(!special)
		if(phantom_owner.dna)
			for(var/datum/mutation/human/mutation as anything in phantom_owner.dna.mutations) //some mutations require having specific limbs to be kept.
				if(mutation.limb_req && mutation.limb_req == body_zone)
					to_chat(phantom_owner, span_warning("You feel your [mutation] deactivating from the loss of your [body_zone]!"))
					phantom_owner.dna.force_lose(mutation)

		for(var/obj/item/organ/organ as anything in phantom_owner.internal_organs) //internal organs inside the dismembered limb are dropped.
			var/org_zone = check_zone(organ.zone)
			if(org_zone != body_zone)
				continue
			organ.transfer_to_limb(src, phantom_owner)

	update_icon_dropped()
	phantom_owner.update_health_hud() //update the healthdoll
	phantom_owner.update_body()
	phantom_owner.update_hair()

	if(!drop_loc) // drop_loc = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
		qdel(src)
		return

	if(is_pseudopart)
		drop_organs(phantom_owner) //Psuedoparts shouldn't have organs, but just in case
		qdel(src)
		return

	forceMove(drop_loc)

//when a limb is dropped, the internal organs are removed from the mob and put into the limb
/obj/item/organ/proc/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	Remove(bodypart_owner)
	forceMove(bodypart)

/obj/item/organ/brain/transfer_to_limb(obj/item/bodypart/head/head, mob/living/carbon/human/head_owner)
	Remove(head_owner) //Changeling brain concerns are now handled in Remove
	forceMove(head)
	head.brain = src
	if(brainmob)
		head.brainmob = brainmob
		brainmob = null
		head.brainmob.forceMove(head)
		head.brainmob.set_stat(DEAD)

/obj/item/organ/eyes/transfer_to_limb(obj/item/bodypart/head/head, mob/living/carbon/human/head_owner)
	head.eyes = src
	..()

/obj/item/organ/ears/transfer_to_limb(obj/item/bodypart/head/head, mob/living/carbon/human/head_owner)
	head.ears = src
	..()

/obj/item/organ/tongue/transfer_to_limb(obj/item/bodypart/head/head, mob/living/carbon/human/head_owner)
	head.tongue = src
	..()

/obj/item/bodypart/chest/drop_limb(special)
	if(special)
		..()

/obj/item/bodypart/r_arm/drop_limb(special)
	var/mob/living/carbon/arm_owner = owner
	..()
	if(arm_owner && !special)
		if(arm_owner.handcuffed)
			arm_owner.handcuffed.forceMove(drop_location())
			arm_owner.handcuffed.dropped(arm_owner)
			arm_owner.set_handcuffed(null)
			arm_owner.update_handcuffed()
		if(arm_owner.hud_used)
			var/atom/movable/screen/inventory/hand/R_hand = arm_owner.hud_used.hand_slots["[held_index]"]
			if(R_hand)
				R_hand.update_appearance()
		if(arm_owner.gloves)
			arm_owner.dropItemToGround(arm_owner.gloves, TRUE)
		arm_owner.update_inv_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/l_arm/drop_limb(special)
	var/mob/living/carbon/arm_owner = owner
	..()
	if(arm_owner && !special)
		if(arm_owner.handcuffed)
			arm_owner.handcuffed.forceMove(drop_location())
			arm_owner.handcuffed.dropped(arm_owner)
			arm_owner.set_handcuffed(null)
			arm_owner.update_handcuffed()
		if(arm_owner.hud_used)
			var/atom/movable/screen/inventory/hand/L_hand = arm_owner.hud_used.hand_slots["[held_index]"]
			if(L_hand)
				L_hand.update_appearance()
		if(arm_owner.gloves)
			arm_owner.dropItemToGround(arm_owner.gloves, TRUE)
		arm_owner.update_inv_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/r_leg/drop_limb(special)
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location()) //At this point bodypart is still in nullspace
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_inv_legcuffed()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	..()

/obj/item/bodypart/l_leg/drop_limb(special) //copypasta
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location())
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_inv_legcuffed()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	..()

/obj/item/bodypart/head/drop_limb(special)
	if(!special)
		//Drop all worn head items
		for(var/obj/item/head_item as anything in list(owner.glasses, owner.ears, owner.wear_mask, owner.head))
			owner.dropItemToGround(head_item, force = TRUE)

	qdel(owner.GetComponent(/datum/component/creamed)) //clean creampie overlay flushed emoji

	//Handle dental implants
	for(var/datum/action/item_action/hands_free/activate_pill/pill_action in owner.actions)
		pill_action.Remove(owner)
		var/obj/pill = pill_action.target
		if(pill)
			pill.forceMove(src)

	//Make sure de-zombification happens before organ removal instead of during it
	var/obj/item/organ/zombie_infection/ooze = owner.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(istype(ooze))
		ooze.transfer_to_limb(src, owner)

	name = "[owner.real_name]'s head"
	..()

//Attach a limb to a human and drop any existing limb of that type.
/obj/item/bodypart/proc/replace_limb(mob/living/carbon/limb_owner, special)
	if(!istype(limb_owner))
		return
	var/obj/item/bodypart/limb = limb_owner.get_bodypart(body_zone) //needs to happen before attach because multiple limbs in same zone breaks helpers
	if(!attach_limb(limb_owner, special))//we can attach this limb and drop the old after because of our robust bodyparts system. you know, just for a sec.
		return
	if(limb)
		limb.drop_limb(1)

/obj/item/bodypart/head/replace_limb(mob/living/carbon/head_owner, special)
	if(!istype(head_owner))
		return
	var/obj/item/bodypart/head/head = head_owner.get_bodypart(body_zone)
	if(!attach_limb(head_owner, special))
		return
	if(head)
		head.drop_limb(1)

/obj/item/bodypart/proc/attach_limb(mob/living/carbon/new_limb_owner, special)
	if(SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH)
		return FALSE
	. = TRUE
	moveToNullspace()
	set_owner(new_limb_owner)
	new_limb_owner.add_bodypart(src)
	if(held_index)
		if(held_index > new_limb_owner.hand_bodyparts.len)
			new_limb_owner.hand_bodyparts.len = held_index
		new_limb_owner.hand_bodyparts[held_index] = src
		if(new_limb_owner.dna.species.mutanthands && !is_pseudopart)
			new_limb_owner.put_in_hand(new new_limb_owner.dna.species.mutanthands(), held_index)
		if(new_limb_owner.hud_used)
			var/atom/movable/screen/inventory/hand/hand = new_limb_owner.hud_used.hand_slots["[held_index]"]
			if(hand)
				hand.update_appearance()
		new_limb_owner.update_inv_gloves()

	if(special) //non conventional limb attachment
		for(var/datum/surgery/attach_surgery as anything in new_limb_owner.surgeries) //if we had an ongoing surgery to attach a new limb, we stop it.
			var/surgery_zone = check_zone(attach_surgery.location)
			if(surgery_zone == body_zone)
				new_limb_owner.surgeries -= attach_surgery
				qdel(attach_surgery)
				break

	for(var/obj/item/organ/limb_organ in contents)
		limb_organ.Insert(new_limb_owner)

	update_bodypart_damage_state()
	if(can_be_disabled)
		update_disabled()

	new_limb_owner.updatehealth()
	new_limb_owner.update_body()
	new_limb_owner.update_hair()
	new_limb_owner.update_damage_overlays()


/obj/item/bodypart/head/attach_limb(mob/living/carbon/new_head_owner, special = FALSE, abort = FALSE)
	// These are stored before calling super. This is so that if the head is from a different body, it persists its appearance.
	var/hair_color = src.hair_color
	var/hairstyle = src.hairstyle
	var/facial_hair_color = src.facial_hair_color
	var/facial_hairstyle = src.facial_hairstyle
	var/lip_style = src.lip_style
	var/lip_color = src.lip_color
	var/real_name = src.real_name

	. = ..()
	if(!.)
		return .
	//Transfer some head appearance vars over
	if(brain)
		if(brainmob)
			brainmob.container = null //Reset brainmob head var.
			brainmob.forceMove(brain) //Throw mob into brain.
			brain.brainmob = brainmob //Set the brain to use the brainmob
			brainmob = null //Set head brainmob var to null
		brain.Insert(new_head_owner) //Now insert the brain proper
		brain = null //No more brain in the head

	if(tongue)
		tongue = null
	if(ears)
		ears = null
	if(eyes)
		eyes = null

	if(ishuman(new_head_owner))
		var/mob/living/carbon/human/human_head_owner = new_head_owner
		human_head_owner.hair_color = hair_color
		human_head_owner.hairstyle = hairstyle
		human_head_owner.facial_hair_color = facial_hair_color
		human_head_owner.facial_hairstyle = facial_hairstyle
		human_head_owner.update_lips(lip_style, lip_color, stored_lipstick_trait)
	if(real_name)
		new_head_owner.real_name = real_name
	real_name = ""
	name = initial(name)

	//Handle dental implants
	for(var/obj/item/reagent_containers/pill/pill in src)
		for(var/datum/action/item_action/hands_free/activate_pill/pill_action in pill.actions)
			pill.forceMove(new_head_owner)
			pill_action.Grant(new_head_owner)
			break

	new_head_owner.updatehealth()
	new_head_owner.update_body()
	new_head_owner.update_hair()
	new_head_owner.update_damage_overlays()


//Regenerates all limbs. Returns amount of limbs regenerated
/mob/living/proc/regenerate_limbs(noheal = FALSE, list/excluded_zones = list())
	SEND_SIGNAL(src, COMSIG_LIVING_REGENERATE_LIMBS, noheal, excluded_zones)

/mob/living/carbon/regenerate_limbs(noheal = FALSE, list/excluded_zones = list())
	. = ..()
	var/list/zone_list = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	if(length(excluded_zones))
		zone_list -= excluded_zones
	for(var/limb_zone in zone_list)
		. += regenerate_limb(limb_zone, noheal)

/mob/living/proc/regenerate_limb(limb_zone, noheal)
	return

/mob/living/carbon/regenerate_limb(limb_zone, noheal)
	var/obj/item/bodypart/limb
	if(get_bodypart(limb_zone))
		return FALSE
	limb = newBodyPart(limb_zone, 0, 0)
	if(limb)
		if(!noheal)
			limb.set_brute_dam(0)
			limb.set_burn_dam(0)
			limb.brutestate = 0
			limb.burnstate = 0

		if(!limb.attach_limb(src, 1))
			qdel(limb)
			return FALSE
		return TRUE
