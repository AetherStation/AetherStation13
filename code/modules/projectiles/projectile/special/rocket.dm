/obj/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 2)
	return BULLET_ACT_HIT

/// PM9 HEDP rocket
/obj/projectile/bullet/a84mm
	name ="\improper HEDP rocket"
	desc = "USE A WEEL GUN"
	icon_state= "84mm-hedp"
	damage = 80
	armour_penetration = 100
	dismemberment = 100
	embedding = null
	shrapnel_type = null
	/// Whether we do extra damage when hitting a mech or silicon
	var/anti_armour_damage = 200

/obj/projectile/bullet/a84mm/on_hit(atom/target, blocked = FALSE)
	if(isliving(target) && prob(1))
		var/mob/living/gibbed_dude = target
		if(gibbed_dude.stat < HARD_CRIT)
			gibbed_dude.say("Is that a fucking ro-", forced = "hit by rocket")
	..()

	do_boom(target)
	if(anti_armour_damage && ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)
	return BULLET_ACT_HIT

/// Since some rockets have different booms depending if they hit a living target or not, this is easier than having explosive radius vars
/obj/projectile/bullet/a84mm/proc/do_boom(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flame_range = 4, flash_range = 1, adminlog = FALSE)

/// PM9 standard rocket
/obj/projectile/bullet/a84mm/he
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "missile"
	damage = 50
	anti_armour_damage = 0

/obj/projectile/bullet/a84mm/he/do_boom(atom/target, blocked=0)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4)

/// PM9 weak rocket
/obj/projectile/bullet/a84mm/weak
	name ="low-yield HE missile"
	desc = "Boom, but less so."
	damage = 30
	anti_armour_damage = 0

/obj/projectile/bullet/a84mm/weak/do_boom(atom/target, blocked=0)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4)

/// SRM-8 mech standard rocket
/obj/projectile/bullet/a84mm/kinetic
	name ="\improper kinetic missile"
	desc = "ACME is painted on the side for some reason..."
	icon_state = "missile"
	damage = 75
	dismemberment = 0
	armour_penetration = 20
	anti_armour_damage = 0

/obj/projectile/bullet/a84mm/kinetic/on_hit(atom/target, blocked = 0)
	var/datum/effect_system/smoke_spread/quick/smoke = new
	if(iscarbon(target))
		smoke.set_up(0, src)
		smoke.start()
		var/mob/living/carbon/M = target
		M.Paralyze(20)
		M.Knockdown(120)
		M.emote("scream") //WEEEE!!
		M.visible_message("<span class='warning'>[M] flies off in an arc after being hit by the [src]!</span>")
		var/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, starting)))
		M.throw_at(throw_target, rand(8,12), 14)
		explosion(target, heavy_impact_range = 0, light_impact_range = 0, flame_range = 0, flash_range = 2, adminlog = FALSE)
	else
		smoke.set_up(1, src)
		smoke.start()
		explosion(target, heavy_impact_range = 0, light_impact_range = 2, flame_range = 0, flash_range = 2)
