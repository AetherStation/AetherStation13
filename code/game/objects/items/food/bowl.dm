/obj/item/reagent_containers/glass/bowl
	name = "bowl"
	desc = "A simple bowl, used for soups and salads."
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/glass = 500)
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_ASSISTANT * 0.6

/obj/item/reagent_containers/glass/bowl/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_CUSTOM_FOOD_REPLACED, .proc/handle_replacement)
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/salad/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

/obj/item/reagent_containers/glass/bowl/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance(icon, "soup_filling")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/reagent_containers/glass/bowl/proc/handle_replacement(datum/source, datum/component/customizable_reagent_holder/CRH)
	SIGNAL_HANDLER
	if (reagents.total_volume)
		CRH.replacement = /obj/item/food/soup/empty
	else
		CRH.replacement = /obj/item/food/salad/empty
