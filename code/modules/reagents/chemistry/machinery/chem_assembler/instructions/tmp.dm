/datum/chem_assembly_instruction/temp
	var/temp

/datum/chem_assembly_instruction/temp/execute(obj/machinery/chem_assembler/A)
	A.target_temperature = temp
	return CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/temp/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/S = text2num(arguments[1])
	if (!isnum(S))
		return "invalid number [arguments[1]]"
	if (S < 0 || S > 1000)
		return "number too large/small 0 < [S] < 1000"
	temp = S
	return
