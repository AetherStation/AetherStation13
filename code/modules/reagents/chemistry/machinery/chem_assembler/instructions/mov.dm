/datum/chem_assembly_instruction/move
	var/slot

/datum/chem_assembly_instruction/move/execute(obj/machinery/chem_assembler/A)
	A.current_slot = slot
	return CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/move/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/S = uppertext(arguments[1])
	if (S in state["slots"])
		slot = state["slots"][S]
		return
	return "invalid slot [S]"
