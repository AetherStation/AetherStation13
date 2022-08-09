/*! Decals that self delete after a while.
Use the longevity var for a fixed time to delete, or step_time for a gradual change.
step_time can be combined with fade_rate which reduces the alpha until transparent then deletes,
or sprite states which will delete once there are no more states left. Fading can be combined with sprite states.
*/

/obj/effect/decal/temporary
	name = "temporary decal"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/objects.dmi'
	icon_state = ""
	layer = TURF_DECAL_LAYER

	///Can more than one exist on a turf at a time.
	var/unique = TRUE
	///Time until deletion.
	var/longevity = 10 SECONDS
	///Time between steps, if any. Overridden by longevity.
	var/step_time
	///Timer reference
	var/stored_timer
	///Rate at which the decal fades out, using alpha. 0-255.
	var/fade_rate
	///Base icon state, fill this in for sprite_states to work. If the desired icon states are base_1, base_2, base_3 etc, this should be base.
	var/base_icon
	///Optional sprite states. If 3, will go through base_icon_1, base_icon_2, base_icon_3.
	var/sprite_states
	///Current sprite state
	var/current_sprite_state = 0
	///Current change count, to avoid creating a lot of new decals.
	var/counter = 0

/obj/effect/decal/temporary/Initialize()
	. = ..()
	if(unique && loc && isturf(loc)) //Replaces old decals when new ones are added, but only if its at least one step old.
		for(var/obj/effect/decal/temporary/T in loc)
			if(T != src && T.type == type && !QDELETED(T))
				if(T.counter)
					qdel(T)
				else
					qdel(src)
					return
	var/time
	if(longevity)
		time = longevity
	else if(step_time)
		time = step_time
	else
		qdel(src) //Invalid, clean ourselves up.
		return
	if(sprite_states)
		icon_state = "[base_icon]_1"
	stored_timer = addtimer(CALLBACK(src,.proc/update), time, TIMER_STOPPABLE)

/obj/effect/decal/temporary/Destroy()
	. = ..()
	if(stored_timer)
		deltimer(stored_timer)

///Handles the updates. If its time to die, it fades into transparency, or there are no more sprite states, will delete itself.
/obj/effect/decal/temporary/proc/update()
	if(longevity)
		qdel(src)
		return
	counter++
	if(fade_rate)
		if(alpha >= fade_rate)
			alpha -= fade_rate
		else
			qdel(src)
			return
	if(base_icon && sprite_states)
		if(current_sprite_state < sprite_states)
			current_sprite_state++
			icon_state = "[base_icon]_[current_sprite_state]"
		else
			qdel(src)
			return

	var/time
	if(longevity)
		time = longevity
	else if(step_time)
		time = step_time
	stored_timer = addtimer(CALLBACK(src,.proc/update), time, TIMER_STOPPABLE)
