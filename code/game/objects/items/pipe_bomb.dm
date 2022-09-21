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
	w_class = WEIGHT_CLASS_NORMAL
	var/shrapnel_type = /obj/projectile/bullet/shrapnel
	var/shrapnel_magnitude = 2
	var/sealed = FALSE
	/// Is the pipe bomb active? Only used for overlay.
	var/fused = FALSE
	/// How long the fuse of the pipe bomb is? Actual fuse length is random from half of fuse length to fuse length seconds.
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
		if (sealed && !fuse_length)
			to_chat(user, span_warning("\the [src] is sealed, you can't add a fuse to this."))
			return
		if (fuse_length >= 5)
			to_chat(user, span_warning("You can't lengthen the fuse of \the [src] any more."))
			return

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
		UnregisterSignal(src, COMSIG_ITEM_UNWRAPPED)
		var/datum/component/C = GetComponent(/datum/component/pellet_cloud)
		C.RemoveComponent()
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
			desc = "Often made by those with strong feelings about industrial society."
			RegisterSignal(src, COMSIG_ITEM_UNWRAPPED, .proc/unwrapped)
			AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_magnitude)
		else
			desc = "A sealed pipe."
		icon_state = "pipe_sealed"
		spillable = FALSE
		reagents.flags = NONE
		sealed = TRUE

/obj/item/reagent_containers/pipe/attack_self(mob/user)
	if (sealed && fuse_length)
		fused = TRUE
		addtimer(CALLBACK(src, .proc/detonate), rand(fuse_length * 0.5 SECONDS, fuse_length SECONDS))
		update_icon(UPDATE_OVERLAYS)
		return
	. = ..()

/obj/item/reagent_containers/pipe/proc/unwrapped(datum/source)
	SIGNAL_HANDLER

	if (prob(80))
		detonate()

/obj/item/reagent_containers/pipe/proc/detonate()
	reagents.chem_temp += rand(5, 20)
	reagents.handle_reactions()
	// well, if it didn't explode then we just remove the fuse.
	fuse_length = 0
	update_icon(UPDATE_OVERLAYS)
