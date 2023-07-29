/obj/item/cyberlink_program/neural_expander
	name = "Neural stabilizer program"
	desc = "Reduces the neural stress caused by too many cybernetics"
	cost = 1
	var/reduction = 1

/obj/item/cyberlink_program/neural_expander/examine(mob/user)
	. = ..()
	. += "It reduces the neural stress gain by [reduction]"

/obj/item/cyberlink_program/neural_expander/added_to_link(obj/item/organ/cyberimp/cyberlink/link)
	link.implant_stress_reduction += reduction

/obj/item/cyberlink_program/neural_expander/removed_from_link(obj/item/organ/cyberimp/cyberlink/link)
	link.implant_stress_reduction -= reduction

/obj/item/cyberlink_program/neural_expander/nt1
	tier = CYBER_CLASS_NT_LOW

/obj/item/cyberlink_program/neural_expander/nt1
	tier = CYBER_CLASS_NT_HIGH
	reduction = 2

/obj/item/cyberlink_program/neural_expander/syndie
	tier = CYBER_CLASS_SYNDICATE
	reduction = 3

/obj/item/cyberlink_program/neural_expander/syndie/hidden
	hidden = TRUE

/obj/item/cyberlink_program/neural_expander/terra
	tier = CYBER_CLASS_TERRA
	reduction = 4

/obj/item/cyberlink_program/defense
	name = "Cyberspace defensive program"
	desc = "Increases the defense of your cyberlink, at cost of cyberlinks attack strength."
	cost = 1
	var/stat_up = 1

/obj/item/cyberlink_program/defense/examine(mob/user)
	. = ..()
	. += "Increases the defense of your cyberlink by [stat_up] points, while reducing it's offensive capabilities by [stat_up] points."

/obj/item/cyberlink_program/defense/added_to_link(obj/item/organ/cyberimp/cyberlink/link)
	link.cyberlink_defense += stat_up
	link.cyberlink_attack -= stat_up

/obj/item/cyberlink_program/defense/removed_from_link(obj/item/organ/cyberimp/cyberlink/link)
	link.cyberlink_defense -= stat_up
	link.cyberlink_attack += stat_up

/obj/item/cyberlink_program/defense/nt1
	tier = CYBER_CLASS_NT_LOW

/obj/item/cyberlink_program/defense/nt2
	tier = CYBER_CLASS_NT_HIGH
	stat_up = 2

/obj/item/cyberlink_program/defense/syndie
	tier = CYBER_CLASS_SYNDICATE
	stat_up = 3

/obj/item/cyberlink_program/defense/syndie/hidden
	hidden = TRUE
/obj/item/cyberlink_program/defense/terra
	tier = CYBER_CLASS_TERRA
	stat_up = 4

/obj/item/cyberlink_program/attack
	name = "Cyberspace offensive program"
	desc = "Increases the defense of your cyberlink, at cost of cyberlinks attack strength."
	cost = 1
	var/stat_up = 1

/obj/item/cyberlink_program/attack/examine(mob/user)
	. = ..()
	. += "Increases the offensive capabilities of your cyberlink by [stat_up] points, while reducing it's defense by [stat_up] points."

/obj/item/cyberlink_program/attack/added_to_link(obj/item/organ/cyberimp/cyberlink/link)
	link.cyberlink_defense -= stat_up
	link.cyberlink_attack += stat_up

/obj/item/cyberlink_program/attack/removed_from_link(obj/item/organ/cyberimp/cyberlink/link)
	link.cyberlink_defense += stat_up
	link.cyberlink_attack -= stat_up

/obj/item/cyberlink_program/attack/nt1
	tier = CYBER_CLASS_NT_LOW

/obj/item/cyberlink_program/attack/nt2
	tier = CYBER_CLASS_NT_HIGH
	stat_up = 2

/obj/item/cyberlink_program/attack/syndie
	tier = CYBER_CLASS_SYNDICATE
	stat_up = 3

/obj/item/cyberlink_program/attack/syndie/hidden
	hidden = TRUE
/obj/item/cyberlink_program/attack/terra
	tier = CYBER_CLASS_TERRA
	stat_up = 4

