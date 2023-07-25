/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W) //don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, PROC_REF(recursive_insertion), W, user)
		return
	. = ..()

/datum/component/storage/concrete/bluespace/bag_of_holding/proc/recursive_insertion(obj/item/W, mob/living/user)
	var/atom/A = parent
	var/safety = tgui_alert(user, "You get a feeling this is pretty stupid.", "Put in [A.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)))
		return
	var/turf/loccheck = get_turf(A)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(W)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

	log_game("[key_name(user)] deleted themselves with two bags of holding at [loc_name(loccheck)].")

	user.gib(TRUE, TRUE, TRUE)
	qdel(A)
