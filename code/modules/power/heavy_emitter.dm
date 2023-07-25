#define EASY_TURN_ON linked_interface ? linked_interface.turn_on() : turn_on()
#define EASY_TURN_OFF linked_interface ? linked_interface.turn_off() : turn_off()
/obj/machinery/power/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "Message an admin if you see this!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	anchored = FALSE
	density = TRUE

/obj/machinery/power/heavy_emitter/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(anchored)
		return FALSE
	I.play_tool_sound(src, 50)
	to_chat(user, "<span class='notice'>You start to rotate [src].</span>")
	if(!do_after(user,10,src))
		return TRUE
	setDir(turn(dir,-90))
	update_icon()
	return TRUE

/obj/machinery/power/heavy_emitter/examine(mob/user)
	. = ..()
	if(anchored)
		. += "It is welded to the floor"

/obj/machinery/power/heavy_emitter/welder_act(mob/living/user, obj/item/I)
	. = ..()
	I.play_tool_sound(src, 50)
	to_chat(user, "<span class='notice'>You start welding [src].</span>")
	if(!do_after(user,5 SECONDS,src))
		return TRUE
	anchored = !anchored
	return TRUE

/obj/machinery/power/heavy_emitter/proc/check_part_connectivity()
	return TRUE

/obj/machinery/power/heavy_emitter/proc/turn_on()
	return

/obj/machinery/power/heavy_emitter/proc/turn_off()
	return

/obj/machinery/power/heavy_emitter/centre
	name = "Heavy Emitter Core"
	desc = "A dangerously unstable, military grade capacitor that eats power like it's candy, before releasing an incredibly potent burst of energy that can annihilate anything."
	idle_power_usage = 0
	active_power_usage = 2000
	///bool to check if the machine is fully constructed
	var/is_fully_constructed = FALSE
	///Current heat level
	var/heat = T0C
	///Max heat level
	var/max_heat = 1500 + T0C
	///List of adjacent vents
	var/list/vents = list()
	///Linked interface
	var/obj/machinery/power/heavy_emitter/interface/linked_interface
	///Linked cannon
	var/obj/machinery/power/heavy_emitter/cannon/linked_cannon
	///Is this currently firing?
	var/firing = FALSE
	///Cooldown
	var/timer = 0
	///Cooldown threshold
	var/max_timer = 10

/obj/machinery/power/heavy_emitter/centre/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/machinery/power/heavy_emitter/centre/examine(mob/user)
	. = ..()
	if(firing)
		. += "It is currently firing"
	else
		. += "It is currently turned off"

	if(!is_fully_constructed)
		. += "Insert a pyroclastic anomaly core to fuel the core!"

/obj/machinery/power/heavy_emitter/centre/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/assembly/signaler/anomaly/pyro) && !is_fully_constructed)
		visible_message("<span class='notice'>You insert the pyroclastic core into the core chamber!</span>")
		is_fully_constructed = TRUE
		qdel(W)
		return
	return ..()

/obj/machinery/power/heavy_emitter/centre/on_set_is_operational(old_value)
	. = ..()
	if(is_operational)
		EASY_TURN_ON
	else
		EASY_TURN_OFF

/obj/machinery/power/heavy_emitter/centre/check_part_connectivity()
	. = ..()
	if(!anchored)
		return FALSE
	for(var/obj/machinery/power/heavy_emitter/object in orange(1,src))
		if(. == FALSE)
			break
		if(!object.anchored)
			. = FALSE
		if(istype(object,/obj/machinery/power/heavy_emitter/arm))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. =  FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. =  FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. =  FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. =  FALSE
			continue

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/power/heavy_emitter/vent))
			//we dont want an object to appear twice in here
			vents |= object

		if(istype(object,/obj/machinery/power/heavy_emitter/interface))
			if(linked_interface && linked_interface != object)
				. =  FALSE
			linked_interface = object

		if(istype(object,/obj/machinery/power/heavy_emitter/cannon))
			if(linked_cannon && linked_cannon != object)
				. =  FALSE
			linked_cannon = object

/obj/machinery/power/heavy_emitter/centre/should_have_node()
	return anchored

/obj/machinery/power/heavy_emitter/centre/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/heavy_emitter/centre/turn_on()
	if(!is_fully_constructed)
		return EASY_TURN_OFF
	log_game("Heavy Emitter was turned on in [loc]")
	use_power = IDLE_POWER_USE
	firing = TRUE
	icon_state = "centre"

/obj/machinery/power/heavy_emitter/centre/turn_off()
	log_game("Heavy Emitter was turned off in [loc]")
	firing = FALSE
	icon_state = "centre_off"

/obj/machinery/power/heavy_emitter/centre/process(delta_time)
	if(!firing || machine_stat & BROKEN)
		return

	if(!check_part_connectivity())
		return EASY_TURN_OFF

	timer += delta_time

	if(timer >= max_timer)
		if(!use_power_from_net(active_power_usage))
			visible_message("<span class='notice'>Heavy Emitter Core hums lowly, not enough energy is supplied to the core...</span>")
			return
		timer = 0
		radiation_pulse(src,500,can_contaminate=FALSE)
		visible_message("<span class='notice'>Heavy Emitter Core is powering the cannon....</span>")
		INVOKE_ASYNC(linked_cannon,TYPE_PROC_REF(/obj/machinery/power/heavy_emitter/cannon, fire))
		heat += 250

	if(heat > max_heat*0.8 && prob(10))
		visible_message("<span class='danger'>DANGER EMITTER CORE OVERHEATING!</span>")

	if(heat > max_heat)
		visible_message("<span class='danger'>EMITTER CORE OVERHEATING, EXPLOSION EMINENT!</span>")
		INVOKE_ASYNC(src,PROC_REF(overheating))
		return

	for(var/V in vents)
		if(heat <= T0C || !V)
			continue
		var/obj/machinery/power/heavy_emitter/vent/vent = V
		heat = vent.vent_gas(heat)

/obj/machinery/power/heavy_emitter/centre/proc/overheating()
	sleep(5 SECONDS)

	for(var/i in 1 to 10)
		visible_message("<span class='danger'>EXPLOSION IN T - [10-i] SECONDS!</span>")
		sleep(1 SECONDS)

	explosion(src,5,10,20)
/obj/machinery/power/heavy_emitter/arm
	name = "Seismic Stabilizer Arm"
	desc = "Dampens the recoil from firing to virtually nothing"
	icon_state = "arm"

/obj/machinery/power/heavy_emitter/interface
	name = "Kinetic Amplification Manipulation Interface"
	desc = "Allows for control over the core."
	icon_state = "interface_off"
	///Core connected to this thing
	var/obj/machinery/power/heavy_emitter/centre/connected_core

/obj/machinery/power/heavy_emitter/interface/attack_hand(mob/living/user)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/power/heavy_emitter/centre/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		turn_off()
		return

	connected_core = centre

	if(connected_core.firing)
		to_chat(user, "<span class='warning'>You disable the Heavy Emitter!</span>")
		turn_off()
	else
		to_chat(user, "<span class='warning'>You power on the Heavy Emitter!</span>")
		turn_on()

/obj/machinery/power/heavy_emitter/interface/examine(mob/user)
	. = ..()
	if(connected_core)
		. += "CORE HEAT LEVEL : [connected_core.heat]"
		. += "VENTS CONNECTED : [connected_core.vents.len]"

		var/working_vents = 0
		for(var/i in connected_core.vents)
			var/obj/machinery/power/heavy_emitter/vent/iterated_vent = i
			if(iterated_vent.get_vent())
				working_vents++
		. += "VENTS FUNCTIONING : [working_vents]"
	else
		. += "CORE NOT DETECTED"

/obj/machinery/power/heavy_emitter/interface/turn_on()
	icon_state = "interface"
	connected_core.turn_on()

/obj/machinery/power/heavy_emitter/interface/turn_off()
	icon_state = "interface_off"
	connected_core.turn_off()

/obj/machinery/power/heavy_emitter/vent
	name = "Energy Core Vent"
	desc = "Circulates air around the core, preventing it from overheating. Doesn't work in low pressure or when blocked by a wall"
	icon_state = "vent"

/obj/machinery/power/heavy_emitter/vent/proc/get_vent()
	var/turf/open/open_turf = get_step(src,dir)
	//You cant cheese it with space!
	if(!istype(open_turf) || isspaceturf(open_turf))
		return FALSE

	var/datum/gas_mixture/gases = open_turf.return_air()

	if(!gases)
		return FALSE

	return TRUE

/obj/machinery/power/heavy_emitter/vent/proc/vent_gas(heat)
	if(!get_vent())
		return heat

	var/turf/open/open_turf = get_step(src,dir)
	flick("vent_on",src)
	//we skip out the whole thing with gases.heat_capacity() since we assume vent has always the same heat capacity as the air around it for simplicity
	open_turf.temperature = (2*open_turf.temperature + heat) / 3
	open_turf.air_update_turf()
	return open_turf.temperature

/obj/machinery/power/heavy_emitter/cannon
	name = "Energy Optic Converging Cannon"
	desc = "Converges the energy from the core into a singular destructive beam."
	icon_state = "cannon"
	var/warmup_sound = 'sound/machines/warmup1.ogg'
	var/cooldown_sound = 'sound/machines/cooldown1.ogg'
	var/projectile_sound = 'sound/weapons/beam_sniper.ogg'
	var/projectile_type = /obj/projectile/beam/emitter/heavy

/obj/machinery/power/heavy_emitter/cannon/proc/fire()
	playsound(src, warmup_sound, 100)
	sleep(5 SECONDS)
	var/turf/hot_turf = get_step(src,dir)
	new /obj/effect/hotspot(hot_turf)
	var/obj/projectile/proj = new projectile_type(get_turf(src))
	playsound(src, projectile_sound, 100, TRUE)
	proj.firer = src
	proj.fired_from = src
	proj.fire(dir2angle(dir))
	playsound(src, cooldown_sound, 100)

#undef EASY_TURN_ON
#undef EASY_TURN_OFF

/obj/item/paper/guides/heavy_emitter
	name = "Heavy Emitter Manual"
	info = "How to setup the heavy emitter:<br>\
	<ul>\
	<li>Clear a 5 by 5 area, heavy emitter requires only 3 by 3 but vents need access to air to function</li>\
	<li>Mount the core in the middle, weld it in place and insert a pyroclastic anomaly core into it.</li>\
	<li>Mount the Kinetic Amplification Manipulation Interface adjacent to the core so that it is flush with it. weld it to the floor</li>\
	<li>Mount and then weld the vents on any side such that they are flush with the core and have access to air in a tile opposite to them.</li>\
	<li>Mount the cannon on the last empty side and also weld it in place.</li>\
	<li>Install the Seismic Stabilizatiors on the corners such that they are flush with the structure, remember to weld them into place.</li>\
	<li>Fire!</li>\
	</ul><br>\
	<b>If the core starts to overheat we recommend quickly disabling the cannon via the interface, otherwise it will explode</b>"

