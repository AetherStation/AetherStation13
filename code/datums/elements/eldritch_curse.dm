/// -- NEW Wiskey's Heretic Curse --

/datum/element/eldritch_curse
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/duration = 5 MINUTES
	var/datum/callback/curse_proc
	var/datum/callback/uncurse_proc

/datum/element/eldritch_curse/Attach(datum/target, duration, datum/callback/curse, datum/callback/uncurse)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.duration = duration
	src.curse_proc = curse
	src.uncurse_proc = uncurse
	RegisterSignal(target, COMSIG_ITEM_PICKUP, .proc/pickup_safety_check)

/datum/element/eldritch_curse/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_PICKUP))

/datum/element/eldritch_curse/proc/pickup_safety_check(datum/source, mob/user)
	SIGNAL_HANDLER

	if(curse_safety_check(source, user))
		return

	curse_proc.Invoke(user)
	addtimer(CALLBACK(src, curse_proc/uncurse_proc, user),duration)
	Detach(source)

/datum/element/eldritch_curse/proc/curse_safety_check(datum/source, mob/living/carbon/user)
	if(!istype(user))
		return FALSE

	if(HAS_TRAIT(user, TRAIT_ANTIMAGIC) || IS_HERETIC_OR_MONSTER(user))
		return FALSE

	return TRUE
