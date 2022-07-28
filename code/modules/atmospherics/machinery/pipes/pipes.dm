#define ARROW_ICON(x) image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = x)

/obj/machinery/atmospherics/pipe
	damage_deflection = 12
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	var/datum/pipeline/parent = null

	paintable = TRUE
	var/amendable = FALSE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = 90

	// Lists can't have integer keys
	var/static/list/radial_options = list(
		"NORTH" = ARROW_ICON(NORTH),
		"EAST" = ARROW_ICON(EAST),
		"SOUTH" = ARROW_ICON(SOUTH),
		"WEST" = ARROW_ICON(WEST)
	)

#undef ARROW_ICON

/obj/machinery/atmospherics/pipe/New()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	volume = 35 * device_type
	..()

/obj/machinery/atmospherics/pipe/Initialize()
	. = ..()

	if (hide)
		AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE) //if changing this, change the subtypes RemoveElements too, because thats how bespoke works

/obj/machinery/atmospherics/pipe/nullifyNode(i)
	var/obj/machinery/atmospherics/oldN = nodes[i]
	..()
	if(oldN)
		SSair.add_to_rebuild_queue(oldN)

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/get_rebuild_targets()
	if(!QDELETED(parent))
		return
	parent = new
	return list(parent)

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)

/obj/machinery/atmospherics/pipe/return_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	if(air_temporary)
		return air_temporary.remove(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/wrench_act_secondary(mob/living/user, obj/item/wrench/W)
	if(!amendable)
		return ..()

	var/choice = show_radial_menu(user, src, radial_options, require_near = TRUE)
	if(choice)
		// Figure out which way we're adding
		var/direction = 0
		switch(choice)
			if("NORTH")
				direction = NORTH
			if("EAST")
				direction = EAST
			if("SOUTH")
				direction = SOUTH
			if("WEST")
				direction = WEST

		// Don't be already connected there
		if(GetInitDirections() & direction)
			to_chat(user, "<span class='warning'>There is already a connection in that direction!</span>")
			return FALSE
		// Don't overlap other pipes
		for(var/obj/machinery/atmospherics/other in loc)
			if((other.piping_layer != piping_layer) && !((other.pipe_flags | pipe_flags) & PIPING_ALL_LAYER)) // Don't continue if either pipe goes across all layers
				continue
			if(other.GetInitDirections() & direction) // New connection is occupied by other
				to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
				return FALSE

		var/turf/T = loc

		// Remove from adjacent pipes
		for(var/obj/machinery/atmospherics/other in nodes)
			var/index = other.nodes.Find(src)
			other.nodes[index] = null
		
		// Don't spill or lose gas
		flags_1 |= NODECONSTRUCT_1
		parent.air.volume -= volume
		parent.members -= src
		// Keep the old pipenet (bit hacky)
		parent = null // Destroy() won't qdel the pipenet
		device_type = 0 // Destroy() won't nullifyNodes()  (we do that manually earlier)

		deconstruct()

		// Create new pipe
		var/obj/machinery/atmospherics/pipe/new_pipe = createAmend(T, direction)
		new_pipe.name = name
		new_pipe.SetInitDirections()
		new_pipe.on_construction(color, piping_layer)
		// Let's keep spraycan and fingerprints too
		new_pipe.atom_colours = atom_colours
		new_pipe.update_atom_colour()
		transfer_fingerprints_to(new_pipe)
		
		// Feedback
		W.play_tool_sound(new_pipe)
		user.visible_message( \
			"[user] amends \the [src].", \
			span_notice("You amend \the [src]."), \
			span_hear("You hear ratcheting."))
	return TRUE

/obj/machinery/atmospherics/pipe/proc/createAmend(turf/T, direction)

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)

	releaseAirToTurf()

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	. = ..()

/obj/machinery/atmospherics/pipe/update_icon()
	. = ..()
	update_layer()

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)

/obj/machinery/atmospherics/pipe/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		pipe_color = paint_color
		update_node_icon()
	return paintable
