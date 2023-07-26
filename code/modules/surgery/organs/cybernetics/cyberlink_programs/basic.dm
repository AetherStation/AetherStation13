/obj/item/cyberlink_program/neural_expander
	name = "Neural stabilizer program"
	desc = "Reduces the neural stress caused by too many cybernetics"
	cost = 1
	var/reduction = 1

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
