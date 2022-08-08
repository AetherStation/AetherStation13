/obj/item/pipe/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	// This is a bit wack but pipe construction is like that.
	if (!ispath(pipe_type, /obj/machinery/atmospherics/pipe/simple) || ((dir - 1) & dir))
		return

	if(tool.use_tool(src, user, amount=5))
		to_chat(user, span_notice("You weld one end of \the [src] shut."))
		var/obj/item/reagent_containers/pipe/P = new (loc)
		P.color = color
		qdel(src)
		return TRUE

/obj/item/reagent_containers/pipe
	name = "capped pipe"
	desc = "Appears to be a straight pipe with one side welded shut."
	icon_state = "pipe"
	volume = 40
	reagent_flags = REFILLABLE | DRAINABLE | AMOUNT_VISIBLE
	spillable = TRUE
	var/sealed = FALSE
	var/fused = FALSE
	var/fuse_length = 0

/obj/item/reagent_containers/pipe/update_overlays()
	. = ..()
	if (fused)
		. += mutable_appearance(icon = icon, icon_state = "pipe_wf", appearance_flags = RESET_COLOR)
	else if (fuse_length)
		. += mutable_appearance(icon = icon, icon_state = "pipe_w", appearance_flags = RESET_COLOR)

/obj/item/reagent_containers/pipe/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if (istype(I, /obj/item/stack/cable_coil))
		if (fuse_length >= 5)
			to_chat(user, span_warning("You can't lengthen the fuse of \the [src] any more."))

		var/obj/item/stack/cable_coil/C = I
		if (!C.use(1))
			return
		if (fuse_length)
			to_chat(user, span_notice("You lengthen the fuse on \the [src]."))
		else
			to_chat(user, span_notice("You add a fuse to \the [src]."))
		fuse_length++
		update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/pipe/welder_act(mob/living/user, obj/item/tool)
	. = ..()

	if(!tool.tool_start_check(user, amount=2))
		return TRUE
	if (sealed)
		to_chat(user, span_notice("You open \the [src]."))
		// You are using a welder to open a container, what did you expect?
		if (fuse_length)
			detonate()
		else
			reagents.chem_temp += rand(5, 20)
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		spillable = TRUE
		reagents.flags = reagent_flags
		sealed = FALSE
	else
		to_chat(user, span_notice("You seal \the [src] shut."))
		if (fuse_length)
			name = "pipe bomb"
			desc = "A work of art, it fills you with the wish to destroy industrial society."
		else
			desc = "A sealed pipe."
		icon_state = "pipe_sealed"
		sealed = TRUE
		spillable = FALSE
		reagents.flags = NONE

/obj/item/reagent_containers/pipe/attack_self(mob/user)
	if (sealed && fuse_length)
		fused = TRUE
		addtimer(CALLBACK(src, .proc/detonate), rand(fuse_length * 0.5 SECONDS, fuse_length SECONDS))
		update_icon(UPDATE_OVERLAYS)
		return
	. = ..()

/obj/item/reagent_containers/pipe/proc/detonate()
	reagents.chem_temp += rand(5, 20)
	reagents.handle_reactions()
	// well, if it didn't explode then we just remove the fuse.
	fuse_length = 0
	update_icon(UPDATE_OVERLAYS)
