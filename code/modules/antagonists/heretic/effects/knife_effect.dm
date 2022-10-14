// "Floating ghost blade" effect for blade heretics
/obj/effect/floating_blade
	name = "knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	/// The color the knife glows around it.
	var/glow_color = "#ececff"

/obj/effect/floating_blade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, INNATE_TRAIT)
	add_filter("knife", 2, list("type" = "outline", "color" = glow_color, "size" = 1))

/obj/item/sharpener/eldritch
	name = "eldritch whetstone"
	desc = "A block, empowered by eldritch magic. Sharp weapons will be enhanced when used on the stone."
	prefix = "eldritch sharpened"

/obj/item/sharpener/eldritch/proc/activate(mob/user, obj/item/I)
	if(I.force >= max || I.throwforce >= max) //So the whetstone never reduces force or throw_force
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return
	if(requires_sharpness && !I.get_sharpness())
		to_chat(user, span_warning("You can only sharpen items that are already sharp, such as knives!"))
		return
	if(is_type_in_list(I, list(/obj/item/melee/transforming/energy, /obj/item/dualsaber))) //You can't sharpen the photons in energy meelee weapons
		to_chat(user, span_warning("You don't think \the [I] will be the thing getting modified if you use it on \the [src]!"))
		return

	//This block is used to check more things if the item has a relevant component.
	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max) //Stores the bitflags returned by SEND_SIGNAL
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, span_warning("[I] is not able to be sharpened right now!"))
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !signal_out)) //No sharpening stuff twice
		to_chat(user, span_warning("[I] has already been refined before. It cannot be sharpened further!"))
		return
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED)) //If the item has a relevant component and COMPONENT_BLOCK_SHARPEN_APPLIED is returned, the item only gets the throw force increase
		I.force = clamp(I.force + increment, 0, max)
	user.visible_message(span_notice("[user] sharpens [I] with [src]!"), span_notice("You sharpen [I], making it much more deadly than before."))
	playsound(user, 'sound/items/unsheath.ogg', 25, TRUE)
	I.sharpness = SHARP_EDGED //When you whetstone something, it becomes an edged weapon, even if it was previously dull or pointy
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]" //This adds a prefix and a space to the item's name regardless of what the prefix is
	desc = "[desc] At least, it used to."
	update_appearance()
