
/datum/surgery/amputation
	name = "Amputation"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/sever_limb)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
	requires_bodypart_type = 0


/datum/surgery_step/sever_limb
	name = "sever limb"
	implements = list(
		/obj/item/shears = 300,
		TOOL_SCALPEL = 100,
		TOOL_SAW = 100,
		/obj/item/melee/arm_blade = 80,
		/obj/item/fireaxe = 50,
		/obj/item/hatchet = 40,
		/obj/item/kitchen/knife/butcher = 25)
	time = 64
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to sever [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to sever [target]'s [parse_zone(target_zone)]!"),
		span_notice("[user] begins to sever [target]'s [parse_zone(target_zone)]!"))

/datum/surgery_step/sever_limb/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, span_notice("You sever [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] severs [target]'s [parse_zone(target_zone)]!"),
		span_notice("[user] severs [target]'s [parse_zone(target_zone)]!"))
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()
	return ..()

/datum/surgery/amputation/mechanic
	name = "Detach mechanical limb"
	self_operable = TRUE
	requires_bodypart_type = BODYPART_ROBOTIC
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	target_mobtypes = list(/mob/living/carbon/human)
	lying_required = FALSE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/sever_limb/mechanic
		)

/datum/surgery/amputation/mechanic/can_start(mob/user, mob/living/carbon/target)
	return ispreternis(target)

/datum/surgery_step/sever_limb/mechanic
	name = "uninstall limb"
	preop_sound = 'sound/items/ratchet.ogg'
	accept_hand = TRUE

/datum/surgery_step/sever_limb/mechanic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to detach [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to detach [target]'s [parse_zone(target_zone)]!",
		"[user] begins to detach [target]'s [parse_zone(target_zone)]!")

/datum/surgery_step/sever_limb/mechanic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	display_results(user, target, span_notice("You detached [L]'s [parse_zone(target_zone)]."),
		"[user] detached [L]'s [parse_zone(target_zone)]!",
		"[user] detached [L]'s [parse_zone(target_zone)]!")
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()

	return 1
