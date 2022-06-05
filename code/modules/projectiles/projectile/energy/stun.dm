/obj/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = FALSE
	damage = 5
	damage_type = BURN
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/projectile/energy/electrode/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		if(C.dna && C.dna.check_mutation(HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		else if (!HAS_TRAIT(C, TRAIT_STUNIMMUNE))
			stun_effect(C)
			addtimer(CALLBACK(C, /mob/living/carbon.proc/do_jitter_animation, jitter), 5)

/obj/projectile/energy/electrode/proc/stun_effect(mob/living/carbon/C)
	if(C.getStaminaLoss() > 50)
		to_chat(C,span_alertwarning("Your hands seize in shock!"))
		C.dropItemToGround(C.get_active_held_item())
		C.dropItemToGround(C.get_inactive_held_item())
	C.apply_status_effect(/datum/status_effect/tased)

/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	..()

/obj/projectile/energy/electrode/stun
	name = "electrode"
	paralyze = 100
	damage = 0
	damage_type = STAMINA

/obj/projectile/energy/electrode/stun/stun_effect(mob/living/carbon/C)
	// nuthin
