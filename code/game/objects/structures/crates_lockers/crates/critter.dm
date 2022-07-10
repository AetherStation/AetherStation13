/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "crittercrate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 600
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	contents_pressure_protection = 0.8
	var/obj/item/tank/internals/emergency_oxygen/tank

/obj/structure/closet/crate/critter/Initialize()
	. = ..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	if(tank)
		tank.forceMove(T)
		tank = null

	return ..()

/obj/structure/closet/crate/critter/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/structure/closet/crate/critter/update_overlays()
	. = ..()
	if(opened)
		. += "crittercrate_door_open"
		return

	. += "crittercrate_door"
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.return_air()
	else
		return loc.return_air()

/obj/structure/closet/crate/critter/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()
	else
		return null

/obj/structure/closet/crate/critter/cryo
	name = "cryostasis animal crate"
	desc = "A crate designed for keeping living samples fresh over long voyages with cryo technology. The closing mechanism seems airtight."
	icon_state = "cryocrate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 600
	delivery_icon = "deliverybox"
	open_sound = 'sound/machines/airlock.ogg'
	close_sound = 'sound/machines/airlock.ogg'
	open_sound_volume = 15
	close_sound_volume = 30
	material_drop = /obj/item/stack/tile/iron
	material_drop_amount = 6
	//can be used as makeshift spacecraft
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	divable = FALSE
	mob_storage_capacity = 1
	horizontal = TRUE
	//cool the mob each process of this much
	var/temperature = -25

/obj/structure/closet/crate/critter/cryo/update_overlays()
	. = ..()
	if(opened)
		. += "cryocrate_door_open"
		return

	. += "cryocrate_door"

/obj/structure/closet/crate/critter/cryo/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/closet/crate/critter/cryo/process(delta_time)
	if(opened || (contents.len == 0))
		STOP_PROCESSING(SSobj, src)
		return
	for(var/mob/living/M in contents)
		if(iscarbon(M))
			var/mob/living/carbon/target = M
			var/thermal_protection = 1 - target.get_insulation_protection(target.bodytemperature + temperature)
			target.adjust_bodytemperature((thermal_protection * temperature) + temperature)

/obj/structure/closet/crate/critter/cryo/close(mob/user, list/modifiers)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/closet/crate/critter/cryo/maint
	name = "abbandoned cryostasis sample crate"
	var/loaded = TRUE
	var/possible_animals = list(/mob/living/simple_animal/cow,
								/mob/living/simple_animal/chicken,
								/mob/living/simple_animal/pig,
								/mob/living/simple_animal/hostile/retaliate/snake,
								/mob/living/simple_animal/mouse) //todo make these have a chance to turn into the thing from that movie

/obj/structure/closet/crate/critter/cryo/maint/open(mob/living/user, force = FALSE)
	. = ..()
	if(loaded)
		var/picked = pick(possible_animals)
		new picked(get_turf(src))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(0, src)
		smoke.start()
		loaded = FALSE
	update_appearance()
