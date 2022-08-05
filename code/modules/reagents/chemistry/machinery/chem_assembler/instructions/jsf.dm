/datum/chem_assembly_instruction/jump/jump_slot_full/execute(obj/machinery/chem_assembler/A)
	if (A.current_slot.total_volume >= A.current_slot.maximum_volume)
		A.current = jump_to
		return CHEM_INST_RERUN
	return CHEM_INST_SUCCESS
