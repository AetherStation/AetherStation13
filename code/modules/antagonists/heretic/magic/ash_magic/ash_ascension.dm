/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases 5 streams of fire away from you."
	school = SCHOOL_FORBIDDEN
	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	charge_max = 300
	range = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/ash_final/cast(list/targets, mob/user)
	for(var/X in targets)
		var/T
		T = line_target(-25, range, X, user)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user,T)
		T = line_target(10, range, X, user)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user,T)
		T = line_target(0, range, X, user)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user,T)
		T = line_target(-10, range, X, user)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user,T)
		T = line_target(25, range, X, user)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user,T)
	return ..()

/obj/effect/proc_holder/spell/pointed/ash_final/proc/line_target(offset, range, atom/at , atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_danger("The spell bounces off of [L]!"),span_danger("The spell bounces off of you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s eldritch flames!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/vehicle/sealed/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(1.5)
