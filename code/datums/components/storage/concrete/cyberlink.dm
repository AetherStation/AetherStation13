/datum/component/storage/concrete/cyberlink
	max_w_class = WEIGHT_CLASS_TINY
	drop_all_on_destroy = TRUE
	drop_all_on_deconstruct = TRUE
	silent = TRUE
	allow_big_nesting = TRUE
	var/obj/item/organ/cyberimp/cyberlink/link

/datum/component/storage/concrete/cyberlink/Initialize(datum/component/storage/concrete/master,amt)
	. = ..()
	max_items = amt
	max_combined_w_class = amt
	link = parent
	set_holdable(subtypesof(/obj/item/cyberware),null)

/datum/component/storage/concrete/cyberlink/handle_item_insertion(obj/item/I, prevent_warning, mob/M, datum/component/storage/remote)
	. = ..()
	link.insert_program(I)

/datum/component/storage/concrete/cyberlink/remove_from_storage(atom/movable/AM, atom/new_location)
	link.eject_program(AM)
	. = ..()

/datum/component/storage/concrete/cyberlink/canreach_react(datum/source, list/next)
	. = ..()
	var/obj/item/organ/cyberimp/cyberlink/link = parent
	if(link == source)
		return COMPONENT_FORCE_REACH
