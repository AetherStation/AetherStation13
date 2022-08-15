#define CHEM_INST_FAIL 0
#define CHEM_INST_SUCCESS 1
#define CHEM_INST_RERUN 2

/datum/chem_assembly_instruction
	var/datum/chem_assembly_instruction/next

/datum/chem_assembly_instruction/proc/execute(obj/machinery/chem_assembler/A, delta_time)
	return CHEM_INST_FAIL

/datum/chem_assembly_instruction/proc/parse_arguments(arguments, state)
	return "Unimplemented Instruction"
