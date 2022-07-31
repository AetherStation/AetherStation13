/datum/chem_assembly_instruction/jump
	var/jump_to

/datum/chem_assembly_instruction/jump/execute(obj/machinery/chem_assembler/A)
	A.current = jump_to
	return CHEM_INST_RERUN

/datum/chem_assembly_instruction/jump/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/L = arguments[1]
	if (L in state["labels"])
		jump_to = state["labels"][L]
		return
	return "invalid label [L]"
