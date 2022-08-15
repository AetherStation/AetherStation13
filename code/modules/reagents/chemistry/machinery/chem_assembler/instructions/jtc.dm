/datum/chem_assembly_instruction/jump/jump_temperature_correct/execute(obj/machinery/chem_assembler/A)
	var/const/error_margin = 0.25

	var/datum/reagents/S = A.slots["H"]
	if (S.chem_temp < A.target_temperature + error_margin && S.chem_temp > A.target_temperature - error_margin)
		A.current = jump_to
		return CHEM_INST_RERUN
	return CHEM_INST_SUCCESS
