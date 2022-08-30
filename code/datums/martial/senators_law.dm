#define PUNCH_COMBO "EH"
#define REPULSE_COMBO "GGH"
#define MAGNETIC_COMBO "HDH"
#define DONTFUCS1_COMBO "HDG"
#define DONTFUCS2_COMBO "EEH"
//TODO
//CHANGE BASIC PUNCH COMBO
//ADD THROWMODE PROC
//ADD REPULSE COMBO PROC
//IF NECK + HARM + AIM HEAD = SPINEBROKEN + REGAIN SOME NANITES ?
//TESTING, BALANCING
/datum/martial_art/senators_law
	name = "Senator's Law"
	id = MARTIALART_SENATORSLAW
	help_verb = /mob/living/proc/senator_help
	smashes_tables = TRUE
	var/old_grab_state = null
	var/restraining = FALSE
	var/SENATOR_STAGE2 = FALSE
	var/timer_punish
	display_combos = TRUE

/datum/martial_art/senators_law/reset_streak(mob/living/new_target)
	. = ..()
	restraining = FALSE

/datum/martial_art/senators_law/proc/check_streak(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,DONTFUCS1_COMBO))
		streak = ""
		return dont_fuc1(A,D)
	if(findtext(streak,DONTFUCS2_COMBO))
		streak = ""
		return dont_fuc2(A,D)
	if(findtext(streak,PUNCH_COMBO))
		streak = ""
		return nanite_punch(A,D)
	if(findtext(streak,REPULSE_COMBO))
		streak = ""
		return repulse_attack(A)
	if(findtext(streak,MAGNETIC_COMBO))
		streak = ""
		return magnetic_attack(A,D)
	return FALSE

/datum/martial_art/senators_law/proc/nanite_punch(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punch", "smash", "crack")
	D.visible_message(span_danger("[A] [atk_verb]ed [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"), \
		span_userdanger("You're [atk_verb]ed by [A] with such inhuman strength that it sends you flying backwards!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
	to_chat(A, span_danger("You [atk_verb] [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"))
	var/atom/throw_target = get_edge_target_turf(D, A.dir)
	D.throw_at(throw_target, 3, 14, A)
	playsound(D, 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, 10)
	log_combat(A, D, "nanite punch (senators_law)")
	return TRUE

/datum/martial_art/senators_law/proc/repulse_attack(mob/living/A)
	if(!can_use(A))
		return FALSE
	playsound(get_turf(A),'sound/magic/repulse.ogg', 100, TRUE)
	A.visible_message(span_danger("[A] launches a small shockwave repulsing everything in range!"))
	var/turf/owner_turf = get_turf(A)
	var/list/thrown_items = list()
	for(var/atom/movable/repulsed in range(owner_turf, 7))
		if(repulsed == A || repulsed.anchored || thrown_items[repulsed])
			continue
		var/throwtarget = get_edge_target_turf(owner_turf, get_dir(owner_turf, get_step_away(repulsed, owner_turf)))
		repulsed.safe_throw_at(throwtarget, 2, 1, force = 10)
		thrown_items[repulsed] = repulsed
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, 20)
	log_combat(A, "repulse attack (senators_law)")
	return TRUE

/datum/martial_art/senators_law/proc/magnetic_attack(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/obj/item/I = D.get_active_held_item()
	if (I?.custom_materials && I.custom_materials[GET_MATERIAL_REF(/datum/material/iron)])
		if (D.temporarilyRemoveItemFromInventory(I))
			D.visible_message(span_danger("[A] pulled [D]'s [I] with magnetic powers and grabbed it!"), \
				span_userdanger("[I] slips out of your grasp!"))
			to_chat(A, span_danger("You take [D]'s [I] with your magnetic power!"))
			playsound(get_turf(D), 'sound/effects/empulse.ogg', 50, TRUE, -1)
			A.put_in_hands(I)
	else
		to_chat(A, span_danger("There are no items in [D]'s hands!"))
	D.apply_damage(10, BRUTE)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, 20)
	log_combat(A, D, "Magnetic Attack (senators_law)")
	return TRUE

/datum/martial_art/senators_law/proc/dont_fuc1(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(D.body_position == STANDING_UP)
		D.visible_message(span_danger("[A] slams [D] into the ground!"), \
						span_userdanger("You're slammed into the ground by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You slam [D] into the ground!"))
	if(D.body_position != STANDING_UP)
		D.visible_message(span_danger("[A] stomps [D] paralyzing them!"), \
						span_userdanger("You're stomped by [A]!"), span_hear("You hear a sickening sound of [A]'s boot hitting flesh!"), null, A)
		to_chat(A, span_danger("You stomp on [D] paralyzing them!"))
	playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, TRUE, -1)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -30)
	D.apply_damage(10, BRUTE)
	D.Paralyze(80)
	A.say("Played college ball, y'know?", forced="senator")
	log_combat(A, D, "dont_fuc STAGE 1 (senators_law)")
	timer_punish = addtimer(CALLBACK(src, .proc/punishment, A), 10 SECONDS, TIMER_STOPPABLE) //Point of no return
	SENATOR_STAGE2 = TRUE
	return TRUE

/datum/martial_art/senators_law/proc/punishment(mob/living/A)
	var/message = span_spider("You fucked up!")
	to_chat(A, message)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -100)
	SENATOR_STAGE2 = FALSE

/datum/martial_art/senators_law/proc/dont_fuc2(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!SENATOR_STAGE2)
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("roundhouse kick", "impeach", "put-down")
	D.visible_message(span_danger("[A] [atk_verb]ed [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"), \
		span_userdanger("You're [atk_verb]ed by [A] with such inhuman strength that it sends you flying backwards!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
	to_chat(A, span_danger("You [atk_verb] [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"))
	D.apply_damage(rand(30,60), A.get_attack_type())
	var/atom/throw_target = get_edge_target_turf(D, A.dir)
	D.throw_at(throw_target, 30, 15, A)
	playsound(D, 'sound/weapons/resonator_blast.ogg', 50, TRUE, -1)
	D.emote("scream")
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, 70)
	var/obj/item/card/id/id_card = A.get_idcard(hand_first = TRUE)
	var/assignment = id_card?.assignment
	if(!id_card?.assignment)
		assignment = "ERROR_JOB_NOT_FOUND"
	assignment = uppertext(assignment)
	A.say("DON'T FUCK WITH THIS [assignment]!!!", forced="senator")
	log_combat(A, D, "dont_fuc STAGE 2 (senators_law)")
	deltimer(timer_punish)
	SENATOR_STAGE2 = FALSE
	return TRUE

/datum/martial_art/senators_law/help_act(mob/living/A, mob/living/D)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -10)
	if(A!=D && can_use(A)) // A!=D prevents hugging yourself
		add_to_streak("E",D)
		if(check_streak(A,D))
			return TRUE
	log_combat(A, D, "helped (senators_law)")
	return FALSE

/datum/martial_art/senators_law/grab_act(mob/living/A, mob/living/D)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -10)
	if(A!=D && can_use(A)) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
	log_combat(A, D, "grabbed (senators_law")
	return FALSE

/datum/martial_art/senators_law/harm_act(mob/living/A, mob/living/D)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -10)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	A.do_attack_animation(D)
	var/atk_verb = pick("kick", "hit", "slam")
	D.visible_message(span_danger("[A] [atk_verb]s [D]!"), \
					span_userdanger("[A] [atk_verb]s you!"), null, null, A)
	to_chat(A, span_danger("You [atk_verb] [D]!"))
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.apply_damage(10, BRUTE, affecting, wound_bonus = CANT_WOUND)
	log_combat(A, D, "attacked (senators_law)")
	return TRUE

/datum/martial_art/senators_law/disarm_act(mob/living/A, mob/living/D)
	SEND_SIGNAL(A, COMSIG_NANITE_ADJUST_VOLUME, -10)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "disarmed (senators_law)")
	return FALSE

/mob/living/proc/senator_help()
	set name = "Open README"
	set desc = "You load attached readme file into your mind."
	set category = "Senator's Law"
	to_chat(usr, "<b><i>You load attached readme file into your brain.</i></b>")

	to_chat(usr, "[span_notice("Nanite Wave")]: Help Harm. Hug an opponent and then punch them to send flying.")
	to_chat(usr, "[span_notice("Magnetic Attack")]: Harm Disarm Harm. WIP_COMBO to take a metallic item from their active hand.")
	to_chat(usr, "[span_notice("Repusle Attack")]: Grab Grab Harm. WIP")
	to_chat(usr, "[span_notice("Standing Here")]: Harm Disarm Grab Help Help Harm. Harm, Disarm and Grab your opponent to knock them down to the floor and paralyze, then Help, Help and Harm to send them flying! <b>WARNING</b>: Once combo reaches 50% completion it has to be finished! Unless, the user will suffer significant nanite loss!")

//DEBUG

/obj/item/senators_law
	name = "Armstrong Program"
	desc = "ARMSTRONG NANITES!"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_program"

/obj/item/senators_law/attack_self(mob/living/user)
	if(!istype(user) || !user)
		return
	var/message = span_spider("SENATOR'S LAW DEBUG ACTIVE")
	to_chat(user, message)
	user.AddComponent(/datum/component/nanites, 500)
	SEND_SIGNAL(user, COMSIG_NANITE_ADD_PROGRAM, new /datum/nanite_program/senators_law)
	SEND_SIGNAL(user, COMSIG_NANITE_ADD_PROGRAM, new /datum/nanite_program/nanite_debugging)
	qdel(src)
